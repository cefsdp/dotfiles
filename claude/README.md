# Configuration Claude Code partagée

Protocole de travail et commandes communs à tous les projets de `~/code/cefsdp`.

```
bash claude/install.sh
```

Idempotent, relançable. À rejouer après avoir amorcé un nouveau projet suivi.

---

## Sur une nouvelle machine

```bash
# 1. Claude Code, si absent
npm install -g @anthropic-ai/claude-code && claude   # puis /login

# 2. L'atelier et ce dépôt
mkdir -p ~/code/cefsdp && cd ~/code/cefsdp
git clone git@github.com:cefsdp/dotfiles.git

# 3. Le protocole
bash dotfiles/claude/install.sh

# 4. Les projets suivis, dans l'atelier
git clone git@github.com:cefsdp/loqos-ariane.git "LoqOS - Module Comptable"

# 5. Relancer, pour lier les projets fraîchement clonés
bash dotfiles/claude/install.sh
```

L'étape 5 n'est pas un doublon : le script ne lie que les dépôts déjà présents. Tout
nouveau clone demande une relance.

Si `dotfiles` ne vit pas dans l'atelier sur cette machine, passer le chemin en argument :

```bash
bash ~/dotfiles/claude/install.sh ~/code/cefsdp
```

### Ce qui ne se transporte pas

| | Pourquoi | Quoi faire |
| --- | --- | --- |
| `.claude/settings.local.json` | Réglages de permission propres au poste, non versionnés | Se réaccorde à l'usage, à la première demande |
| Mémoire automatique de Claude | `~/.claude/projects/<projet>/memory/`, jamais partagée entre machines | Rien — c'est précisément pourquoi le protocole écrit l'état dans git |
| Autorisation des imports externes | Le `CLAUDE.md` de l'atelier importe un fichier situé hors du dossier de travail | Une boîte de dialogue s'affiche **une fois par projet**. Accepter |

Cette dernière est normale et attendue : le protocole vit au-dessus des dépôts, donc
l'import sort du dossier de travail vu depuis un projet. Refuser désactive le protocole
pour ce projet, et la question n'est plus reposée.

---

## Ce que fait l'installation

| Ce qui est posé | Où | Pourquoi là |
| --- | --- | --- |
| Skills `demarrer` et `cloturer` | Liens dans `~/.claude/skills/` | Seul emplacement découvert dans **tous** les projets |
| `CLAUDE.md` de l'atelier | `~/code/cefsdp/CLAUDE.md` | Les `CLAUDE.md` remontent jusqu'à la racine du système |
| Vue des projets suivis | Liens dans `~/code/cefsdp/.claude/projets/` | Vue centralisée sans sortir les fichiers de leur dépôt |

---

## Pourquoi les skills ne sont pas dans `~/code/cefsdp/.claude/`

C'était l'intention de départ, et elle ne fonctionne pas. La documentation est explicite :

> Project skills load from `.claude/skills/` in the directory where you start Claude Code
> and in every parent directory **up to the repository root**.

La remontée s'arrête à la racine du dépôt. `~/code/cefsdp` est **au-dessus** de chaque
dépôt : un `.claude/skills/` posé là ne serait jamais découvert.

Les `CLAUDE.md` se comportent différemment — eux remontent jusqu'à la racine du système —
d'où le montage mixte : le protocole au-dessus des dépôts, les skills dans `~/.claude/`.

Les liens pointent vers ce dépôt, qui est versionné : une correction du protocole se
propage par `git pull`, pas par recopie sur chaque machine.

---

## Amorcer un projet suivi

Créer dans le dépôt du projet :

```
.claude/projet/
├── ETAT.md                          60 lignes max, réécrit à chaque session
├── PROJET.md                        cahier des charges, contraintes, non-objectifs
├── PIEGES.md                        pièges rencontrés. Cumulatif, jamais élagué
├── INBOX.md                         idées captées, pas encore rangées
├── versions/V1.md                   arbre phases / fonctionnalités / tâches
└── sessions/AAAA-MM-JJ-<prénom>.md
```

Terminer le `CLAUDE.md` du projet par `@.claude/projet/ETAT.md`, puis relancer
`install.sh` pour créer le lien dans la vue centralisée.

**Ces fichiers sont versionnés avec le code du projet.** C'est ce qui fait que la reprise
fonctionne d'une machine à l'autre, et qu'un clone du seul dépôt suffit à tout avoir.

`.claude/settings.local.json` reste propre à chaque poste : à mettre dans le `.gitignore`
du projet.

---

## Exclure un projet du protocole

Le `CLAUDE.md` de l'atelier se charge dans les 16 dépôts. Pour l'écarter d'un projet, dans
son `.claude/settings.local.json` :

```json
{
  "claudeMdExcludes": ["/home/cefsdp/code/cefsdp/CLAUDE.md"]
}
```

---

## Le guide d'origine

`protocole-reference.md`, à côté de ce fichier, est le raisonnement complet qui a mené à ce
montage. Il porte en tête la table des trois points sur lesquels la mise en œuvre a divergé,
et pourquoi. `PROTOCOLE.md` est ce qui fait foi ; le guide sert à comprendre.

---

## Vérifier

Dans une session : `/context` liste les fichiers de mémoire réellement chargés, `/skills`
liste les commandes disponibles.
