-- Gérer le format des montants
CREATE OR REPLACE VIEW vue_stg_2023 AS
SELECT 
    categorie AS cat,
    
    -- 1. Réparation des décalages (Noms et Arrondissements)
    CASE 
        WHEN montant_transaction REGEXP '[0-9]' AND arrondissement LIKE '%$%' THEN CONCAT(`nom_contractantÂ`, ', ', description) 
        ELSE `nom_contractantÂ` 
    END AS contractant,
    
    CASE 
        WHEN arrondissement LIKE '%$%' THEN `numero_decision-resolution` 
        ELSE arrondissement 
    END AS arrondissement,
    
    -- Nettoyage UTF-8 (UNHEX)
    CAST(
        REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            CASE 
                WHEN montant_transaction LIKE '%Approuver%' THEN arrondissement 
                ELSE montant_transaction 
            END, 
        'Â', ''), UNHEX('C2A0'), ''), ' ', ''), '$', ''), ',', '.') 
    AS DECIMAL(15,2)) AS montant,
    
    2023 AS annee
FROM `montreal_immobilier`.`liste_des_transactions_2023`;

SELECT *
FROM vue_stg_2023;

CREATE OR REPLACE VIEW vue_stg_2024 AS
SELECT 
    `CatÃ©gorie` AS cat,
    -- Réparation des décalages
    CASE WHEN montant_transaction REGEXP '[0-9]' AND arrondissement LIKE '%$%' THEN CONCAT(cocontractant, ', ', Description) ELSE cocontractant END AS contractant,
    CASE WHEN arrondissement LIKE '%$%' THEN `numero_decision-resolution` ELSE arrondissement END AS arrondissement,
    
    -- Formatage 2024 : On enlève le $ et la virgule des milliers
    CAST(REPLACE(REPLACE(
        CASE WHEN montant_transaction LIKE '%Approuver%' THEN arrondissement ELSE montant_transaction END, 
    '$', ''), ',', '') AS DECIMAL(15,2)) AS montant,
    
    2024 AS annee
FROM `montreal_immobilier`.`liste_des_transactions_2024`;

SELECT *
FROM
	vue_stg_2024;

CREATE OR REPLACE VIEW vue_transacs_mtl_clean AS
SELECT 
    -- REPLACE pour les autres colonnes mal formattées
	REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(cat, 'Ã©', 'é'), 'Ã¨', 'è'), 'â€™', "'"), 'Ã‰', 'É'), 'Å“u', 'œ'), 'Ã¢', 'â'), 'ÃŽ', 'Î'), 'Ã', 'à') AS categorie,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(contractant, 'Ã©', 'é'), 'Ã¨', 'è'), 'â€™', "'"), 'Ã‰', 'É'), 'Å“u', 'œ'), 'Ã¢', 'â'), 'ÃŽ', 'Î'), 'Ã', 'à') AS nom_contractant,
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(arrondissement, 'Ã©', 'é'), 'Ã¨', 'è'), 'â€™', "'"), 'Ã‰', 'É'), 'Å“u', 'œ'), 'Ã¢', 'â'), 'ÃŽ', 'Î'), 'Ã', 'à') AS arrondissement,
    montant,
    annee
FROM (
    SELECT * FROM vue_stg_2023
    UNION ALL
    SELECT * FROM vue_stg_2024
) AS fusion_propre
-- On retire les potentiel NULL et valeurs de montant négative
WHERE montant IS NOT NULL AND montant > 0;

SELECT *
FROM  vue_transacs_mtl_clean;