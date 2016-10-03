## Documentation / Équipe API
 ---

# Créer une collection de données identifiées (avec OpenId)


*Pré-requis : La plateforme sur laquelle cette documentation est accessible doit être configurée pour communiquer avec un fournisseur d’identité implémentant le protocole OpenIdConnect (tel que FranceConnect) et disposant d’une route de vérification de jeton de connexion (contactez un administrateur de la plateforme si ce n’est pas le cas).*


```
La plateforme recommande l’utilisation du protocole OpenIdConnect afin de gérer les aspects du stockage de données identifiées (Authentification de l’utilisateur et autorisation d’accès à ses données).
```


2 niveaux d’implémentation du protocole OpenIdConnect sont proposés :

- Lecture et écriture des données de la collection

- Lecture seulement des données de la collection


Si vous choisissez l’implémentation “Lecture et écriture”, il n’est possible de créer, modifier, supprimer et accéder aux données identifiées de la collection uniquement dans le cas où l’utilisateur est connecté et a autorisé l’action via le fournisseur d’identité configuré sur la plateforme. En somme, toute requête nécessite la présence d’un jeton de connexion OpenId valide.



Si vous choisissez l’implémentation “Lecture seulement”, seuls les services non propriétaires de la collection ou ne possédant pas de droit d’écriture sont restreints par ce protocole pour requêter sur la collection. Le propriétaire de la collection peut créer, modifier, supprimer et accéder aux données identifiées sans jeton de connexion OpenId, à condition de respecter le standard de génération des ID décrit au chapitre “Générer manuellement un ID pour une donnée identifiée“. Le but étant de conserver la cohérence des données.

### Configurer une collection de données identifiées avec jeton de connexion OpenId

* À la création ou à la modification d’une collection, cochez la case “Données identifiées”.



* Puis sélectionnez le mode d’implémentation du protocole OpenIdConnect souhaité :

    - “Lecture seulement”
    - Ou “Lecture et écriture”


* Enregistrez les modifications.


```
Attention : assurez-vous des paramètres de partage de la collection afin qu’elle soit compatible avec la politique de confidentialité des données identifiées de votre service, et assurez-vous que les services consomateur de la collection en ont préalablement été informé et que toutes les dispositions de mises à jour ont éte prises.
```
### Expiration des données identifiées

Afin de se mettre en conformité avec la législation du pays hébergeant la plateforme, il est conseillé d’activer l’expiration sur les collections stockant des données identifiées.



Rendez-vous sur le dashboard de la collection, “Modifier”, puis cochez la case “Expiration des données” et renseignez une durée de stockage. Sauvegardez les modifications.


```
Attention : les données enregistrées antérieurement à la durée de stockage ou n’ayant subi aucune modification durant cette période seront immédiatement supprimées.
```
### Générer manuellement un ID pour une donnée identifiée

Afin de conserver la cohérence des données d’une collection de type “données identifiées”, un service ayant accès à cette collection sans jeton de connexion OpenId valide (par exemple le propriétaire de la collection) doit respecter le standard décrit ci-dessous pour générer les ID.



Il est tout à fait possible de ne pas respecter ce standard, mais cela aurait pour conséquence de rendre incompatible les requêtes générées par les autres services via un jeton de connexion OpenIdConnect.



Voici le protocole standard utilisé sur cette plateforme pour générer un ID de type “donnée identifiée” :

- Concaténation dans une chaîne de caractère, dans cet ordre, des champs du profil de l’utilisateur (userinfo) : “sub”, “given_name”, “family_name”, “birthdate”, “gender” et “email”.
- Remplacement des caractères majuscules en leur équivalent minuscule
- Hachage de la chaîne de caractère obtenue avec l'algorithme “RS256” (sha-256)
- Conversion en hexadécimal


Exemples de code dans différents langages :

[PHP][JavaScript]

