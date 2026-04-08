-- ============================================================
-- queries.sql — Manipulation quotidienne du Habit Tracker
-- Simule les actions typiques d'un utilisateur de l'app
-- ============================================================

PRAGMA foreign_keys = ON;

-- ------------------------------------------------------------
-- 1. INSERTIONS — Ajouter du contenu
-- ------------------------------------------------------------

-- Ajouter un nouvel utilisateur
INSERT INTO utilisateurs (nom, email, date_inscription)
VALUES ('David', 'david@example.com', '2024-01-15');

-- Ajouter une nouvelle habitude au catalogue
INSERT INTO habitudes (nom, description, frequence_cible)
VALUES ('Gratitude', 'Lister 3 choses pour lesquelles on est reconnaissant', 'quotidienne');

-- David s'abonne à deux habitudes
-- (on récupère les IDs via sous-requêtes pour ne pas les coder en dur)
INSERT INTO objectifs (utilisateur_id, habitude_id, date_debut)
VALUES
    ((SELECT id FROM utilisateurs WHERE email = 'david@example.com'),
     (SELECT id FROM habitudes WHERE nom = 'Sport'),
     '2024-01-15'),

    ((SELECT id FROM utilisateurs WHERE email = 'david@example.com'),
     (SELECT id FROM habitudes WHERE nom = 'Gratitude'),
     '2024-01-15');

-- Enregistrer le suivi du jour pour David (15 janvier)
INSERT INTO suivi (utilisateur_id, habitude_id, date, fait, note)
VALUES
    ((SELECT id FROM utilisateurs WHERE email = 'david@example.com'),
     (SELECT id FROM habitudes WHERE nom = 'Sport'),
     '2024-01-15', 1, 'Course à pied, 5 km'),

    ((SELECT id FROM utilisateurs WHERE email = 'david@example.com'),
     (SELECT id FROM habitudes WHERE nom = 'Gratitude'),
     '2024-01-15', 1, 'Famille, santé, soleil');

-- ------------------------------------------------------------
-- 2. MISES À JOUR — Modifier des données existantes
-- ------------------------------------------------------------

-- Corriger une entrée oubliée :
-- Alice avait oublié de cocher la Méditation le 5 janvier
UPDATE suivi
SET fait = 1, note = 'Ajout oublié'
WHERE utilisateur_id = (SELECT id FROM utilisateurs WHERE nom = 'Alice')
  AND habitude_id    = (SELECT id FROM habitudes WHERE nom = 'Méditation')
  AND date           = '2024-01-05';

-- Mettre à jour l'email d'un utilisateur
UPDATE utilisateurs
SET email = 'alice.dupont@example.com'
WHERE nom = 'Alice';

-- Changer la description d'une habitude
UPDATE habitudes
SET description = 'Activité physique d''au moins 45 minutes (niveau intermédiaire)'
WHERE nom = 'Sport';

-- ------------------------------------------------------------
-- 3. SUPPRESSIONS — Retirer des données
-- ------------------------------------------------------------

-- David se désinscrit de l'habitude Sport
-- (ON DELETE CASCADE supprimera aussi ses entrées de suivi associées)
DELETE FROM objectifs
WHERE utilisateur_id = (SELECT id FROM utilisateurs WHERE nom = 'David')
  AND habitude_id    = (SELECT id FROM habitudes WHERE nom = 'Sport');

-- Supprimer une entrée de suivi incorrecte (doublon ou erreur)
DELETE FROM suivi
WHERE utilisateur_id = (SELECT id FROM utilisateurs WHERE nom = 'David')
  AND habitude_id    = (SELECT id FROM habitudes WHERE nom = 'Sport')
  AND date           = '2024-01-15';

-- Supprimer un utilisateur (ses objectifs et suivis sont supprimés en CASCADE)
DELETE FROM utilisateurs
WHERE nom = 'David';
