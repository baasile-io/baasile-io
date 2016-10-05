# Paginer les résultats

## Le paramètre "page"

Tel que défini dans le cahier des charges du standard JSONAPI, le paramètre "page" est réservé aux opérations de pagination des résultats d'une requête.

Le standard JSONAPI ne définit pas de stratégie commune aux API, c'est pourquoi la Plate-forme vous propose sa propre stratégie décrite dans le document ici présent.

## La stratégie de pagination

La Plate-forme a choisi d'implémenter une stratégie de pagination de type **offset-based**.
 
Le début d'une page se définit donc par l'index du premier objet.

Ainsi, si le nombre d'éléments par page est de 25, l'index 0 correspond à la première page et l'index 25 correspond à la seconde page, et ainsi de suite jusqu'à la dernière page.

Cependant, pour des raisons de compatibilité, la Plate-forme accepte les requêtes se basant sur une stratégie de pagination de type **page-based**. Référez-vous à la section "Compatibilité avec la stratégie 'page-based'".

## Nombre d'éléments par page

Le nombre d'éléments par page est de 25 par défaut.

Spécifiez le paramètre `page[limit]` avec une valeur comprise en 1 et 200.

Exemple :

        ?page[limit]=100

## Numéro de page

Le numéro de page par défaut est la première page.

Changez 