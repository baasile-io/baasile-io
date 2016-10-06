# Paginer les résultats

## Le paramètre "page"

Tel que défini dans le cahier des charges du standard JSONAPI, le paramètre "page" est réservé aux opérations de pagination des résultats d'une requête.

Le standard JSONAPI ne définit pas de stratégie commune aux API, c'est pourquoi la Plate-forme vous propose sa propre stratégie décrite dans le document ici présent.

## La stratégie de pagination

La Plate-forme a choisi d'implémenter une stratégie de pagination de type **offset-based**.
 
Le début d'une page se définit par un index, celui du premier objet souhaité dans les résultats. 

Ainsi, si le nombre d'éléments par page est de 25, l'index 0 correspond à la première page et l'index 25 correspond à la seconde, et ainsi de suite jusqu'à la dernière page.

Cependant, pour des raisons de compatibilité, la Plate-forme accepte les requêtes se basant sur une stratégie de pagination de type **page-based**. Référez-vous à la section "Compatibilité".

## Nombre d'éléments par page

Le nombre d'éléments par page est de 25 par défaut.

Spécifiez le paramètre `page[limit]` avec une valeur comprise en 1 et 200.

Exemple :

        ?page[limit]=100

## Position du curseur

Tel que spécifié dans la stratégie de pagination plus haut, le numéro de page est défini par l'index du premier objet requêté.

On parlera de "position du curseur" dans les résultats.

Spécifiez le paramètre `page[offset]` avec une valeur comprise entre 0 (première page) et le nombre maximum de ressources auquel il faut soustraire une unité (Par exemple 42 quand il y a 43 objets).

Exemple :

        ?page[limit]=25&page[offset]=25

## Compatibilité

Vous pouvez choisir de naviguer entre les pages via la notion de numéro de page.

Cependant, les méta-données obtenues dans les réponses de l'API (les champs `links` et `meta`) se baseront toujours sur la notion de "position du curseur".

Spécifiez le paramètre `page[number]` avec une valeur comprise en 1 et le nombre de pages indiqué dans les méta-données (`total_pages`).

Info : Vous pouvez utiliser le paramètre `page[size]` en remplacement de `page[limit]`.

Les exemples ci-dessous ont le même effet :

        ?page[number]=3&page[size]=25
        ?page[offset]=50&page[limit]=25

Info : Les paramètres `page[limit]` et `page[offset]` ont respectivement la priorité sur les paramètres `page[size]` et `page[number]`.
