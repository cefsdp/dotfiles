---
name: cloturer
description: Rituel de fin de session — écrit l'entrée de session, met à jour le backlog et l'état courant, vérifie la cohérence des statuts, puis commit et push. À invoquer quand on dit « on clôture ».
---

Exécute le protocole de fin de session.

1. Crée `.claude/projet/sessions/AAAA-MM-JJ-<prénom>.md` — suffixe `-2`, `-3`… si le
   fichier existe déjà, parce qu'on a repris le travail après une première clôture.
   **Ne jamais compléter l'entrée précédente** : elle décrit une session close, et la
   modifier après coup ferait mentir l'historique.
   - date, prénom, branche
   - objectif de la session
   - ce qui a été fait, avec les SHA et les IDs de tâches
   - **ce qui a été tenté puis abandonné, et pourquoi** ← ne saute jamais ce point
   - ce qui reste cassé ou non testé
   - la prochaine étape, formulée comme une action exécutable telle quelle
2. Mets à jour les statuts dans le fichier de version.
3. Verse les pièges rencontrés dans `.claude/projet/PIEGES.md`, et les décisions
   durables dans l'ADR du projet ou `PROJET.md`. **Avant l'étape 4, pas après.**
4. Réécris `.claude/projet/ETAT.md` **en entier**, sans repartir de la version
   précédente.
5. Vérifie la cohérence des statuts (voir ci-dessous).
6. Montre les fichiers modifiés, **puis** commit et push.

## Rappels sur lesquels ne pas transiger

- La ligne « tenté puis abandonné » est celle qui rapporte le plus : sans elle, le collègue
  suivant repart dans l'impasse qu'on vient de quitter.
- La prochaine étape se formule comme une **action exécutable telle quelle**, pas comme une
  intention. « Écrire le docker-compose PostgreSQL et Redis » plutôt que « avancer sur la
  persistance ».
- Aucun `[x]` sans SHA, et aucun `[x]` dont le critère de fin n'a pas été vérifié de bout en
  bout. **Le code écrit ne vaut pas critère vérifié.**
- Vérifie que chaque SHA cité est bien un ancêtre de `HEAD` :
  `git merge-base --is-ancestor <sha> HEAD`. Un SHA relevé avant un `--amend` pointe vers un
  commit orphelin, encore présent dans le reflog local mais absent de la branche.
- Aucune ligne `[~]` qui traîne sans être réellement en cours.
- `ETAT.md` reste sous 60 lignes, et **ne porte aucune section cumulative** : ni pièges,
  ni journal de décisions. Un fichier réécrit à chaque session ne peut pas être aussi la
  mémoire longue du projet — c'est toujours la mémoire longue qui gagne, et le fichier
  finit par n'être plus lu. Compte les lignes avant de commiter : `wc -l`.
- Avant d'écrire une ligne dans `ETAT.md`, vérifie qu'elle n'est pas déjà dans
  `PROJET.md`, dans le fichier de version ou dans une ADR. La duplication ne se voit pas
  à l'écriture et produit deux vérités qui divergent.
