---
title: Extensions Firefox pour protéger sa vie privée
---

Comme promis à plusieurs personnes, un petit billet sur les extensions que j’utilise pour tenter de protéger ma vie privée.

Vous pourrez retrouver toutes ces extensions (et d’autres que j’ai pu tester mais pas retenu) sur ma collection [Respect my privacy](https://addons.mozilla.org/firefox/collections/aeris22/pr/).

# Celles qu’on peut installer les yeux fermées

Pour commencer, les extensions qui n’ont pas d’effets de bord notable sur l’usage de son Internet.
Vous pouvez donc les installer sans aucun soucis.

![Au revoir UTM](/assets/images/20151208/au-revoir-utm.png) **[Au-revoir-UTM](https://addons.mozilla.org/firefox/addon/au-revoir-utm/)** est une extension très simple qui va virer automatiquement les balises « utm » laissées par les régies publicitaires ou trackers pour savoir d’où vous venez lors de l’accès au contenu.

![Decentraleyes](/assets/images/20151208/decentraleyes.png) **[Decentraleyes](https://addons.mozilla.org/firefox/addon/decentraleyes/)** remplace à la volée les contenus que vous auriez normalement dus aller chercher sur des [CDN](https://en.wikipedia.org/wiki/Content_delivery_network) centralisés et généralement très enclin à violer votre vie privée, tels Google, CloudFlare, Akamai et j’en passe.

![Disconnect](/assets/images/20151208/disconnect.png) **[Disconnect](https://addons.mozilla.org/firefox/addon/disconnect/)** supprime tout le contenu traçant comme le contenu publicitaire, les outils d’analyse de trafic et les boutons sociaux.

![DNSSec/TLSA Validator](/assets/images/20151208/dnssec-tlsa-validator.png) **[DNSSec/TLSA Validator](https://addons.mozilla.org/firefox/addon/dnssec-validator/)** est une extension qui permet de vérifier les signatures [DNSSec](https://fr.wikipedia.org/wiki/Domain_Name_System_Security_Extensions) et [DANE/TLSA](https://fr.wikipedia.org/wiki/DNS_-_based_Authentication_of_Named_Entities), qui ne sont malheureusement pas encore vérifiées nativement par Firefox.
DNSSec couplé à DANE/TLSA permet d’enfin se passer des autorités de certification de HTTPS, et à un administrateur de déclarer par lui-même quel certificat et/ou clef publique il utilise.

![HTTPS Everywhere](/assets/images/20151208/https-everywhere.png) **[HTTPS Everywhere](https://addons.mozilla.org/firefox/addon/https-everywhere/)** force votre navigateur à utiliser les versions HTTPS (donc chiffrés) des sites web que vous consultez, même si vous cliquez sur un lien HTTP (en clair).
Pas de panique, l’extension utilise une liste de sites compatibles et validés à la main, vous ne risquez donc pas de finir n’importe où si le site visite supporte HTTPS mais est mal configuré.

![Pure URL](/assets/images/20151208/pure-url.png) **[Pure URL](https://addons.mozilla.org/firefox/addon/pure-url/)**, dans la lignée de Au revoir UTM, nettoie vos URL du contenu traçant.
L’extension supporte plus de contenu traçant que Au revoir UTM (Yandex, Youtube, Facebook…) mais fait moins le ménage sur Google (Au revoir UTM supprime tous les tags utm_, Pure URL uniquement certain).

![SSleuth](/assets/images/20151208/ssleuth.png) **[SSleuth](https://addons.mozilla.org/firefox/addon/ssleuth/)** analyse le niveau de sécurité des connexions HTTPS que vous effectuez et affiche une note entre 0 et 10.
Attention cependant, ce n’est pas parce qu’un site est bien noté qu’il est effectivement correctement sécurisé.
SSleuth ne note en effet que le niveau de sécurité des paramètres que vous avez réussi à négocier avec le serveur, il est tout à fait possible que celui-ci en supporte plein d’autres, dont peut-être des totalement non fiables.
À titre d’exemple, un passage sur [https://galaxie.enseignementsup-recherche.gouv.fr/](https://galaxie.enseignementsup-recherche.gouv.fr/) vous donnera une note de 6.3/10, alors que le serveur est [un des pires que j’ai pu rencontré](https://tls.imirhil.fr/https/galaxie.enseignementsup-recherche.gouv.fr), allant jusqu’à supporter NULL-MD5, ie. pas de chiffrement du tout…

![uBlock Origin](/assets/images/20151208/u-block.png) **[uBlock Origin](https://addons.mozilla.org/firefox/addon/ublock-origin/)**, qu’on ne présente plus, un super bloqueur de publicité et de trackeurs. Très léger et n’intégrant pas (encore) les publicités « acceptables », juste un must-have.

# Celles qui peuvent parfois vous jouer des tours

![Blender](/assets/images/20151208/blender.png) **[Blender](https://addons.mozilla.org/firefox/addon/blender-1/)** est une extension qui va tricher sur l’identité de votre navigateur, pour tenter de le faire passer pour celui le plus utilisé à l’heure actuelle, et ainsi se noyer dans la masse.
Il peut par exemple vous faire passer pour un anglais, masquer vos polices de caractères ou vos plugins installés, ou encore forcer les en-têtes envoyés aux serveurs.  
Problème, certains paramètres peuvent troubler les serveurs en face, qui vont avoir du mal à vous répondre correctement (par exemple [Firefox Hello](https://www.mozilla.org/firefox/hello/) n’est plus utilisable avec le mode « forçage des en-têtes » actif).

![Certificate Patrol](/assets/images/20151208/certificate-patrol.png) **[Certificate Patrol](https://addons.mozilla.org/firefox/addon/certificate-patrol/)** devrait aussi être un must-have sur les navigateurs, mais est malheureusement parfois un peu trop intrusif.
Il permet de se protéger d’une attaque de l’homme du milieu sur HTTPS, avec un attaquant qui trafiquerait le certificat présenté (par exemple avec la coopération d’une autorité de certification).
Lorsque vous vous connectez pour la première fois sur un site en HTTPS, Certificate Patrol vous demande de confirmer que le certificat présenté est valable (par exemple en demandant si une personne dans un autre pays que le vôtre voit le même certificat, ou en <s>harcelant</s> contactant l’administrateur du site directement).
Si vous vous reconnectez sur le même site mais qu’il présente alors un certificat différent, il va vous alertez qu’il y a un soucis et vous demandera si vous voulez réellement continuer ou non.  
L’extension est parfois assez intrusive, en particulier sur les sites mal configuré ou utilisant un CDN (donc présentant un certificat différent sur presque chacune de vos requêtes), comme par exemple Twitter.
Pas d’autre choix que de la désactiver sur certains domaines pour avoir enfin la paix, même si cette extension peut littéralement [vous sauvez la vie](https://status.imirhil.fr/conversation/10144#notice-11924), surtout dans un pays un peu craignos (Syrie, Libye, Iran, France…). 

![Cookie Monster](/assets/images/20151208/cookie-monster.png) **[Cookie Monster](https://addons.mozilla.org/firefox/addon/cookie-monster/)**, une extension qui bloque complètement les cookies et en particulier les cookies tiers.
Très efficace pour protéger votre vie privée, les cookies restant le moyen de prédilection pour vous tracer en permanence, le blocage des cookies pose néanmoins quelques soucis sur certains sites, et il faut alors passer par une configuration manuelle de l’extension pour rétablir les choses.

![Smart Referer](/assets/images/20151208/smart-referer.png) **[Smart Referer](https://addons.mozilla.org/firefox/addon/smart-referer/)** permet de masquer son [référent](https://fr.wikipedia.org/wiki/Référent_(informatique)). En effet, par défaut, votre navigateur envoie au serveur l’URL du site duquel vous venez.
L’extension permet de remplacer cette valeur par l’URL du site sur lequel on va, voire carrément de supprimer l’information.
Malheureusement, certains sites vérifient ce référent pour autoriser ou non l’accès à une ressource (image ou vidéo généralement), Smart Referer peut donc parfois casser les fonctionnalités d’un site, il faut alors aller dans les préférences de l’extension pour ajouter le site en question à la liste d’exclusion.

![uMatrix](/assets/images/20151208/u-matrix.png) **[uMatrix](https://addons.mozilla.org/firefox/addon/umatrix/)** est **THE** extension ultime pour la protection de sa vie privée sur Internet.
Elle va en effet bloquer **tout** appel externe au site visité, vous protégeant de tout le tracking ambiant du net.
Problème, elle est extrêmement intrusive, avec la plupart des sites totalement cassés par défaut.
Il faut un certain temps d’adaptation pour mettre suffisamment de filtre d’exclusion pour retrouver un confort de surf.
Le gros avantage de uMatrix sur [Request Policy](https://addons.mozilla.org/firefox/addon/requestpolicy/) est de pouvoir filtrer non seulement par site mais aussi par contenu (HTML, CSS, JavaScript, image, vidéo…), ce qui permet d’être plus fin dans les exclusions et de n’autoriser que le strict minimum et non obligatoirement tout un domaine traçant.
