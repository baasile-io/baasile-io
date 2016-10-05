# Filtrer les résultats

Note 1 : Cette fonctionnalité n'est actuellement implémentée que sur les champs des dollections de données.  
Note 2 : Les parties barrées (~~barrées~~) ne sont pas encore fonctionnelles. 

## Le paramètre "filter"

Tel que défini dans le cahier des charges du standard JSONAPI, le paramètre "filter" est réservé aux opérations de filtrage des résultats d'une requête.

Le standard JSONAPI ne définit pas de stratégie commune aux API, c'est pourquoi la Plate-forme vous propose sa propre stratégie décrite dans le document ici présent.

## La stratégie de filtrage

La stratégie de filtrage de la Plate-forme est régie par les règles suivantes :

- L'opérateur de comparaison par défaut est l'*ÉGALITÉ STRICTE* ;
- L'opérateur logique par défaut est un *ET* ;
- ~~Filtrer en fonction d'un champ invalide génère une erreur **400 Bad Request** accompagné du message **`invalid_filter`** ;~~
- Filtrer avec des valeurs dont le type ne correspond pas au champ génère une erreur **400 Bad Request** accompagné du message **`invalid_filter`**.

## Ajouter des filtres

Le paramètre **`filter`** est un tableau de clés-valeurs à dimensions multiples.

Une clé peut correspondre soit au nom du champ sur lequel appliquer le filtre, soit à un opérateur de logique ou de comparaison.

Par exemple, si vous souhaitez filtrer les résultats en fonction de la valeur du champ `lastname`, vous devez ajouter la clé `lastname` au tableau et lui spécifier une valeur :

        ?filter[lastname]=Mercier

Par défaut, l'opérateur de comparaison est l'*ÉGALITÉ STRICTE*. On traduira ainsi l'exemple précédent par "Je requête les résultats dont le champ `lastname` est strictement égal à `Mercier`".

Pour filtrer en fonction de plusieurs champs, ajoutez simplement des clés supplémentaires au tableau :

        ?filter[lastname]=Mercier&filter[firstname]=Eric

Par défaut, l'opérateur logique entre les filtres est l'opérateur *ET*. On traduira ainsi l'exemple par "Je requête les résultats dont les champs `lastname` et `firstname` sont strictement égaux aux valeurs respectives `Mercier` et `Eric`". Référez-vous à la section "**Les opérateurs logiques**" pour changer de comportement.

Pour filtrer en fonction de valeurs multiples sur un même champ, dupliquez simplement la clé :

        ?filter[$or][lastname]=Mercier&filter[$or][lastname]=Ratinger

Remarquez l'utilisation de l'opérateur de logique *OU* à la raçine du tableau. On traduira ainsi l'exemple par "Je requête les résultats dont le champs `lastname` est strictement égal à l'une des deux valeurs `Mercier` et `Ratinger`".

Enfin, pour filtrer en fonction de critères différents de l'*ÉGALITÉ STRICTE*, référez-vous à la section "**Les opérateurs de comparaison**".

## Les opérateurs de comparaison

Pour utiliser des opérateurs de comparaison différents de l'*ÉGALITÉ STRICTE*, l'opérateur par défaut, vous devez utiliser un tableau de clés-valeurs en tant que valeur du filtre, dont les clés sont des opérateurs de comparaison. Les opérateurs commencent par le caractère dollar (`$`).

Vous pouvez utiliser plusieurs opérateurs pour un même champ, ou les inclure dans des structures conditionnelles plus complexes avec des opérateurs de logique (référez-vous à la section "**Exemples de filtrage avancé**").

#### $eq - ÉGALITÉ STRICTE (défaut)

        ?filter[score][$eq]=100

"Je requête les résultats dont le champ `score` est strictement égal à 100"

Si vous spécifiez un tableau en tant que valeur de l'opérateur d'*ÉGALITÉ STRICTE* (`$eq`), ce dernier sera substitué par l'opérateur d'*INCLUSION* (`$in`). Ainsi, les deux exemples suivants ont le même effet :

        ?filter[score][$eq]=21&filter[score][$eq]=42
        ?filter[score][$in]=21&filter[score][$in]=42

