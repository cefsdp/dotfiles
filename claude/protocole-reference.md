# Protocole Claude Code multi-machines — synthèse et mise en œuvre

> **Guide d'origine, conservé pour son raisonnement.** La mise en œuvre effective diverge
> sur quatre points — trois tranchés le 2026-08-24 en montant l'atelier, un le 2026-08-27. Le protocole qui fait foi
> est `PROTOCOLE.md`, à côté de ce fichier.
>
> | Le guide dit | Ce qui a été fait | Pourquoi |
> | --- | --- | --- |
> | `CLAUDE.md` par dépôt | Un seul, dans `~/code/cefsdp/`, plus un court par projet | Les `CLAUDE.md` remontent jusqu'à la racine du système : un seul suffit pour les seize dépôts |
> | `.claude/commands/` par dépôt | Skills dans `dotfiles`, liés depuis `~/.claude/skills/` | La découverte des skills **s'arrête à la racine du dépôt** : un dossier commun au-dessus ne serait jamais lu |
| `ETAT.md` porte « Décisions » et « Pièges » | Pièges dans `PIEGES.md`, décisions dans les ADR ou `PROJET.md` | Ces sections sont cumulatives, `ETAT.md` est réécrit à chaque session : le fichier atteignait 156 lignes pour 60 permises. C'est l'échec n° 4 de la section 8, arrivé exactement comme annoncé |
> | `ETAT.md` et `sessions/` à la racine de `.claude/` | Tout sous `.claude/projet/` | Un seul dossier à lier vers la vue centralisée de l'atelier |
>
> Les versions vivent en outre dans `.claude/projet/versions/`, pour qu'un backlog à
> plusieurs millésimes reste lisible.

---

## 1. Le problème et le principe directeur

Plusieurs développeurs travaillent sur le même dépôt avec Claude Code, sur des machines
différentes. Chaque session repart d'un contexte vierge, et la mémoire locale de Claude
Code (`~/.claude/projects/…`) **ne traverse pas les machines**.

Trois conséquences qui structurent tout le reste :

- **Git est le seul canal commun.** Tout état utile doit être un fichier versionné.
- **Ne partagez pas l'historique brut des prompts.** Volumineux, bruyant, jamais relu.
  Ce qui se transmet, c'est le _résumé décidé_ de la session.
- **Le dépôt fait loi.** Une seule source de vérité. Un outil de suivi parallèle
  (Notion, Linear) pourrirait en quelques semaines — et ce serait celui que l'IA ne lit
  pas.

---

## 2. Architecture de fichiers

```
CLAUDE.md                        ← protocole, chargé automatiquement
.claude/
└── projet/
    ├── ETAT.md                  ← état courant, court, réécrit à chaque session
    ├── PROJET.md                ← cahier des charges, contraintes, non-objectifs
    ├── INBOX.md                 ← idées captées, pas encore rangées
    ├── versions/
    │   ├── V1.md                ← arbre phases / fonctionnalités / tâches
    │   └── V2.md
    └── sessions/
        ├── 2026-08-22-marc.md   ← une entrée par session, jamais modifiée
        └── 2026-08-23-julie.md

# /demarrer et /cloturer ne sont pas ici : ce sont des skills partagés,
# dans dotfiles/claude/skills/, liés depuis ~/.claude/skills/.
```

### Rôle de chaque fichier

| Fichier         | Nature                                        | Rythme d'écriture        |
| --------------- | --------------------------------------------- | ------------------------ |
| `CLAUDE.md`     | Le protocole                                  | Rarement modifié         |
| `ETAT.md`       | Volatile — « où j'en suis ce soir »           | Réécrit à chaque session |
| `sessions/*.md` | Historique — immuable                         | Créé en fin de session   |
| `PROJET.md`     | Durable — « ce qu'on a décidé de construire » | Au fil des discussions   |
| `V<n>.md`       | Backlog exécutable                            | En continu               |
| `INBOX.md`      | Capture brute non triée                       | Dès qu'une idée sort     |

**La distinction qui compte :** `ETAT.md` est volatile, le référentiel projet est
durable. Les mélanger fait pourrir les deux.

---

## 3. Les quatre conventions structurantes

### 3.1 Identifiants stables — `V1-P2-F03-T04`

C'est ce qui relie tout le système : le commit, l'entrée de session, `ETAT.md` et le
backlog parlent du même objet. Sans ID, chaque fichier redevient une île.

- Jamais réutilisés, jamais renumérotés, jamais réordonnés.
- Un nouvel élément s'ajoute **à la fin de sa section**, avec le numéro suivant.

