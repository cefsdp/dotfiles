# Configuration Claude Code partagée

Protocole de travail et commandes communs à tous les projets de `~/code/cefsdp`.

```
bash claude/install.sh
```

Idempotent, relançable. À rejouer sur une nouvelle machine, et après avoir amorcé un
nouveau projet suivi.

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
