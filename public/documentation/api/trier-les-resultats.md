# Trier les résultats

## Le paramètre "sort"

Tel que défini dans le cahier des charges du standard JSONAPI, le paramètre "sort" est réservé aux opérations de tri des résultats d'une requête.

Le standard JSONAPI ne définit pas de stratégie commune aux API, c'est pourquoi la Plate-forme vous propose sa propre stratégie décrite dans le document ici présent.

## La stratégie de tri

La stratégie de tri de la Plate-forme est régie par les règles suivantes :

- Le tri par défaut est ascendant *+*;
- trier en fonction d'un champ invalide génère une erreur **400 Bad Request** accompagné du message **`invalid_sort`** ;

## Les différents tris

Le paramètre **`sort`** est une clés comprenant une ou plusieur valeur séparé par une virgule.

Une valeur correspond au nom du champ et peut être précédé d'un opérateur *+* ou *-*.

Par exemple, si vous souhaitez trier les résultats dans l'ordre acendant en fonction de la valeur du champ `lastname`, vous devez ajouter la valeur `lastname`:

        ?sort=lastname

Par défaut, le tri sera ascendant. On traduira ainsi l'exemple précédent par "Je requête les résultats dans l'ordre acendant en fonction du champ `lastname`".

Si vous souhaitez trier les résultats dans l'ordre descendant en fonction de la valeur du champ `firstname`, vous devez ajouter la valeur `firstname` précédé de l'operateur *-*:

        ?sort=-firstname

le tri sera descendant. On traduira ainsi l'exemple précédent par "Je requête les résultats dans l'ordre descendant en fonction du champ `firstname`".

Pour trier en fonction de plusieurs champs, ajoutez simplement des valeurs supplémentaires:

        ?sort=lastname,-firstname

Par défaut, le tri sera ascendant. On traduira ainsi l'exemple par "Je requête les résultats dans l'ordre acendant en fonction du champ `lastname` et descendant en fonction du champ `firstname`".

Cette exemple correspond exactement a l exemple ci-dessus

        ?sort=+lastname,-firstname

Remarquez une chose :
Le tri se fera dans un premier temps en fonction de la première valeur, puis sur la suivante, puis sur celle d'apres, etc.