_Coût assumé :_ au bout de quelques mois, `V1.md` sera dans un ordre historique et non
logique. C'est le bon échange — un fichier un peu désordonné mais fiable vaut mieux
qu'un fichier propre que git casse toutes les semaines.

### 3.2 Cinq statuts, pas trois

```
[?] idée non spécifiée   ← capturée en discussion, pas encore cadrée
[ ] à faire              ← spécifiée, prête à être prise
[~] en cours
[x] fait                 ← critère de fin vérifié + SHA du commit
[-] abandonné            ← reste visible, avec sa raison
```

`[?]` empêche le backlog de se remplir de lignes qui _ressemblent_ à du travail prêt.
`[-]` empêche de re-débattre du même arbitrage dans deux mois.

### 3.3 Critère de fin par fonctionnalité

Sans lui, « fait » veut dire « le code est écrit », ce qui n'est pas la même chose.

### 3.4 Un fichier par session

Plutôt qu'un journal unique : zéro conflit de merge quand deux personnes clôturent le
même jour.

---

## 4. Le `CLAUDE.md` complet

```markdown
# Protocole de collaboration multi-machines

Plusieurs développeurs travaillent sur ce dépôt avec Claude Code, sur des machines
différentes. Ta mémoire locale n'est PAS partagée avec eux. Le seul canal commun est git
: tout état utile doit être écrit dans des fichiers versionnés.

## Fichiers de suivi

- `.claude/ETAT.md` — état courant. Max 60 lignes, réécrit à chaque session.
- `.claude/sessions/AAAA-MM-JJ-<prénom>.md` — une entrée par session, jamais modifiée
  après coup.
- `.claude/projet/PROJET.md` — cahier des charges, contraintes, non-objectifs,
  glossaire.
- `.claude/projet/versions/V<n>.md` — arbre phases / fonctionnalités / tâches.
- `.claude/projet/INBOX.md` — idées captées, pas encore rangées.

## Au démarrage — dans cet ordre, AVANT toute modification de code

1. `git pull --rebase`, puis `git status` et `git log --oneline -15`.
2. Lis `.claude/ETAT.md` en entier.
3. Lis les 3 fichiers les plus récents de `.claude/sessions/`.
4. Lis `PROJET.md` et la version active ; relève les tâches `[~]`.
5. Si des commits existent après le dernier SHA cité en session, lis leur diff
   (`git diff <sha>..HEAD --stat`) : quelqu'un a travaillé sans clôturer.
6. Résume-moi en 10 lignes max : où en est le projet, ce qui est en cours, ce qui est
   cassé, la prochaine étape, l'ID de la tâche concernée.
7. Pose-moi les questions bloquantes maintenant. Si l'état contredit ce que je te
   demande, signale-le au lieu de trancher seul.
8. N'écris aucun code tant que je n'ai pas validé le point 6.

## Pendant la session

- Découpe le travail en petits pas ; fais valider chaque pas avant le suivant.
- Commits atomiques, messages en français : `feat(V1-P1-F01): ...`
- Dès qu'une décision d'architecture est prise ou qu'un piège est découvert, note-le
  immédiatement dans `.claude/ETAT.md`. N'attends pas la fin.

## En fin de session (je dirai « on clôture »)

1. Crée `.claude/sessions/AAAA-MM-JJ-<prénom>.md` :
   - date, prénom, branche
   - objectif de la session
   - ce qui a été fait, avec les SHA et les IDs de tâches
   - ce qui a été tenté puis abandonné, et pourquoi ← ne saute jamais ce point
   - ce qui reste cassé ou non testé
   - la prochaine étape, formulée comme une action exécutable telle quelle
2. Mets à jour les statuts dans le fichier de version.
3. Réécris `.claude/ETAT.md`.
4. Vérifie qu'aucune ligne `[~]` ne traîne sans être réellement en cours, et qu'aucun
   `[x]` n'est sans SHA.
5. Commit + push.

## Règles d'écriture du backlog — strictes

- Les identifiants ne sont JAMAIS réutilisés, renumérotés ni réordonnés. Un nouvel
  élément s'ajoute à la fin de sa section, avec le numéro suivant.
- Ne supprime jamais une ligne. Une tâche annulée passe en `[-]` avec sa raison.
- Ne passe une tâche en `[x]` que si le critère de fin est vérifié de bout en bout, pas
  quand le code est écrit. Cite le SHA du commit.
- N'invente jamais de tâche. Si ce que je décris est flou, écris-la en `[?]` avec la
  date, sans la spécifier à ma place.
- Avant d'ajouter quoi que ce soit, vérifie que ça ne double pas un ID existant.

## Mode cahier des charges

Quand je parle du produit sans demander de code : ne code pas, ne modifie aucun fichier
source.

1. Fais-moi préciser ce qui est ambigu.
2. Propose les lignes exactes à ajouter ou modifier, sous forme de diff.
3. Attends ma validation avant d'écrire.
4. Si je n'ai pas tranché la version ou la phase, mets-le dans `INBOX.md` avec la date —
   ne devine pas.

## État courant (chargé automatiquement)

@.claude/ETAT.md
```

