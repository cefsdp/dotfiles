# Protocole de travail — atelier cefsdp

Chargé automatiquement dans tous les projets de `~/code/cefsdp`, parce que Claude Code lit
les `CLAUDE.md` du dossier courant **et de tous les dossiers au-dessus**.

Ce fichier est générique. Tout ce qui est propre à un projet vit dans le `CLAUDE.md` de ce
projet, qui est lu après celui-ci et peut donc le préciser.

<!-- Source : ~/code/cefsdp/dotfiles/claude/PROTOCOLE.md — versionné, ne pas éditer la copie. -->

---

## Le dépôt fait loi

Plusieurs machines, parfois plusieurs personnes. **La mémoire locale de Claude n'est pas
partagée.** Le seul canal commun est git : tout état utile s'écrit dans des fichiers
versionnés, dans le dépôt du projet concerné.

Un projet suivi porte cette arborescence, **versionnée avec son code** :

```
<projet>/.claude/projet/
├── ETAT.md                          état courant. 60 lignes max, réécrit à chaque session
├── PROJET.md                        cahier des charges, contraintes, non-objectifs, glossaire
├── INBOX.md                         idées captées, pas encore rangées
├── versions/V<n>.md                 arbre phases / fonctionnalités / tâches
└── sessions/AAAA-MM-JJ-<prénom>.md  une entrée par session, jamais modifiée après coup
```

Le `CLAUDE.md` du projet se termine par `@.claude/projet/ETAT.md`, seul import automatique.

Les versions sont dans leur propre dossier : un projet finit par en compter plusieurs, et
les laisser à plat noie `ETAT.md` et `PROJET.md` au milieu du backlog.

`~/code/cefsdp/.claude/projets/<nom>` est un lien symbolique vers ce dossier : la vue est
centralisée, les fichiers restent dans leur dépôt. Un clone du projet suffit à tout avoir.

---

## Au démarrage — avant toute modification de code

1. `git pull --rebase`, puis `git status` et `git log --oneline -15`.
2. Lis `.claude/projet/ETAT.md` en entier.
3. Lis les 3 fichiers les plus récents de `.claude/projet/sessions/`.
4. Lis `PROJET.md` et la version active dans `versions/` ; relève les tâches `[~]`.
5. Si des commits existent après le dernier SHA cité en session, lis leur diff
   (`git diff <sha>..HEAD --stat`) : quelqu'un a travaillé sans clôturer.
6. Résume en 10 lignes max : où en est le projet, ce qui est en cours, ce qui est cassé,
   la prochaine étape, l'ID de la tâche concernée.
7. Pose les questions bloquantes maintenant. Si l'état contredit ce que je demande,
   signale-le au lieu de trancher seul.
8. N'écris aucun code tant que je n'ai pas validé le point 6.

`/demarrer` exécute ce rituel.

---

## Pendant la session

- Découpe le travail en petits pas ; fais valider chaque pas avant le suivant.
- Commits atomiques, messages en français : `feat(V1-P1-F01): ...`
- Dès qu'une décision d'architecture est prise ou qu'un piège est découvert, note-le
  **immédiatement** dans `ETAT.md`. N'attends pas la fin.
- Un piège consigné vaut mieux qu'un piège recontourné. La section « Pièges » est celle
  qui rapporte le plus au collègue suivant.

---

## En fin de session — je dirai « on clôture »

`/cloturer` exécute ce rituel.

1. Crée `.claude/projet/sessions/AAAA-MM-JJ-<prénom>.md` : date, prénom, branche, objectif,
   ce qui a été fait avec les SHA et les IDs, **ce qui a été tenté puis abandonné et
   pourquoi** ← ne saute jamais ce point, ce qui reste cassé ou non testé, et la prochaine
   étape formulée comme une action exécutable telle quelle.
2. Mets à jour les statuts dans `versions/V<n>.md`.
3. Réécris `ETAT.md`.
4. Vérifie qu'aucune ligne `[~]` ne traîne sans être réellement en cours, et qu'aucun `[x]`
   n'est sans SHA.
5. Commit + push.

---

## Règles d'écriture du backlog — strictes

- Les identifiants ne sont **jamais** réutilisés, renumérotés ni réordonnés. Un nouvel
  élément s'ajoute à la fin de sa section, avec le numéro suivant.
- Ne supprime jamais une ligne. Une tâche annulée passe en `[-]` avec sa raison.
- Ne passe une tâche en `[x]` que si le critère de fin est vérifié **de bout en bout**, pas
  quand le code est écrit. Cite le SHA du commit.
- **Ne jamais `git commit --amend` après avoir inscrit un SHA.** L'amend change le hash, et
  la ligne se met à citer un commit orphelin : présent dans le reflog local, absent de la
  branche, introuvable au premier clone. Inscrire le SHA dans un commit suivant.
- N'invente jamais de tâche. Si ce que je décris est flou, écris-la en `[?]` avec la date,
  sans la spécifier à ma place.
- Avant d'ajouter quoi que ce soit, vérifie que ça ne double pas un ID existant.

Statuts : `[ ]` à faire · `[~]` en cours · `[x]` fait, avec SHA · `[-]` annulé, avec raison
· `[?]` flou, à préciser, avec date.

---

## Mode cahier des charges

Quand je parle du produit sans demander de code : **ne code pas, ne modifie aucun fichier
source.**

1. Fais-moi préciser ce qui est ambigu.
2. Propose les lignes exactes à ajouter ou modifier, sous forme de diff.
3. Attends ma validation avant d'écrire.
4. Si je n'ai pas tranché la version ou la phase, mets-le dans `INBOX.md` avec la date —
   ne devine pas.

---

## Travail transverse entre projets

`~/code/cefsdp/.claude/ATELIER.md` porte la carte des projets et de leurs modules.

Quand une demande touche un module qui appartient à un autre projet, **dis-le avant de
coder** : nomme le projet, le module, et ce qu'il faudrait y changer. Ne modifie jamais un
autre dépôt dans la même session sans validation explicite — un commit qui traverse deux
dépôts ne se révise pas et ne se révoque pas d'un bloc.

Lire un projet voisin suppose que son dossier soit accessible. S'il ne l'est pas, demande-le
plutôt que de supposer son contenu.
