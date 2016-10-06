# Inclure des ressources liées dans les résultats

**Attention : Cette fonctionnalité n'a pas encore été implémentée sur les données des collections (Les relations entre les collections ne sont pas opérationnelles).**

## Le paramètre "include"

Tel que défini dans le cahier des charges du standard JSONAPI, le paramètre "include" est réservé aux opérations d'inclusion des relations dans les résultats d'une requête.

## Les relations entre les ressources

Les relations entre les ressources sont définies dans les champs `relationships` :

        {
          "type": "services",
          "id": "ID_SERVICE",
          "attributes": {
            ...
          },
          "relationships": {
            "collections": {
              "links": {
                "self": "/api/v1/services/ID_SERVICE/relationships/collections"
              }
            }
          }
        }

Ici, on observe qu'une ressource de type "services" peut être liée à une ou plusieurs ressources de type "collections".

Pour requêter les ressources liées de manière classique, utilisez la route indiquée dans le champs `links.self`.

Vous pouvez obtenir un échantillon de ces ressources liées en utilisant le principe d'inclusion dans vos requêtes initiales.

## Paramétrer une inclusion

Pour requêter une inclusion, spécifiez le paramètre `include` avec une valeur correspondant au type de la donnée liée.

Exemple :

        ?include=collections

L'échantillon obtenu est limité à 25 objets, il se matérialise sous deux formes dans la réponse :

- Un champ `data` est ajouté au champ `relationships` de la ressource initiale, il contient les références des ressources liés uniquement ;
- Un champ `included` est ajouté à la raçine de la réponse, il contient un tableau de ressources.

        {
            "data": {
                "type": "services",
                "id": "ID_SERVICE",
                "attributes": {
                    ...
                },
                "relationships": {
                    "collections": {
                        "links": {
                            "self": "/api/v1/services/ID_SERVICE/relationships/collections"
                        },
                        "data": [
                            {"type": "collections", "id": "ID_COLLECTION_1"},
                            {"type": "collections", "id": "ID_COLLECTION_2"}
                        ]
                    }
                }
            },
            included: [
                {
                    "type": "collections",
                    "id": "ID_COLLECTION_1",
                    "attributes": {
                        ...
                    },
                    "relationships": {
                        ...
                    }
                },
                {
                    "type": "collections",
                    "id": "ID_COLLECTION_2",
                    "attributes": {
                        ...
                    },
                    "relationships": {
                        ...
                    }
                }
            ]
        }

## Paramétrer une inclusion multiple

Une ressource peut être liée à plusieurs autres types de ressources, comme dans l'exemple ci-dessous :

        {
          "type": "collections",
          "id": "ID_COLLECTION",
          "attributes": {
            ...
          },
          "relationships": {
            "champs": {
              "links": {
                "self": "/api/v1/collections/ID_COLLECTION/relationships/champs"
              }
            },
            "services": {
              "links": {
                "self": "/api/v1/collections/ID_COLLECTION/relationships/services"
              }
            }
          }
        }

On observe qu'une ressource de type "collections" est liée à deux types de ressources, "champs" et "services".

Pour inclure ces deux types de ressources, spécifiez-les en les séparant par des virgules (`,`) :

        ?include=services,champs

Des échantillons de 25 objets maximum par type de ressource seront inclus dans le champs `included`.