**Point d'attention :** n'importez avec `@` que `ETAT.md`. `PROJET.md` et les fichiers
de version vont grossir ; un import les injecterait intégralement à chaque session.
Laissez Claude aller les lire à la demande.

---

## 5. Les gabarits

### `.claude/ETAT.md`

```
Mis à jour le : <date> par <prénom>
Branche active : <branche>
Tâche en cours : <ID>

## Objectif en cours
<une phrase>

## Ça marche
## Ça ne marche pas / non testé
## Prochaine étape (une action concrète, exécutable telle quelle)
## Décisions prises (et pourquoi)
## Pièges — ne pas refaire
## Commandes utiles (installer / lancer / tester)
```

### `.claude/projet/versions/V1.md`

```markdown
# V1 — MVP

Statuts : [?] idée non spécifiée · [ ] à faire · [~] en cours · [x] fait · [-] abandonné

## P1 — Socle technique

### V1-P1-F01 — Authentification [~]

Critère de fin : un utilisateur peut créer un compte, se connecter, se déconnecter.

- [x] V1-P1-F01-T01 — Schéma BDD utilisateurs — a3f9c21
- [~] V1-P1-F01-T02 — Endpoint /login — Marc, depuis 22/08
- [ ] V1-P1-F01-T03 — Réinitialisation du mot de passe
- [-] V1-P1-F01-T04 — OAuth Google — reporté V2 : coût de config > valeur MVP
- [?] V1-P1-F01-T05 — 2FA — évoqué le 20/08, à spécifier
```

### `dotfiles/claude/skills/demarrer/SKILL.md` — `/demarrer`

```markdown
---
description: Rituel de reprise de session
---

Exécute le protocole de démarrage du CLAUDE.md, dans l'ordre :

1. `git pull --rebase`, `git status`, `git log --oneline -15`
2. Lis `.claude/ETAT.md`
3. Lis les 3 fichiers les plus récents de `.claude/sessions/`
4. Lis la version active dans `.claude/projet/` et relève les tâches `[~]`
5. Si des commits existent après le dernier SHA cité en session, lis leur diff
6. Résume en 10 lignes max : où en est le projet, ce qui est en cours, ce qui est cassé,
   la prochaine étape, l'ID de la tâche concernée
7. Pose-moi les questions bloquantes. N'écris aucun code avant ma validation.
```

### `dotfiles/claude/skills/cloturer/SKILL.md` — `/cloturer`

```markdown
---
description: Rituel de fin de session
---

Exécute le protocole de fin de session du CLAUDE.md : crée l'entrée dans
`.claude/sessions/`, mets à jour les statuts du backlog, réécris `.claude/ETAT.md`,
vérifie la cohérence des statuts, commit et push. Montre-moi les fichiers modifiés avant
de committer.
```

---

## 6. Ce qui est automatique, ce qui ne l'est pas

| Mécanisme                           | Chargement                   | Fiabilité    |
| ----------------------------------- | ---------------------------- | ------------ |
| `CLAUDE.md`                         | Automatique à chaque session | Garantie     |
| `@fichier.md` cité dans `CLAUDE.md` | Automatique avec lui         | Garantie     |
| « Lis tel fichier au démarrage »    | Sur décision du modèle       | Probabiliste |
| `/demarrer` (commande)              | Déclenché par vous, un mot   | Déterministe |
| Hook `SessionStart`                 | Automatique, sans rien taper | Déterministe |

La doc officielle précise que `CLAUDE.md` est traité comme du contexte, pas comme une
configuration imposée. D'où la commande `/demarrer` : le déclenchement ne dépend pas de
l'humeur du modèle.

Note de nomenclature : les commandes personnalisées ont été fusionnées avec les skills.
`.claude/commands/` reste supporté, mais **la migration a été faite d'emblée** — non par
goût de la nouveauté, mais parce que ni `commands/` ni `skills/` ne sont découverts
au-dessus de la racine d'un dépôt. Partager une commande entre projets impose de passer
par `~/.claude/skills/`, donc autant y mettre la forme recommandée.

