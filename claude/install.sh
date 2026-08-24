#!/usr/bin/env bash
#
# Installe la configuration Claude Code partagée de l'atelier.
#
# Trois choses, et une seule raison à chacune :
#
#   1. Les skills sont liés depuis ~/.claude/skills/ — c'est le seul emplacement
#      découvert dans tous les projets. La remontée des skills s'arrête à la racine du
#      dépôt, donc un dossier commun placé au-dessus ne serait jamais vu.
#   2. Le CLAUDE.md de l'atelier est posé au-dessus des dépôts — les CLAUDE.md, eux,
#      remontent jusqu'à la racine du système.
#   3. Les liens pointent vers ce dépôt, qui est versionné. Une correction du protocole
#      se propage par `git pull`, pas par recopie.
#
# Idempotent : relançable sans dommage.

set -euo pipefail

ICI="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_UTILISATEUR="$HOME/.claude/skills"

# Dossier qui contient les dépôts. Par défaut le parent de `dotfiles`, ce qui suppose
# que ce dépôt soit cloné dans l'atelier. Sur une machine où il vit ailleurs, le passer
# en argument ou par la variable ATELIER :
#
#     bash claude/install.sh ~/code/cefsdp
#     ATELIER=~/dev/perso bash claude/install.sh
ATELIER="${1:-${ATELIER:-$(cd "$ICI/../.." && pwd)}}"

if [ ! -d "$ATELIER" ]; then
  printf '\033[1;31m-----> \033[0mAtelier introuvable : %s\n' "$ATELIER" >&2
  printf '       Passer le bon chemin en argument : bash claude/install.sh ~/code/cefsdp\n' >&2
  exit 1
fi
ATELIER="$(cd "$ATELIER" && pwd)"

info() { printf '\033[1;32m-----> \033[0m%s\n' "$1"; }
avert() { printf '\033[1;33m-----> \033[0m%s\n' "$1"; }

# Crée un lien, en sauvegardant une éventuelle vraie copie déjà présente.
lier() {
  local source="$1" cible="$2"

  if [ -L "$cible" ]; then
    if [ "$(readlink -f "$cible")" = "$(readlink -f "$source")" ]; then
      info "déjà en place : $cible"
      return
    fi
    rm "$cible"
  elif [ -e "$cible" ]; then
    mv "$cible" "$cible.backup"
    avert "$cible existait en dur — déplacé vers $cible.backup"
  fi

  ln -s "$source" "$cible"
  info "lié : $cible → $source"
}

# 1. Skills partagés, exposés à tous les projets
mkdir -p "$SKILLS_UTILISATEUR"
for chemin in "$ICI"/skills/*/; do
  lier "${chemin%/}" "$SKILLS_UTILISATEUR/$(basename "$chemin")"
done

# 2. Protocole commun, chargé dans tous les dépôts de l'atelier
mkdir -p "$ATELIER/.claude/projets"

# Chemin d'import du protocole : relatif si ce dépôt vit dans l'atelier — le cas courant —
# absolu sinon. Un import relatif se résout depuis le fichier qui le contient, donc depuis
# l'atelier, pas depuis le dossier de travail.
case "$ICI" in
  "$ATELIER"/*) IMPORT_PROTOCOLE="${ICI#"$ATELIER"/}/PROTOCOLE.md" ;;
  *)            IMPORT_PROTOCOLE="$ICI/PROTOCOLE.md" ;;
esac

MARQUEUR="<!-- Généré par dotfiles/claude/install.sh."
if [ -e "$ATELIER/CLAUDE.md" ] && ! head -1 "$ATELIER/CLAUDE.md" | grep -q "$MARQUEUR"; then
  avert "$ATELIER/CLAUDE.md existe et n'a pas été généré ici — laissé tel quel."
  avert "  Y ajouter à la main : @$IMPORT_PROTOCOLE  et  @.claude/ATELIER.md"
else
  cat > "$ATELIER/CLAUDE.md" <<FIN
$MARQUEUR Ne pas éditer :
     le contenu vit dans les fichiers importés. Relancer le script pour le régénérer. -->

@$IMPORT_PROTOCOLE

@.claude/ATELIER.md
FIN
  info "écrit : $ATELIER/CLAUDE.md → @$IMPORT_PROTOCOLE"
fi

# Carte de l'atelier : amorcée si absente, jamais écrasée — elle se remplit à la main.
if [ ! -e "$ATELIER/.claude/ATELIER.md" ]; then
  cat > "$ATELIER/.claude/ATELIER.md" <<'FIN'
# Atelier — carte des projets

Sert à répondre à « pour cette fonctionnalité, quel projet et quel module toucher ».

**Ne lister que ce qui est vrai.** Un projet dont la structure est inconnue vaut mieux
marqué « non renseigné » qu'approximé : une carte fausse est pire que pas de carte.

| Projet | Dépôt | Nature | Modules |
| --- | --- | --- | --- |
FIN
  info "amorcé : $ATELIER/.claude/ATELIER.md — à compléter"
else
  info "déjà en place : $ATELIER/.claude/ATELIER.md"
fi

# 3. Vue centralisée des projets suivis
#    Un lien par projet portant un .claude/projet/. Les fichiers restent dans leur dépôt.
lies=0
for depot in "$ATELIER"/*/; do
  [ -d "$depot/.claude/projet" ] || continue

  # Le nom du dépôt distant plutôt que celui du dossier : « LoqOS - Module Comptable »
  # donnerait « loqos---module-comptable », alors que le dépôt s'appelle « loqos-ariane ».
  # C'est ce nom-là qui circule entre machines et dans les conversations.
  distant="$(git -C "$depot" remote get-url origin 2>/dev/null || true)"
  if [ -n "$distant" ]; then
    nom="$(basename "$distant" .git)"
  else
    nom="$(basename "$depot" | tr '[:upper:] ' '[:lower:]-')"
  fi

  lier "${depot%/}/.claude/projet" "$ATELIER/.claude/projets/$nom"
  lies=$((lies + 1))
done
[ "$lies" -eq 0 ] && avert "aucun projet suivi trouvé (aucun .claude/projet/)"

echo
info "Terminé. Vérifier avec /context puis /skills dans une session."