#### $ne - INÉGALITÉ STRICTE

        ?filter[score][$ne]=0

"Je requête les résultats dont le champ `score` n'est strictement pas égal à 0"

Si vous spécifiez un tableau en tant que valeur de l'opérateur d'*INÉGALITÉ STRICTE* (`$ne`), ce dernier sera substitué par l'opérateur d'*EXCLUSION* (`$nin`). Ainsi, les deux exemples suivants ont le même effet :

        ?filter[score][$ne]=21&filter[score][$ne]=42
        ?filter[score][$nin]=21&filter[score][$nin]=42

#### $gt - SUPÉRIORITÉ STRICTE

        ?filter[score][$gt]=50

"Je requête les résultats dont le champ `score` est strictement plus grand que 50"

#### $gte - SUPÉRIORITÉ LARGE

        ?filter[score][$gte]=50

"Je requête les résultats dont le champ `score` est plus grand que ou égal à 50"

#### $lt - INFÉRIORITÉ STRICTE

        ?filter[score][$lt]=70

"Je requête les résultats dont le champ `score` est strictement plus petit que 70"

#### $lte - INFÉRIORITÉ LARGE

        ?filter[score][$lte]=70

"Je requête les résultats dont le champ `score` est plus petit que ou égal à 70"

#### $in - INCLUSION

L'opérateur d'*INCLUSION* requiert un tableau de valeurs. Il permet de réaliser une opération logique *OR* avec une comparaison d'*ÉGALITÉ STRICTE*.

        ?filter[county][$in]=750017&filter[county][$in]=750018

"Je requête les résultats dont le champ `county` est strictement égal au 17ème ou au 18ème arrondissement de Paris"

#### $nin - EXCLUSION

L'opérateur d'*EXCLUSION* requiert un tableau de valeurs. Il permet de réaliser une opération logique *NON-OU* avec une comparaison d'*ÉGALITÉ STRICTE*.

        ?filter[county][$nin]=750017&filter[county][$nin]=750018

"Je requête les résultats dont le champ `county` n'est strictement égal ni au 17ème, ni au 18ème arrondissement"

#### ~~$regex - EXPRESSION RÉGULIÈRE~~

