-- ============================================================
-- schema.sql — Habit Tracker
-- Création du schéma de la base de données
-- ============================================================

PRAGMA foreign_keys = ON;

-- ------------------------------------------------------------
-- Table : utilisateurs
-- Stocke les personnes qui utilisent l'application.
-- L'email est unique pour éviter les doublons de comptes.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS utilisateurs (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    nom              TEXT    NOT NULL,
    email            TEXT    NOT NULL UNIQUE,
    date_inscription DATE    NOT NULL DEFAULT (DATE('now'))
);

-- ------------------------------------------------------------
-- Table : habitudes
-- Catalogue des habitudes disponibles dans l'application.
-- frequence_cible indique si l'habitude est attendue
-- chaque jour ou seulement certains jours.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS habitudes (
    id               INTEGER PRIMARY KEY AUTOINCREMENT,
    nom              TEXT    NOT NULL,
    description      TEXT,
    frequence_cible  TEXT    NOT NULL DEFAULT 'quotidienne'
        CHECK(frequence_cible IN ('quotidienne', 'hebdomadaire'))
);

-- ------------------------------------------------------------
-- Table : objectifs
-- Table de jonction entre utilisateurs et habitudes.
-- Représente le fait qu'un utilisateur "s'abonne" à une
-- habitude à partir d'une date donnée.
-- Contrainte UNIQUE pour éviter de s'abonner deux fois.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS objectifs (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id  INTEGER NOT NULL,
    habitude_id     INTEGER NOT NULL,
    date_debut      DATE    NOT NULL DEFAULT (DATE('now')),
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (habitude_id)    REFERENCES habitudes(id)    ON DELETE CASCADE,
    UNIQUE (utilisateur_id, habitude_id)  -- un utilisateur ne peut s'abonner qu'une fois à chaque habitude
);

-- ------------------------------------------------------------
-- Table : suivi
-- Enregistrement quotidien des habitudes.
-- Chaque ligne = un utilisateur + une habitude + un jour.
-- fait = 1 si réalisée, 0 sinon.
-- note = commentaire optionnel du jour.
-- Contrainte UNIQUE pour éviter les doublons par jour.
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS suivi (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    utilisateur_id  INTEGER NOT NULL,
    habitude_id     INTEGER NOT NULL,
    date            DATE    NOT NULL,
    fait            INTEGER NOT NULL DEFAULT 0
        CHECK(fait IN (0, 1)),
    note            TEXT,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (habitude_id)    REFERENCES habitudes(id)    ON DELETE CASCADE,
    UNIQUE (utilisateur_id, habitude_id, date)  -- une seule entrée par user/habitude/jour
);

-- ------------------------------------------------------------
-- Index pour accélérer les requêtes fréquentes
-- ------------------------------------------------------------

-- Recherches de suivi par utilisateur
CREATE INDEX IF NOT EXISTS idx_suivi_utilisateur ON suivi(utilisateur_id);

-- Recherches de suivi par date (vue calendrier)
CREATE INDEX IF NOT EXISTS idx_suivi_date ON suivi(date);

-- Recherches de suivi par habitude (stats globales)
CREATE INDEX IF NOT EXISTS idx_suivi_habitude ON suivi(habitude_id);

-- ------------------------------------------------------------
-- Vue : vue_suivi_complet
-- Affiche le suivi avec les noms lisibles, sans avoir à
-- faire des JOIN manuels à chaque requête.
-- ------------------------------------------------------------
CREATE VIEW IF NOT EXISTS vue_suivi_complet AS
SELECT
    s.id,
    u.nom           AS utilisateur,
    h.nom           AS habitude,
    s.date,
    s.fait,
    s.note
FROM suivi s
JOIN utilisateurs u ON s.utilisateur_id = u.id
JOIN habitudes    h ON s.habitude_id    = h.id;
