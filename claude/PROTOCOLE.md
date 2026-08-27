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
├── PIEGES.md                        pièges rencontrés. Cumulatif, on n'y retire jamais rien
├── INBOX.md                         idées captées, pas encore rangées
├── versions/V<n>.md                 arbre phases / fonctionnalités / tâches
└── sessions/AAAA-MM-JJ-<prénom>.md  une entrée par session, jamais modifiée après coup
                                     (`-2`, `-3`… si l'on clôture deux fois le même jour)
```

Deux régimes d'écriture, à ne pas mélanger — c'est ce qui décide où va une ligne.

| Régime | Fichiers | Ce qu'on y fait |
| --- | --- | --- |
| **Volatile** — remis à zéro | `ETAT.md` | Réécrit en entier à chaque clôture. Ne dit que : où on en est ce soir |
| **Cumulatif** — jamais élagué | `PIEGES.md`, `sessions/` | On ajoute, on ne retire pas |
| **Durable** — corrigé, pas empilé | `PROJET.md`, `versions/`, ADR du projet | Modifié quand la décision change, pas quand la session change |

**`ETAT.md` ne porte aucune section cumulative.** Un fichier réécrit à chaque session ne
peut pas être aussi la mémoire longue du projet : les deux rôles ont des rythmes
contraires, et c'est toujours la mémoire longue qui gagne — le fichier grossit jusqu'à
ce que plus personne ne le lise. D'où la limite de 60 lignes, qui n'est pas un caprice
de format mais le seul garde-fou vérifiable.

Chaque chose à sa place, dans l'ordre où on se pose la question :

| Ce qu'on veut écrire | Où | Pourquoi pas dans `ETAT.md` |
| --- | --- | --- |
| Un piège, un contournement, un message d'erreur trompeur | `PIEGES.md` | Ne périme jamais. C'est ce qui rapporte le plus au collègue suivant |
| Une décision coûteuse à défaire | ADR du projet, sinon `PROJET.md` | Le raisonnement d'origine vaut plus que la conclusion |
| Une contrainte durable — version d'outil, convention, non-objectif | `PROJET.md` | Se corrige, ne s'empile pas |
| Un arbitrage sur l'ordre ou le découpage du travail | `versions/V<n>.md` | Se lit là où il s'applique |
| Ce qui a été tenté puis abandonné aujourd'hui | `sessions/` | Daté, jamais modifié après coup |
| Où on en est, ce qui est cassé, la prochaine étape | `ETAT.md` | — |

**Avant d'ajouter une ligne à `ETAT.md`, vérifie qu'elle n'existe pas déjà ailleurs.**
La duplication est le mode de défaillance normal de ce fichier : elle ne se voit pas à
l'écriture, et elle produit deux vérités qui divergent silencieusement.

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
- Dès qu'un piège est découvert, écris-le **immédiatement** dans `PIEGES.md` ; dès
  qu'une décision d'architecture est prise, dans l'ADR du projet ou `PROJET.md`.
  N'attends pas la fin — c'est en le contournant qu'on sait pourquoi il piège.
- Un piège consigné vaut mieux qu'un piège recontourné. `PIEGES.md` est le fichier qui
  rapporte le plus au collègue suivant.

---

## En fin de session — je dirai « on clôture »

`/cloturer` exécute ce rituel.

1. Crée `.claude/projet/sessions/AAAA-MM-JJ-<prénom>.md` : date, prénom, branche, objectif,
   ce qui a été fait avec les SHA et les IDs, **ce qui a été tenté puis abandonné et
   pourquoi** ← ne saute jamais ce point, ce qui reste cassé ou non testé, et la prochaine
   étape formulée comme une action exécutable telle quelle.
2. Mets à jour les statuts dans `versions/V<n>.md`.
3. Verse dans `PIEGES.md` les pièges rencontrés, et dans l'ADR du projet ou `PROJET.md`
   les décisions durables. **Avant de réécrire `ETAT.md`, pas après** : ce qui reste
   après ce versement est exactement ce qui a sa place dans l'état courant.
4. Réécris `ETAT.md` **en entier**, sans repartir de la version précédente. Si le
   résultat dépasse 60 lignes, c'est qu'une ligne appartient à un autre fichier.
5. Vérifie qu'aucune ligne `[~]` ne traîne sans être réellement en cours, et qu'aucun `[x]`
   n'est sans SHA.
6. Commit + push.

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
