-- ============================================================
-- analysis.sql — Requêtes d'analyse du Habit Tracker
-- Extraire des insights utiles pour les utilisateurs
-- ============================================================

PRAGMA foreign_keys = ON;

-- ============================================================
-- A. VUE GLOBALE — Tableau de bord
-- ============================================================

-- A1. Taux de complétion global par utilisateur
-- Combien de % des habitudes prévues ont été réalisées ?
SELECT
    u.nom                                                         AS utilisateur,
    COUNT(*)                                                      AS jours_enregistres,
    SUM(s.fait)                                                   AS jours_realises,
    ROUND(SUM(s.fait) * 100.0 / COUNT(*), 1)                     AS taux_completion_pct
FROM suivi s
JOIN utilisateurs u ON s.utilisateur_id = u.id
GROUP BY u.id, u.nom
ORDER BY taux_completion_pct DESC;

-- A2. Nombre de jours actifs (au moins 1 habitude réalisée) par utilisateur
SELECT
    u.nom                                                         AS utilisateur,
    COUNT(DISTINCT s.date)                                        AS jours_avec_au_moins_une_habitude
FROM suivi s
JOIN utilisateurs u ON s.utilisateur_id = u.id
WHERE s.fait = 1
GROUP BY u.id, u.nom
ORDER BY jours_avec_au_moins_une_habitude DESC;

-- ============================================================
-- B. ANALYSE PAR HABITUDE
-- ============================================================

-- B1. Habitude la plus réalisée dans toute la base
SELECT
    h.nom                                                         AS habitude,
    COUNT(*)                                                      AS fois_realisee,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM suivi WHERE habitude_id = h.id), 1) AS taux_global_pct
FROM suivi s
JOIN habitudes h ON s.habitude_id = h.id
WHERE s.fait = 1
GROUP BY h.id, h.nom
ORDER BY fois_realisee DESC;

-- B2. Habitude la plus difficile (le plus faible taux de réalisation)
SELECT
    h.nom                                                         AS habitude,
    COUNT(*)                                                      AS entrees_total,
    SUM(s.fait)                                                   AS fois_realisee,
    ROUND(SUM(s.fait) * 100.0 / COUNT(*), 1)                     AS taux_completion_pct
FROM suivi s
JOIN habitudes h ON s.habitude_id = h.id
GROUP BY h.id, h.nom
ORDER BY taux_completion_pct ASC;

-- ============================================================
-- C. ANALYSE PAR UTILISATEUR
-- ============================================================

-- C1. Fiche d'un utilisateur — détail par habitude
-- Remplacer 'Alice' par le nom souhaité
SELECT
    h.nom                                                         AS habitude,
    COUNT(*)                                                      AS jours_suivis,
    SUM(s.fait)                                                   AS jours_realises,
    ROUND(SUM(s.fait) * 100.0 / COUNT(*), 1)                     AS taux_pct
FROM suivi s
JOIN habitudes    h ON s.habitude_id    = h.id
JOIN utilisateurs u ON s.utilisateur_id = u.id
WHERE u.nom = 'Alice'
GROUP BY h.id, h.nom
ORDER BY taux_pct DESC;

-- C2. Activité jour par jour d'un utilisateur (vue calendrier)
SELECT
    s.date,
    h.nom                                                         AS habitude,
    CASE s.fait WHEN 1 THEN '✓' ELSE '✗' END                    AS statut,
    s.note
FROM suivi s
JOIN habitudes    h ON s.habitude_id    = h.id
JOIN utilisateurs u ON s.utilisateur_id = u.id
WHERE u.nom = 'Alice'
ORDER BY s.date, h.nom;

-- ============================================================
-- D. ANALYSE TEMPORELLE
-- ============================================================

-- D1. Meilleur jour de la semaine (tous utilisateurs confondus)
-- 0 = dimanche, 1 = lundi, … 6 = samedi dans SQLite
SELECT
    CASE CAST(strftime('%w', date) AS INTEGER)
        WHEN 0 THEN 'Dimanche'
        WHEN 1 THEN 'Lundi'
        WHEN 2 THEN 'Mardi'
        WHEN 3 THEN 'Mercredi'
        WHEN 4 THEN 'Jeudi'
        WHEN 5 THEN 'Vendredi'
        WHEN 6 THEN 'Samedi'
    END                                                           AS jour,
    COUNT(*)                                                      AS entrees,
    SUM(fait)                                                     AS realisations,
    ROUND(SUM(fait) * 100.0 / COUNT(*), 1)                       AS taux_pct
FROM suivi
GROUP BY strftime('%w', date)
ORDER BY taux_pct DESC;

-- D2. Progression semaine par semaine par utilisateur
SELECT
    u.nom                                                         AS utilisateur,
    strftime('%Y-W%W', s.date)                                   AS semaine,
    COUNT(*)                                                      AS entrees,
    SUM(s.fait)                                                   AS realisations,
    ROUND(SUM(s.fait) * 100.0 / COUNT(*), 1)                     AS taux_pct
FROM suivi s
JOIN utilisateurs u ON s.utilisateur_id = u.id
GROUP BY u.id, semaine
ORDER BY u.nom, semaine;

-- ============================================================
-- E. UTILISATEUR LE PLUS RÉGULIER
-- ============================================================

-- E1. Classement final par taux de complétion
SELECT
    u.nom                                                         AS utilisateur,
    ROUND(SUM(s.fait) * 100.0 / COUNT(*), 1)                     AS score_regularite_pct
FROM suivi s
JOIN utilisateurs u ON s.utilisateur_id = u.id
GROUP BY u.id, u.nom
ORDER BY score_regularite_pct DESC
LIMIT 1;

-- ============================================================
-- F. UTILISATION DE LA VUE — vue_suivi_complet
-- ============================================================

-- F1. Aperçu rapide de toutes les données via la vue créée dans schema.sql
SELECT *
FROM vue_suivi_complet
ORDER BY date DESC, utilisateur, habitude
LIMIT 20;
