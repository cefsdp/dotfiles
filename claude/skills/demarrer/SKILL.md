---
name: demarrer
description: Rituel de reprise de session — lit l'état du projet, les dernières sessions et le backlog, puis résume où on en est avant d'écrire la moindre ligne de code. À invoquer en début de session sur un projet suivi.
---

Exécute le protocole de démarrage, dans cet ordre.

1. `git pull --rebase`, puis `git status` et `git log --oneline -15`.
2. Lis `.claude/projet/ETAT.md` en entier.
3. Lis les 3 fichiers les plus récents de `.claude/projet/sessions/`.
4. Lis `.claude/projet/PROJET.md` et la version active ; relève les tâches `[~]`.
5. Si des commits existent après le dernier SHA cité en session, lis leur diff
   (`git diff <sha>..HEAD --stat`) : quelqu'un a travaillé sans clôturer.
6. Résume en **10 lignes maximum** : où en est le projet, ce qui est en cours, ce qui est
   cassé, la prochaine étape, l'ID de la tâche concernée.
7. Pose les questions bloquantes maintenant.

**N'écris aucun code tant que le point 6 n'est pas validé.**

Si l'état contredit ce qui est demandé ensuite, signale-le au lieu de trancher seul.

Si `.claude/projet/` n'existe pas, ce projet n'est pas encore suivi : propose de l'amorcer
plutôt que de deviner un état. Ne fabrique jamais un `ETAT.md` à partir du seul code.
