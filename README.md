Habit Tracker — Suivi d'habitudes quotidiennes

##  Description

Cette base de données modélise une application de suivi d'habitudes quotidiennes.
Elle permet aux utilisateurs d'enregistrer leurs habitudes, de les cocher chaque jour,
et d'analyser leur régularité sur la durée.

## Objectif

Aider les utilisateurs à :
- Définir leurs habitudes personnelles (sport, lecture, méditation, sommeil…)
- Suivre jour par jour si ces habitudes ont été réalisées
- Calculer des statistiques de régularité (séries consécutives, taux de complétion)
- Identifier les habitudes les plus tenues et les jours les plus productifs

##  Utilisateurs cibles

- Étudiants souhaitant structurer leur quotidien
- Personnes en démarche de développement personnel
- Sportifs suivant leur entraînement
- Toute personne voulant améliorer sa discipline

##  Sources de données

Les données sont **générées manuellement** pour simuler une utilisation réelle
sur plusieurs semaines avec 3 utilisateurs et 5 habitudes distinctes.

##  Moteur de base de données

**SQLite** — simple, sans serveur, fichier unique `habit_tracker.db`.

##  Lancement

```bash
sqlite3 habit_tracker.db < schema.sql
sqlite3 habit_tracker.db < data/seed.sql
sqlite3 habit_tracker.db < queries.sql
sqlite3 habit_tracker.db < analysis.sql
```

Ou avec DB Browser for SQLite : ouvrir `habit_tracker.db` et importer les fichiers SQL.