~~L'opérateur d'*EXPRESSION RÉGULIÈRE* requiert une chaîne de caractères compatible avec la norme des expressions régulière de Perl (PCRE version 8.38 - [http://www.pcre.org/](http://www.pcre.org/)).~~

~~Vous pouvez paramétrer l'opérateur d'*EXPRESSION RÉGULIÈRE* en spécifiant une seconde clé `$options` (valeurs possible : `i`, `m`, `x`, `s`).~~

        ?filter[firstname][$regex]=^Jean

~~"Je requête les résultats dont le champ `firstname` est strictement égal ou commence par `Jean`."~~

        ?filter[firstname][$regex]=^Jean&filter[firstname][$options]=i

~~"Je requête les résultats dont le champ `firstname` est égal ou commence par `Jean`, peu importe la casse (`Jean`, `JEAN`, `jean`, `jEAN`, etc).~~

        ?filter[county][$regex]=^3[04][0-9]{3}$

~~"Je requête les résultats dont le champ `county` correspond à un code postal de l'Hérault ou du Gard, commençant par 30 ou 34"~~

## Les opérateurs logiques

#### $and - ET

L'opérateur logique *ET* permet de filtrer les résultats en fonction d'une liste de filtres dont l'intégralité doit être positif.

        ?filter[score][$and][$gt]=75&filter[score][$and][$lte]=100

"Je requête les résultats dont le champ `score` est strictement supérieur à 75 et inférieur ou égal à 100"

#### $or - OU

L'opérateur logique *OU* permet de filtrer les résultats en fonction d'une liste de filtres dont l'un au moins doit être positif.

        ?filter[score][$or][$eq]=0&filter[score][$or][$eq]=100

"Je requête les résultats dont le champ `score` est strictement égal à 0 ou strictement égal à 100"

#### ~~$not - NON~~

~~L'opérateur logique *NON* permet d'inverser le résultat d'un seul et unique filtre.~~

        ?filter[$not][lastname]=Mercier

~~"Je requête les résultats dont les champs 'lastname' n'est pas strictement égal à 'Mercier'"~~

#### ~~$nor - NON-OU~~

~~L'opérateur logique *NON-OU* est l'équivalent d'un opérateur *ET* inversé. L'exemple présenté ci-dessous a le même effet que celui présenté pour l'opérateur *ET*.~~

        ?filter[score][$nor][$lte]=75&filter[score][$nor][$gt]=100

~~"Je requête les résultats dont le champ `score` n'est pas inférieur ou égal à 75 et n'est pas strictement plus grand que 100"~~

## Filtrer une collection en fonction des champs personnalisés

Les champs personnalisés d'une collection sont définis par un service. Ils doivent être préfixés par la chaîne de caractères **`data`** suivie d'un point (`.`).

Cela évite tout conflit avec les champs standards que les données possèdent par défaut, tels que `created_at` et `updated_at`.

Par exemple, si vous souhaitez filtrer les résultats en fonction d'un champ personnalisé `county` défini dans une collection d'un service, utilisez la clé `data.county` :

        ?filter[data.county]=34000

## ~~Filtrer une collection sur tous les champs en même temps~~

#### ~~$text - RECHERCHE PAR MOT~~

~~[TODO]~~

## Exemples de filtrage avancé

### Un formulaire de recherche de formations

Supposons que votre service mette à disposition de ses utilisateurs un formulaire de recherche de formations.

Les critères de ce formulaire sont les suivants :

- Code NAF ou mots-clés (champ libre)
- Ville ou code postal (champ libre)
- Fourchette de durée (deux champs avec un nombre d'heures)
- Note minimum (un chiffre de 1 à 5)

La collection de données comporte les champs suivants :

- `code_naf`
- `intitule`
- `description`
- `ville`
- `code_postal`
- `nb_heures`
- `note`

Admettons maintenant que tous les champs du formulaire sont renseignés avec les valeurs suivantes :

- Code NAF ou mots-clés : "informatique développement expert"
- Ville ou code postal : "Montpellier"
- Fourchette de durée : "Entre 35 et 70 heures"
- Note minimum : "3"

On souhaite alors construire la structure conditionnelle suivante :

        (code_naf)
            STRICTEMENT ÉGAL À "informatique"
                OU STRICTEMENT ÉGAL À "développement"
                OU STRICTEMENT ÉGAL À "expert"
            OU (intitule)
                CONTIENT "informatique"
                    OU CONTIENT "développement"
                    OU CONTIENT "expert"
            OU (description)
                CONTIENT "informatique"
                    OU CONTIENT "développement"
                    OU CONTIENT "expert"
        ET (ville)
            CONTIENT "Montpellier"
            OU (code_postal)
                STRICTEMENT ÉGAL À "Montpellier"
        ET (nb_heures)
            PLUS GRAND QUE OU ÉGAL À "35"
                ET PLUS PETIT QUE OU ÉGAL À "70"
        ET (note)
            PLUS GRAND QUE OU ÉGAL À "3"

Appliquons maintenant cette structure conditionnelle à la stratégie de filtrage de la Plate-forme :

        ?filter[0][$or][data.code_naf][$in]=informatique
        &filter[0][$or][data.code_naf][$in]=développement
        &filter[0][$or][data.code_naf][$in]=expert
        &filter[0][$or][data.intitule][$regex]=informatique
        &filter[0][$or][data.intitule][$regex]=développement
        &filter[0][$or][data.intitule][$regex]=expert
        &filter[0][$or][data.description][$regex]=informatique
        &filter[0][$or][data.description][$regex]=développement
        &filter[0][$or][data.description][$regex]=expert
        &filter[1][$or][data.ville][$regex]=Montpellier
        &filter[1][$or][data.code_postal][$eq]=Montpellier
        &filter[2][data.nb_heures][$gte]=35
        &filter[2][data.nb_heures][$lte]=70
        &filter[3][data.note][$gte]=3

Remarquez la construction du tableau de base à 4 éléments. Cela permet de parenthéser les filtres pour former plusieurs blocs de conditions.
