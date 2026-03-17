# Pipeline ETL & Dashboard : Transactions Immobilières de Montréal (2023-2024)

## Aperçu du Projet
Ce projet de bout en bout illustre l'extraction, le nettoyage complexe et la visualisation des données ouvertes de la Ville de Montréal concernant les acquisitions et ventes immobilières. 
L'objectif principal était de transformer des fichiers CSV bruts, comportant des erreurs de structure et d'encodage majeures, en un tableau de bord analytique interactif et fiable pour l'aide à la décision.

## Techniques utilisées
* **Base de données & ETL :** MySQL (Vues, query)
* **Visualisation (BI) :** Power BI Desktop
* **Langage :** SQL (`UNION ALL`, `CASE WHEN`, `REGEXP`, `REPLACE`, manipulations UTF-8)

## Les Défis Techniques (Data Cleaning)
Les données publiques ont été prises sur le site donnees.montreal.ca : https://donnees.montreal.ca/dataset/liste-des-transactions-immobilieres. Ces données présentent souvent des incohérences. Ce projet a nécessité la résolution de trois problèmes majeurs via SQL :
1. **Décalage structurel des colonnes :** Des virgules non échappées dans les noms de contractants divisaient les données sur plusieurs colonnes. Résolu via une logique conditionnelle (`CASE WHEN ... REGEXP`).
2. **Formats monétaires incohérents :** * **2023 :** Format francophone avec espaces insécables (`1 630 000,00 $`). Traité en identifiant et supprimant l'octet UTF-8 de l'espace insécable (`UNHEX('C2A0')`).
   * **2024 :** Format comptable anglophone (`$1,572,000`). Traité dynamiquement avec détection de format via `LIKE '$%'`.
3. **Erreurs d'encodage :** Correction des caractères corrompus (ex: `Ã©` -> `é`, `ÃŽ` -> `Î`) via des fonctions `REPLACE` imbriquées et ordonnées de manière stratégique (de la chaîne la plus longue à la plus courte).

## Architecture des Données
L'approche modulaire a été privilégiée pour garantir la lisibilité et la maintenabilité du code SQL :
* `vue_stg_2023` : Staging et formatage spécifique aux données de l'année 2023.
* `vue_stg_2024` : Staging et formatage spécifique aux données de l'année 2024.
* `vue_transac_mtl_clean` : Fusion des tables propres (`UNION ALL`) et ultime nettoyage des caractères (UTF-8).

## Tableau de Bord (Power BI)
![Capture d'écran du Dashboard Power BI](demo_mtlpro20232024.gif)


Le tableau de bord interactif permet de :
* Filtrer les montants globaux par année.
* Analyser la répartition financière par arrondissement (Histogramme).
* Visualiser la proportion des montants par type de transaction (Treemap).

## Auteur
**Abdoul Karim Ouattara**
* LinkedIn : [linkedin.com/in/abdoulkaouatt](https://linkedin.com/in/abdoulkaouatt)
* GitHub : [github.com/KarimOuatt](https://github.com/KarimOuatt)
* Email : trkarimouatt@gmail.com