---

## 7. Plan d'implémentation — petits pas

### Étape A — Squelette (15 min, un seul dépôt pilote)

- [x] A1. Créer l'arborescence `.claude/projet/` (versions, sessions)
- [ ] A2. Copier le `CLAUDE.md` de la section 4 à la racine
- [ ] A3. Créer `.claude/ETAT.md` vide au gabarit
- [ ] A4. Créer `.claude/projet/INBOX.md` vide
- [ ] A5. Commit + push

### Étape B — Amorcer le référentiel (1 à 2 h, à deux)

- [ ] B1. Rédiger `PROJET.md` : le pourquoi, les contraintes, le glossaire
- [ ] B2. Y ajouter la section **non-objectifs** — c'est celle qui évite de re-débattre
      des mêmes arbitrages
- [ ] B3. Créer `versions/V1.md` : découper en phases, puis en fonctionnalités
- [ ] B4. Écrire le **critère de fin** de chaque fonctionnalité (avant les tâches)
- [ ] B5. Descendre en tâches uniquement pour la phase 1 — le reste reste en `[?]`
- [ ] B6. Marquer `[x]` ce qui est déjà fait dans le code existant

### Étape C — Automatiser le rituel (20 min)

- [x] C1. Créer le skill `demarrer` dans `dotfiles/claude/skills/`
- [x] C2. Créer le skill `cloturer` dans `dotfiles/claude/skills/`
- [ ] C3. Ajouter `@.claude/ETAT.md` à la fin du `CLAUDE.md`
- [ ] C4. Tester : ouvrir une session, taper `/demarrer`, vérifier le résumé
- [ ] C5. Commit + push

### Étape D — Rodage (2 semaines, sans généraliser)

- [ ] D1. Chacun fait au moins trois sessions complètes `/demarrer` → `/cloturer`
- [ ] D2. Après chaque session, se demander : « qu'est-ce que le collègue n'aurait pas
      compris en lisant l'entrée ? » → ajuster le gabarit
- [ ] D3. Faire une reprise à froid : reprendre le travail de l'autre sans lui parler.
      C'est le seul vrai test du système.
- [ ] D4. Corriger le `CLAUDE.md` à partir de ce test

### Étape E — Généralisation

- [ ] E1. Reporter la version rodée sur les autres dépôts
- [ ] E2. Décider si un hook `SessionStart` est nécessaire (seulement si `/demarrer` est
      oublié en pratique)
- [x] E3. Migration `commands/` → `skills/` — faite d'emblée, voir section 6

---

## 8. Utilisation au quotidien

**Ouvrir une session** `/demarrer` → lire le résumé → valider ou corriger → travailler.

**Discuter du produit sans coder** Le dire explicitement (« on parle cahier des charges
»). Claude propose des diffs sur `V<n>.md` ou `INBOX.md`, vous validez, il écrit. Aucun
fichier source touché.

**Une idée surgit en pleine session de dev** Elle va dans `INBOX.md` avec la date. On ne
tranche pas la version tout de suite.

**Fermer une session** `/cloturer`, relire les fichiers modifiés, laisser committer.

**Trier l'INBOX** Une fois par semaine : chaque ligne part vers un `versions/V<n>.md` en `[?]`,
ou disparaît.

---

## 9. Les cinq pièges

1. **Sauter « ce qui a été tenté puis abandonné ».** C'est la ligne qui rapporte le plus
   : sans elle, le collègue repart dans l'impasse que vous venez de quitter. C'est
   exactement ce que l'historique des prompts contenait.
2. **Coder avant de valider le résumé de démarrage.** C'est ce qui transforme le rituel
   en décoration.
3. **Passer une tâche en `[x]` parce que le code est écrit.** Le critère de fin est
   vérifié de bout en bout, ou la tâche reste `[~]`.
4. **Laisser `ETAT.md` grossir.** Au-delà de 60 lignes, plus personne ne le lit. Ce qui
   est durable descend dans `PROJET.md` ou le backlog.
5. **Maintenir un second outil de suivi en parallèle.** Le dépôt fait loi — ou rien ne
   fait loi.

Et un filet de sécurité assumé : **quelqu'un oubliera de clôturer.** C'est prévu —
l'étape 5 du démarrage reconstruit l'écart depuis les commits. Le protocole doit tenir
sans discipline parfaite.
