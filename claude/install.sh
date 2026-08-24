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
ATELIER="$(cd "$ICI/../.." && pwd)"   # ~/code/cefsdp
SKILLS_UTILISATEUR="$HOME/.claude/skills"

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
if [ ! -e "$ATELIER/CLAUDE.md" ]; then
  cat > "$ATELIER/CLAUDE.md" <<'FIN'
<!-- Généré par dotfiles/claude/install.sh. Le contenu vit dans les fichiers importés. -->

@dotfiles/claude/PROTOCOLE.md

@.claude/ATELIER.md
FIN
  info "créé : $ATELIER/CLAUDE.md"
else
  info "déjà en place : $ATELIER/CLAUDE.md"
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
