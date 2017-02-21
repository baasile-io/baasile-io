I18n.translations || (I18n.translations = {});
I18n.translations["fr"] = I18n.extend((I18n.translations["fr"] || {}), {"actions":{"activate":"Activer","add_admin":"Ajouter un administrateur","admin_list":"liste des administrateurs","back":"\u003c\u003c Retour","change_password":"Changer de mot de passe","configure":"Configurer","deactivate":"Désactiver","destroy":"Supprimer","edit":"Modifier","edit_account":"Modifier mon compte","infos":"Infos","new":"Créer","resend_confirmation_instructions":"Renvoyer les instructions de confirmation par E-Mail","reset_password":"Recevoir les instructions pour changer de mot de passe","reset_unlock_instructions":"Renvoyer les instructions pour activer mon compte","return":"Retour","save":"Sauvegarder","save_in_progress":"Enregistrement en cours...","send_welcome_instructions":"Envoyer les instructions de bienvenue par E-Mail","set_admin":"Ajouter les droits admin","sign_in":"Se connecter","sign_out":"Se déconnecter","sign_up":"S'inscrire","signin_in":"Connexion...","signin_up":"Inscription..","success":{"created":"%{resource} a été créé avec succès","destroyed":"%{resource} a été supprimé avec succès","updated":"%{resource} a été mis à jour avec succès"},"unset_admin":"Enlever les droits admin"},"activerecord":{"attributes":{"company":{"name":"Nom"},"contact_detail":{"address_line1":"Adresse","address_line2":"Adresse (ligne 2)","address_line3":"Adresse (ligne 3)","city":"Ville","country":"Pays","name":"Nom d'adresse","phone":"Numéro de téléphone","siret":"Numéro de SIRET","zip":"Code postal"},"identifier":{"client_id":"Clé publique","client_secret":"Clé secrète","encrypted_secret":"Clé secrète cryptée","proxy":"Fonctionnalité","user":"Créateur"},"proxy":{"alias":"Alias","description":"Description","name":"Nom","proxy_parameter":{"authorization_mode":"Mode d'autorisation","authorization_url":"URL d'autorisation","grant_type":"Grant type","hostname":"Domaine","port":"Port","protocol":"Protocole","realm":"realm"},"service":"Service","service_id":"Service","user":"Créateur","user_id":"Créateur"},"proxy_parameter":{"authorization_mode":"Mode d'autorisation","authorization_url":"URL d'autorisation","follow_redirection":"Nombre de redirections maximum","follow_url":"Suivre l'URL","grant_type":"Grant type","hostname":"Domaine","port":"Port","protocol":"Protocole","realm":"realm"},"query_parameter":{"mode":"Mode","name":"Nom"},"route":{"description":"Description","hostname":"Domaine","name":"Nom","port":"Port","protocol":"Protocole","proxy":"Proxy","proxy_id":"Proxy","url":"URL","user":"Créateur","user_id":"Créateur"},"service":{"client_id":"CLIENT_ID","client_secret":"CLIENT_SECRET","company":"Compagnie","company_id":"Compagnie","description":"Description","name":"Nom","public":"Référencer dans le catalogue","service_type":"Type","subdomain":"Identifiant publique","user":"Créateur","user_id":"Créateur","website":"Site Internet"},"user":{"current_password":"Mot de passe actuel","email":"E-Mail","first_name":"Prénom","full_name":"Nom complet","gender":"Civilité","is_active":"Actif ?","last_name":"Nom","password":"Mot de passe","password_confirmation":"Confirmation du mot de passe","phone":"Téléphone"}},"models":{"company":"Compagnie","contact_detail":"Coordonnée","identifier":"Identifiant","proxy":"Fonctionnalité","proxy_parameter":"Paramètres de fonctionnalité","query_parameter":"Paramètre de requête","route":"Route","service":"Service","user":"Utilisateur"},"validations":{"service":{"missing_subdomain":"L'identifiant publique doit être renseigné","subdomain_changed_disallowed":"L'identifiant publique ne peut pas être modifié car le service est actif"}}},"back_office":{"users":{"create":{"title":"Créer un utilisateur"},"edit":{"title":"Modifier"},"index":{"title":"Utilisateurs"},"new":{"title":"Créer un utilisateur"},"permissions":{"title":"Permissions"}}},"companies":{"add_admin":{"title":"Ajouter un administrateur"},"admin_list":{"title":"Liste des administrateurs"},"clients":{"title":"Clients"},"index":{"title":"Compagnies"},"new":{"title":"Créer une nouvelle compagnie"},"startups":{"title":"Startups"}},"config":{"platform_name":"OpenRH"},"devise":{"confirmations":{"confirmed":"Votre adresse E-Mail a bien été confirmée.","confirmed_at":"L'adresse E-Mail a été confirmée le %{date}","email_confirmation":"Confirmation de l'adresse E-Mail","send_instructions":"Vous allez recevoir les instructions nécessaires à la confirmation de votre compte dans quelques minutes.","send_paranoid_instructions":"Si votre e-mail existe dans notre base de données, vous allez bientôt recevoir un e-mail contenant les instructions de confirmation de votre compte.","unconfirmed":"Adresse E-Mail non confirmée"},"failure":{"already_authenticated":"Vous êtes déjà connecté","expired":"Votre compte a été désactivé du fait d'une longue inactivité. Veuillez contacter un administrateur afin de réactiver votre accès.","inactive":"Votre compte n'est pas encore activé.","invalid":"Email ou mot de passe incorrect.","last_attempt":"Vous avez droit à une tentative avant que votre compte ne soit verrouillé.","locked":"Votre compte est verrouillé.","not_found_in_database":"Email ou mot de passe invalide.","session_limited":"Vous avez une session active sur un autre appareil, veuillez vous reconnecter.","timeout":"Votre session est expirée. Veuillez vous reconnecter pour continuer.","unauthenticated":"Vous devez vous connecter ou vous inscrire pour continuer.","unconfirmed":"Vous devez valider votre compte pour continuer."},"invalid_captcha":"Le captcha est invalide","omniauth_callbacks":{"failure":"Nous n'avons pas pu vous authentifier via %{kind} : '%{reason}'.","success":"Authentifié avec succès via %{kind}."},"password_expired":{"change_required":"Votre mot de passe a expiré, veuillez le changer.","show":{"description":"Veuillez changer de mot de passe pour continuer à vous connecter.","title":"Mot de passe expiré"},"updated":"Votre nouveau mot de passe a bien été enregistré."},"passwords":{"no_token":"Vous ne pouvez accéder à cette page sans passer par un e-mail de réinitialisation de mot de passe. Si vous êtes passé par un e-mail de ce type, assurez-vous d'utiliser l'URL complète.","password_restrictions":"Au minimum 6 caractères, 1 majuscule, 1 minuscule et 1 chiffre.","send_instructions":"Vous allez recevoir les instructions de réinitialisation du mot de passe dans quelques instants","send_paranoid_instructions":"Si votre e-mail existe dans notre base de données, vous allez recevoir un lien de réinitialisation par e-mail","updated":"Votre mot de passe a été édité avec succès, vous êtes maintenant connecté","updated_not_active":"Votre mot de passe a été changé avec succès."},"registrations":{"destroyed":"Votre compte a été supprimé avec succès. Nous espérons vous revoir bientôt.","pending_reconfirmation":"Nouvelle adresse E-Mail en attente de confirmation: %{email}","signed_up":"Bienvenue, vous êtes connecté.","signed_up_but_inactive":"Vous êtes bien enregistré. Vous ne pouvez cependant pas vous connecter car votre compte n'est pas encore activé.","signed_up_but_locked":"Vous êtes bien enregistré. Vous ne pouvez cependant pas vous connecter car votre compte est verrouillé.","signed_up_but_unconfirmed":"Un message contenant un lien de confirmation a été envoyé à votre adresse email. Ouvrez ce lien pour activer votre compte.","update_needs_confirmation":"Votre compte a bien été mis à jour mais nous devons vérifier votre nouvelle adresse email. Merci de vérifier vos emails et de cliquer sur le lien de confirmation pour finaliser la validation de votre nouvelle adresse.","updated":"Votre compte a été modifié avec succès."},"sessions":{"already_signed_out":"Déconnecté.","signed_in":"Connecté.","signed_out":"Déconnecté."},"unlocks":{"send_instructions":"Vous allez recevoir les instructions nécessaires au déverrouillage de votre compte dans quelques instants","send_paranoid_instructions":"Si votre compte existe, vous allez bientôt recevoir un email contenant les instructions pour le déverrouiller.","unlocked":"Votre compte a été déverrouillé avec succès, vous êtes maintenant connecté."}},"errors":{"an_error_occured":"Une erreur est survenue","messages":{"already_confirmed":"a déjà été validé(e), veuillez essayer de vous connecter","blank":"doit être renseigné(e)","confirmation_period_expired":"à confirmer dans les %{period}, merci de faire une nouvelle demande","equal_to_current_password":"doit être différent du mot de passe courant","expired":"a expiré, merci d'en faire une nouvelle demande","inclusion":"n'est pas une valeur autorisée","invalid":"est invalide","not_a_number":"doit être numérique","not_found":"n'a pas été trouvé(e)","not_locked":"n'était pas verrouillé(e)","not_saved":{"one":"1 erreur a empêché ce(tte) %{resource} d'être sauvegardé(e) :","other":"%{count} erreurs ont empêché ce(tte) %{resource} d'être sauvegardé(e) :"},"password_format":"doit contenir une majuscule, une minuscule, un chiffre et un caractère spécial","record_invalid":"L'objet de peut être enregistré car il est invalide","taken":"est déjà utilisé","taken_in_past":"a déjà été utilisé par le passé","too_short":"est trop court"}},"identifiers":{"index":{"title":"Identifiants"}},"mailer":{"service_notifier":{"send_validation":{"subject":"Votre service a été activé","text":"Vous pouvez dès à présent accéder au tableau de bord de %{name}."}},"shared":{"best_regard":"Cordialement.","hello":"Bonjour,"},"user_notifier":{"send_welcome_email":{"subject":"Bienvenue"}}},"misc":{"advanced_permissions":"Permissions avancées","back_office":"Tableau d'administration","captcha":"Code de vérification","captcha_hint":"Veuillez recopier le code de vérification.","correct_errors":"Merci de corriger les erreurs ci-dessous :","dashboard":"Tableau de bord","invalid_fields":"Champs renseignés non valides","parameters":"Paramètres","permissions":"Permissions","profile":"Profil","roles":"Rôles"},"pages":{"root":{"title":"Bienvenue sur OpenRH"},"service_book":{"description":"Voici le catalogue des startups proposant leurs APIs sur la plateforme","title":"Catalogue des startups"}},"permissions":{"list_services":{"title":"Permissions"}},"proxies":{"create":{"title":"Nouvelle fonctionalité"},"edit":{"title":"Modifier la fonctionnalité"},"form":{"hints":{"authorization_url":"L'URL d'autorisation doit commencer par un slash. Exemple : \"/api/oauth/token\".","client_secret":"La clé secrète est encryptée à l'enregistrement. Ne la renseignez que si vous souhaitez modifier sa valeur."},"tabs":{"authorization":"Autorisation","general":"Général"}},"index":{"description":"Paramétrez vos APIs afin de fournir des données à des clients","title":"Fonctionnalités"},"new":{"title":"Nouvelle fonctionalité"},"proxy_parameters_form":{"select_authorization_mode":"Sélectionnez un mode d'autorisation..."},"show":{"title":"Fonctionnalité"},"update":{"title":"Modifier la fonctionnalité"}},"query_parameters":{"create":{"title":"Ajouter"},"edit":{"title":"Modifier"},"form":{"default_mode":"DEFAULT"},"index":{"title":"Paramètres de requête"},"new":{"title":"Ajouter"},"show":{"title":"Paramètre de requête"},"update":{"title":"Modifier"}},"roles":{"admin":{"description":"Un administrateur de compagnie peut créer des compagnies et administrer des clients.","icon":"fa fa-fw fa-user-circle","title":"Administrateur","title_long":"Administrateur de compagnie"},"commercial":{"description":"Un commercial peut créer des contrats pour le compte de ses clients ou startups.","icon":"fa fa-fw fa-handshake-o","title":"Commercial","title_long":"Commercial"},"developer":{"description":"Un startuper peut créer des startups et configurer leurs APIs.","icon":"fa fa-fw fa-user","title":"Startuper","title_long":"Startuper"},"superadmin":{"description":"Un Super-Administrateur de la plateforme a accès à tout en lecture et écriture.","icon":"fa fa-fw fa-star","title":"Super-administrateur","title_long":"Super-Administrateur"}},"routes":{"create":{"title":"Nouvelle route"},"edit":{"title":"Modifier la route"},"form":{"default_protocol":"Par défaut (%{protocol})"},"index":{"title":"Routes"},"new":{"title":"Nouvelle route"},"show":{"title":"Route"},"update":{"title":"Modifier la route"}},"services":{"edit":{"title":"Paramètres"},"form":{"hints":{"subdomain":"Doit être en minuscule et ne peut contenir que des caractères alpha-numériques et le trait d'union"}},"index":{"title":"Services"},"new":{"title":"Créer un nouveau service"},"show":{"title":"Tableau de bord"},"update":{"title":"Paramètres"}},"types":{"authorization_modes":{"null":"Autorisation non requise","oauth2":"OAuth 2.0 client credentials grant"},"genders":{"female":"Madame","male":"Monsieur"},"protocols":{"http":"HTTP","https":"HTTPS"},"query_parameter_modes":{"forbidden":"interdit","mandatory":"obligatoire","optional":"optionnel"},"service_types":{"client":"Client","service":"Service","startup":"Startup"}},"users":{"confirmations":{"new":{"title":"Instructions de confirmation"}},"index":{"title":"Utilisateurs"},"mailer":{"confirmation_instructions":{"subject":"Instructions de confirmation"},"password_change":{"subject":"Votre mot de passe a été modifié avec succés."},"reset_password_instructions":{"subject":"Instructions pour changer le mot de passe"},"unlock_instructions":{"subject":"Instructions pour déverrouiller le compte"}},"passwords":{"edit":{"title":"Changer de mot de passe"},"new":{"title":"Mot de passe oublié"}},"registrations":{"edit":{"title":"Modifier mon compte"},"new":{"title":"S'inscrire"}},"sessions":{"new":{"description":"Accédez au tableau de bord","title":"Se connecter"}},"shared":{"links":{"did_not_received_confirmation_instructions":"Je n'ai pas reçu les instructions de confirmation","did_not_received_unlock_instruction":"Je n'ai pas reçu les instructions pour réactiver mon compte","forgot_password":"Mot de passe oublié"}},"unlocks":{"new":{"title":"Activer mon compte"}}}});
I18n.translations["en"] = I18n.extend((I18n.translations["en"] || {}), {"actions":{"activate":"Activate","add_admin":"Add an administrator","admin_list":"administrator list","back":"\u003c\u003c Back","change_password":"Change password","configure":"Configurate","deactivate":"Deactivate","destroy":"Delete","edit":"Edit","edit_account":"Edit account","infos":"Infos","new":"New","resend_confirmation_instructions":"Resend confirmation instructions by email","reset_password":"Send password reset instructions","reset_unlock_instructions":"Resend unlock instructions","return":"Return","save":"Save","save_in_progress":"Save in progress...","send_welcome_instructions":"Send welcome instructions by email","set_admin":"Set admin","sign_in":"Sign in","sign_out":"Sign out","sign_up":"Sign up","signin_in":"Signin in...","signin_up":"Signin up..","success":{"created":"%{resource} was successfuly created","destroyed":"%{resource} was successfuly deleted","updated":"%{resource} was successfuly updated"},"unset_admin":"Unset admin"},"activerecord":{"attributes":{"company":{"name":"Name"},"contact_detail":{"address_line1":"Address","address_line2":"Address (line 2)","address_line3":"Address (line 3)","city":"City","country":"Country","name":"Address Name","phone":"Phone Number","siret":"SIRET Number","zip":"Zip Code"},"identifier":{"client_id":"Public Key","client_secret":"Secret Key","encrypted_secret":"Encrypted Secret Key","user":"Creator"},"proxy":{"alias":"Alias","description":"Description","name":"Name","proxy_parameter":{"authorization_mode":"Authorization mode","authorization_url":"Authorization URL","grant_type":"Grant type","hostname":"Hostname","port":"Port","protocol":"Protocol","realm":"realm"},"service":"Service","service_id":"Service","user":"Creator","user_id":"Creator"},"proxy_parameter":{"authorization_mode":"Authorization mode","authorization_url":"Authorization URL","grant_type":"Grant type","hostname":"Hostname","port":"Port","protocol":"Protocol","realm":"realm"},"query_parameter":{"mode":"Mode","name":"Name"},"route":{"description":"Description","hostname":"Hostname","name":"Name","port":"Port","protocol":"Protocol","proxy":"Proxy","proxy_id":"Proxy","url":"URL","user":"Creator","user_id":"Creator"},"service":{"client_id":"CLIENT_ID","client_secret":"CLIENT_SECRET","company":"Company","company_id":"Company","description":"Description","name":"Name","public":"Publish in catalog","service_type":"Type","subdomain":"Public identifier","user":"Creator","user_id":"Creator","website":"Website"},"user":{"current_password":"Current password","email":"Email","first_name":"First name","full_name":"Full name","gender":"Gender","is_active":"Active ?","last_name":"Last name","password":"Password","password_confirmation":"Password confirmation","phone":"Phone Number"}},"errors":{"messages":{"record_invalid":"Validation failed: %{errors}","restrict_dependent_destroy":{"has_many":"Cannot delete record because dependent %{record} exist","has_one":"Cannot delete record because a dependent %{record} exists"}}},"models":{"company":"Company","contact_detail":"Contact Detail","identifier":"Credential","proxy":"Proxy","proxy_parameter":"Proxy parameter","query_parameter":"Query parameter","route":"Route","service":"Service","user":"User"},"validations":{"service":{"missing_subdomain":"The public identifier can't be blank","subdomain_changed_disallowed":"The public identifier can't be changed because service is active"}}},"back_office":{"users":{"create":{"title":"New User"},"edit":{"title":"Edit"},"index":{"title":"Users"},"new":{"title":"New User"},"permissions":{"title":"Permissions"}}},"companies":{"add_admin":{"title":"Add an administrator"},"admin_list":{"title":"Administrators list"},"clients":{"title":"Clients"},"index":{"title":"Companies"},"new":{"title":"Create a new company"},"startups":{"title":"Startups"}},"config":{"platform_name":"OpenRH"},"date":{"abbr_day_names":["Sun","Mon","Tue","Wed","Thu","Fri","Sat"],"abbr_month_names":[null,"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"],"day_names":["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"],"formats":{"default":"%Y-%m-%d","long":"%B %d, %Y","short":"%b %d"},"month_names":[null,"January","February","March","April","May","June","July","August","September","October","November","December"],"order":["year","month","day"]},"datetime":{"distance_in_words":{"about_x_hours":{"one":"about 1 hour","other":"about %{count} hours"},"about_x_months":{"one":"about 1 month","other":"about %{count} months"},"about_x_years":{"one":"about 1 year","other":"about %{count} years"},"almost_x_years":{"one":"almost 1 year","other":"almost %{count} years"},"half_a_minute":"half a minute","less_than_x_minutes":{"one":"less than a minute","other":"less than %{count} minutes"},"less_than_x_seconds":{"one":"less than 1 second","other":"less than %{count} seconds"},"over_x_years":{"one":"over 1 year","other":"over %{count} years"},"x_days":{"one":"1 day","other":"%{count} days"},"x_minutes":{"one":"1 minute","other":"%{count} minutes"},"x_months":{"one":"1 month","other":"%{count} months"},"x_seconds":{"one":"1 second","other":"%{count} seconds"}},"prompts":{"day":"Day","hour":"Hour","minute":"Minute","month":"Month","second":"Seconds","year":"Year"}},"devise":{"confirmations":{"confirmed":"Your email address has been successfully confirmed.","confirmed_at":"Email address was confirmed on %{date}","email_confirmation":"Email address confirmation","send_instructions":"You will receive an email with instructions for how to confirm your email address in a few minutes.","send_paranoid_instructions":"If your email address exists in our database, you will receive an email with instructions for how to confirm your email address in a few minutes.","unconfirmed":"Email address has not been confirmed"},"failure":{"already_authenticated":"You are already signed in.","expired":"Your account has expired due to inactivity. Please contact the site administrator.","inactive":"Your account is not activated yet.","invalid":"Invalid %{authentication_keys} or password.","last_attempt":"You have one more attempt before your account is locked.","locked":"Your account is locked.","not_found_in_database":"Invalid %{authentication_keys} or password.","session_limited":"Your login credentials were used in another browser. Please sign in again to continue in this browser.","timeout":"Your session expired. Please sign in again to continue.","unauthenticated":"You need to sign in or sign up before continuing.","unconfirmed":"You have to confirm your email address before continuing."},"invalid_captcha":"The captcha input is not valid!","mailer":{"confirmation_instructions":{"subject":"Confirmation instructions"},"password_change":{"subject":"Password Changed"},"reset_password_instructions":{"subject":"Reset password instructions"},"unlock_instructions":{"subject":"Unlock instructions"}},"omniauth_callbacks":{"failure":"Could not authenticate you from %{kind} because \"%{reason}\".","success":"Successfully authenticated from %{kind} account."},"password_expired":{"change_required":"Your password is expired. Please renew your password!","show":{"description":"You are required to change your password in order to sign in.","title":"Expired password"},"updated":"Your new password is saved."},"passwords":{"no_token":"You can't access this page without coming from a password reset email. If you do come from a password reset email, please make sure you used the full URL provided.","password_restrictions":"At least 6 characters, one uppercase, one downcase and one numeric.","send_instructions":"You will receive an email with instructions on how to reset your password in a few minutes.","send_paranoid_instructions":"If your email address exists in our database, you will receive a password recovery link at your email address in a few minutes.","updated":"Your password has been changed successfully. You are now signed in.","updated_not_active":"Your password has been changed successfully."},"registrations":{"destroyed":"Bye! Your account has been successfully cancelled. We hope to see you again soon.","pending_reconfirmation":"New email adress waiting for confirmation: %{email}","signed_up":"Welcome! You have signed up successfully.","signed_up_but_inactive":"You have signed up successfully. However, we could not sign you in because your account is not yet activated.","signed_up_but_locked":"You have signed up successfully. However, we could not sign you in because your account is locked.","signed_up_but_unconfirmed":"A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.","update_needs_confirmation":"You updated your account successfully, but we need to verify your new email address. Please check your email and follow the confirm link to confirm your new email address.","updated":"Your account has been updated successfully."},"sessions":{"already_signed_out":"Signed out successfully.","signed_in":"Signed in successfully.","signed_out":"Signed out successfully."},"unlocks":{"send_instructions":"You will receive an email with instructions for how to unlock your account in a few minutes.","send_paranoid_instructions":"If your account exists, you will receive an email with instructions for how to unlock it in a few minutes.","unlocked":"Your account has been unlocked successfully. Please sign in to continue."}},"errors":{"an_error_occured":"An error occured","connection_refused":"Oops! Failed to connect to the Web Console middleware.\nPlease make sure a rails development server is running.\n","format":"%{attribute} %{message}","messages":{"accepted":"must be accepted","already_confirmed":"was already confirmed, please try signing in","blank":"can't be blank","confirmation":"doesn't match %{attribute}","confirmation_period_expired":"needs to be confirmed within %{period}, please request a new one","empty":"can't be empty","equal_to":"must be equal to %{count}","equal_to_current_password":"must be different to the current password!","even":"must be even","exclusion":"is reserved","expired":"has expired, please request a new one","greater_than":"must be greater than %{count}","greater_than_or_equal_to":"must be greater than or equal to %{count}","inclusion":"is not an authorized value","invalid":"is invalid","less_than":"must be less than %{count}","less_than_or_equal_to":"must be less than or equal to %{count}","model_invalid":"Validation failed: %{errors}","not_a_number":"must be numeric","not_an_integer":"must be an integer","not_found":"not found","not_locked":"was not locked","not_saved":{"one":"1 error prohibited this %{resource} from being saved:","other":"%{count} errors prohibited this %{resource} from being saved:"},"odd":"must be odd","other_than":"must be other than %{count}","password_format":"must contain big, small letters and digits","present":"must be blank","record_invalid":"The record cannot be saved because it is invalid","required":"must exist","taken":"is already used","taken_in_past":"was already taken in the past!","too_long":{"one":"is too long (maximum is 1 character)","other":"is too long (maximum is %{count} characters)"},"too_short":"is too short","wrong_length":{"one":"is the wrong length (should be 1 character)","other":"is the wrong length (should be %{count} characters)"}},"unacceptable_request":"A supported version is expected in the Accept header.\n","unavailable_session":"Session %{id} is no longer available in memory.\n\nIf you happen to run on a multi-process server (like Unicorn or Puma) the process\nthis request hit doesn't store %{id} in memory. Consider turning the number of\nprocesses/workers to one (1) or using a different server in development.\n"},"flash":{"actions":{"create":{"notice":"%{resource_name} was successfully created."},"destroy":{"alert":"%{resource_name} could not be destroyed.","notice":"%{resource_name} was successfully destroyed."},"update":{"notice":"%{resource_name} was successfully updated."}}},"hello":"Hello world","helpers":{"select":{"prompt":"Please select"},"submit":{"create":"Create %{model}","submit":"Save %{model}","update":"Update %{model}"}},"identifiers":{"index":{"title":"Credentials"}},"mailer":{"service_notifier":{"send_validation":{"subject":"Your service has been activated","text":"You are notified that you can now access to the dashboard of %{name}."}},"shared":{"best_regard":"Best regard.","hello":"Hello!"},"user_notifier":{"send_welcome_email":{"subject":"Welcome"}}},"misc":{"advanced_permissions":"Advanced permissions","back_office":"Back Office","captcha":"Verification code","captcha_hint":"Please copy the verification code.","correct_errors":"Correct the following errors and try again:","dashboard":"Dashboard","invalid_fields":"Invalid Fields","parameters":"Parameters","permissions":"Permissions","profile":"Profile","roles":"Roles"},"number":{"currency":{"format":{"delimiter":",","format":"%u%n","precision":2,"separator":".","significant":false,"strip_insignificant_zeros":false,"unit":"$"}},"format":{"delimiter":",","precision":3,"separator":".","significant":false,"strip_insignificant_zeros":false},"human":{"decimal_units":{"format":"%n %u","units":{"billion":"Billion","million":"Million","quadrillion":"Quadrillion","thousand":"Thousand","trillion":"Trillion","unit":""}},"format":{"delimiter":"","precision":3,"significant":true,"strip_insignificant_zeros":true},"storage_units":{"format":"%n %u","units":{"byte":{"one":"Byte","other":"Bytes"},"eb":"EB","gb":"GB","kb":"KB","mb":"MB","pb":"PB","tb":"TB"}}},"percentage":{"format":{"delimiter":"","format":"%n%"}},"precision":{"format":{"delimiter":""}}},"pages":{"root":{"title":"Welcome to OpenRH"},"service_book":{"description":"The catalog of startups providing APIs on the marketplace","title":"Startup Book"}},"permissions":{"list_services":{"title":"Permissions"}},"proxies":{"create":{"title":"New functionality"},"edit":{"title":"Edit functionality"},"form":{"hints":{"authorization_url":"Authorisation URL must start with a slash. Example : \"/api/oauth/token\".","client_secret":"The secret key is encrypted on save. You are not required to fill it if you want to keep the actual value."},"tabs":{"authorization":"Authorization","general":"General"}},"index":{"description":"Manage your APIs and provide data to the clients","title":"Functionalities"},"new":{"title":"New functionality"},"proxy_parameters_form":{"select_authorization_mode":"Select an authorization mode..."},"show":{"title":"Functionality"},"update":{"title":"Edit functionality"}},"query_parameters":{"create":{"title":"New query parameter"},"edit":{"title":"Edit"},"form":{"default_mode":"DEFAULT"},"index":{"title":"Query parameters"},"new":{"title":"New query parameter"},"show":{"title":"Query parameter"},"update":{"title":"Edit"}},"roles":{"admin":{"description":"A Company Administrator can create companies and manage them.","title":"Administrator","title_long":"Company Administrator"},"commercial":{"description":"A Company Commercial can create contracts and on behalf of his clients.","title":"Commercial","title_long":"Company Commercial"},"developer":{"description":"A startuper can create startups and manage their APIs.","title":"Startuper","title_long":"Startuper"},"superadmin":{"description":"A Super-Administrator can do everything on the platform.","title":"Super-Administrator","title_long":"Super-Administrator"}},"routes":{"create":{"title":"New route"},"edit":{"title":"Edit route"},"form":{"default_protocol":"Default (%{protocol})"},"index":{"title":"List of routes"},"new":{"title":"New route"},"show":{"title":"Route"},"update":{"title":"Edit route"}},"services":{"form":{"hints":{"subdomain":"Must be lower case and contain alphanumeric and minus characters only"}},"index":{"title":"List of services"},"new":{"title":"Create a new service"}},"simple_form":{"error_notification":{"default_message":"Veuillez consulter les problèmes ci-dessous:"},"no":"Non","required":{"mark":"*","text":"Obligatoire"},"yes":"Oui"},"support":{"array":{"last_word_connector":", and ","two_words_connector":" and ","words_connector":", "}},"time":{"am":"am","formats":{"default":"%a, %d %b %Y %H:%M:%S %z","long":"%B %d, %Y %H:%M","short":"%d %b %H:%M"},"pm":"pm"},"types":{"authorization_modes":{"null":"No authentication required","oauth2":"OAuth 2.0 client credentials grant"},"genders":{"female":"Ms.","male":"Mr."},"protocols":{"http":"HTTP","https":"HTTPS"},"query_parameter_modes":{"forbidden":"forbidden","mandatory":"mandatory","optional":"optional"},"service_types":{"client":"Client","service":"Service","startup":"Startup"}},"users":{"confirmations":{"new":{"title":"Confirmation instructions"}},"index":{"title":"Users"},"mailer":{"confirmation_instructions":{"subject":"Confirmation instructions"},"password_change":{"subject":"Password Changed"},"reset_password_instructions":{"subject":"Reset password instructions"},"unlock_instructions":{"subject":"Unlock instructions"}},"passwords":{"edit":{"title":"Change password"},"new":{"title":"Forgot password"}},"registrations":{"edit":{"title":"Edit my account"},"new":{"title":"Sign up"}},"sessions":{"new":{"description":"Log in to your developer account and manage your functionalities","title":"Developer Account"}},"shared":{"links":{"did_not_received_confirmation_instructions":"Didn't receive confirmation instructions?","did_not_received_unlock_instruction":"Didn't receive unlock instructions?","forgot_password":"Forgot password"}},"unlocks":{"new":{"title":"Unlock my account"}}}});
