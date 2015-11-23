---
title: Pourquoi je recommande SMSSecure et pas TextSecure ou Signal
---

Le 6 mars 2015, [TextSecure](https://whispersystems.org/) a annoncé [la fin du support des SMS/MMS](https://whispersystems.org/blog/goodbye-encrypted-sms/) au profit unique d’un transport custom via [Google Cloud Messaging](https://developers.google.com/cloud-messaging/) et votre forfait data.

Depuis ce changement, je ne recommande plus du tout d’utiliser TextSecure (ou [Signal](https://whispersystems.org/blog/just-signal/)), mais un fork de ce système, reposant toujours sur les SMS, [SMSSecure](https://smssecure.org/).

Voici pourquoi.

# Dépendance à Google

TextSecure/Signal, depuis la suppression du mode SMS, réclame l’utilisation de GCM pour l’échange de données entre utilisateurs.
Ce système nécessite de passer par le Google Play, et donc d’avoir un compte Google.

Je me vois mal demander à mes correspondants d’installer une application nécessitant la création d’un compte chez Google et l’utilisation d’une plate-forme que je cherche à éviter par tous les moyens et qui est connue pour fonder l’ensemble de son modèle commercial sur le viol de la vie privée de ses utilisateurs et la revente de leurs informations personnelles.

La dépendance au Google Play empêche en plus d’utiliser des Android alternatifs comme [CyanogenMod](https://cyngn.com/) ou [Replicant](http://www.replicant.us/), qui ne proposent pas le Google Play, justement pour des motifs de respect de la vie privée de leurs utilisateurs.

# Prestataires étrangers plutôt que français

Le fonctionnement des SMS permet de n’utiliser que des réseaux français pour véhiculer l’information, et à ma connaissance uniquement via des réseaux (2, celui de l’émetteur puis du destinataire) pour lesquels les correspondants ont souscrit des contrats de vente français où les tribunaux français sont compétents en cas de litige.

Le fonctionnement par le canal des données, lui, fait partir vos données dans la nature, généralement via une multitude d’intermédiaires américains (les 2 FAI des correspondants, tous les prestataires intermédiaires, WhisperSystems, Google et sûrement encore 10 ou 12 autres) et avec lesquels vous n’avez signé aucun contrat sinon de nébuleuses conditions générales d’utilisations incompréhensibles.
Dans tous les cas, la justice française n’y aura pas son mot à dire, à la limite la justice californienne, si vous parvenez à la saisir…

# Réseau TCP/IP au lieu du réseau GSM

## Le contenu

On est sur un téléphone, n’y faites jamais transiter quelque chose de critique.
Si vous ne souhaitez pas que quelqu’un sache que vous avez correspondu avec intel ou que le contenu du message échangé soit rendu public, juste n’utilisez pas votre téléphone.

Entre [la puce baseband](https://fr.wikipedia.org/wiki/Processeur_de_bande_de_base) dont personne ne saurait dire ce qu’elle fait exactement, sinon qu’elle fait [des choses dégeulasses](https://www.fsf.org/blogs/community/replicant-developers-find-and-close-samsung-galaxy-backdoor), les [IMSI catcher](https://fr.wikipedia.org/wiki/IMSI-catcher) et autres joyeusetés, vous ne pouvez et ne devez pas considérer votre téléphone comme votre meilleur ami et lui confier vos secrets.

Que ce soit SMSSecure ou TextSecure, on ne peut donc absolument pas considérer ces solutions comme permettant une protection du contenu lors de l’envoi/réception d’un message.
Par contre ces deux solutions permettent de sécuriser les données a posteriori de l’envoi/réception, par exemple d’empêcher l’accès aux données en cas de vol de votre téléphone (ou de saisie judiciaire).

Égalité parfaite entre les deux applications sur ce point.

## Les méta-données

La grosse différence entre les deux outils va se trouver au niveau de la gestion des [méta-données](https://fr.wikipedia.org/wiki/Métadonnée).
Oui, parce qu’elles sont [beaucoup plus critiques](https://ssd.eff.org/fr/module/pourquoi-les-métadonnées-sont-elles-importantes) que le contenu lui-même et qu’elles permettent souvent, en plus de révéler votre graphe de relations, d’en apprendre beaucoup sur le contenu lui-même sans jamais y avoir accès.
Les révélations Snowden [regorgent](https://nsa.imirhil.fr/pages?filter=metadata&size=10&with_text=on) d’exemples d’usages tous plus glauques les uns que les autres qui sont faits via la récolte des méta-données.

TextSecure va reposer sur l’Internet « standard » (TCP/IP, routeurs, câbles transatlantiques…) pour transporter vos données, tout pile exactement le même chemin que votre navigation internet sous surveillance de la NSA et des [boîtes noires françaises](http://www.nextinpact.com/news/93724-on-vous-reexplique-projet-loi-sur-renseignement.htm).
Bref, quand vous allez envoyer un message à quelqu’un, certes son contenu va être protégé, mais un nombre important de services vont être au courant de vos échanges, et avec un peu de (mauvaise) volonté, pourraient réussir à corréler les méta-données collectées et à reconstruire votre graphe de relation, dans le but de vous placez plus de pub… ou de vous surveiller !
C’est ce que fait la NSA à longueur de temps, et ça a l’air plutôt efficace…

SMSSecure, lui, passe par le réseau GSM classique (voix & SMS) pour faire circuler l’information.
Même si on sait que ce réseau n’est pas [complètement fiable](http://www.zdnet.fr/actualites/ss7-la-confidentialite-des-reseaux-3g-remise-en-cause-39811821.htm) [non plus](https://theintercept.com/2015/02/19/great-sim-heist/), la surveillance y est bien plus complexe et coûteuse à mettre en place, en plus de ratisser beaucoup moins large et de nécessiter la coopération (volontaire ou non) des opérateurs téléphoniques.
On est finalement beaucoup plus proche de la surveillance ciblée que de la surveillance de masse.
On reste en plus sur un réseau 100% français, ce qui en soit n’est pas forcément une marque de confiance mais reste quand même statistiquement plus sûr que de voir son petit paquet réseau faire 42× le tour du monde pour atteindre votre correspondant à 10m de vous, et vous permettrait de vous retourner contre votre opérateur en cas de dérive.

# Connecté en permanence

TextSecure nécessite aussi du coup d’avoir la 3G d’allumée en permanence pour être joignable.

Si vous coupez la 3G, plus de réception de messages sécurisés, avec le risque que votre correspondant repasse en clair pour vous joindre à tout prix via un SMS classique…

Le fait d’avoir la data allumée en continu fait que vous allez aussi devoir lutter pour configurer correctement votre téléphone pour qu’il n’explose pas votre forfait (je n’ai que 50Mo de données par mois par exemple) ou ne viole votre vie privée, la plupart des applications grand public adorant juste transmettre vos informations (de géolocalisation en particulier) à qui veut bien l’entendre.
Certaines n’ont parfois même pas l’option « communication en Wifi seulement », et vous n’aurez alors d’autres choix que de la désinstaller ou de dégueuler votre vie privée (ou votre forfait)…

Bref, même si TextSecure était plus fiable et respectueux de votre vie privée, on court le risque de subir des effets de bord assez catastrophiques via les autres applications installées sur notre téléphone, vu qu’au contraire il est conseillé de couper la data le plus souvent possible pour éviter de [fuiter sa vie privée en permanence](http://www.francetvinfo.fr/replay-magazine/france-2/envoye-special/envoye-special-du-jeudi-12-fevrier-2015_822079.html).

# Bilan

Bref, les justifications apportées par WhisperSystems pour l’abandon du transport SMS ne tiennent pas la route pour de la communication franco-française.

La friction de l’échange de clef n’est déjà pour moi pas un argument recevable, automatiser cette partie revient à laisser un trou grand ouvert dans la raquette.
Comment en effet s’assurer qu’on communique réellement bien avec la bonne personne via la data si on automatise cette partie ?
En mode SMS, l’interception du message est quasiment du domaine de l’utopie sauf à être sous un modèle de menace qui devrait vous faire renoncer à l’usage même de votre téléphone.

La compatibilité avec les iPhones est aussi pour moi un faux problème.
Si on tient à sa vie privée et à sa confidentialité, on n’utilise pas non plus [ce genre](http://www.silicon.fr/us-doj-apple-dechiffrement-ios-iphone-129852.html) [de bestiole](http://www.macplus.net/depeche-85672-apple-bientot-contrainte-de-supprimer-le-chiffrement-en-grande-bretagne).
[Snowden lui-même](http://www.numerama.com/magazine/31997-mouchard-iphone.html) s’interdit d’utiliser un iPhone (même s’il est vrai qu’il n’a pas un modèle de menace très classique).
Android ne connaîtra pas ce genre de problème puisqu’étant du logiciel libre, on conservera à vie la possibilité de virer toute décision équivalente prise par Google, via CyanogenMod par exemple.

Pour les fuites de méta-données, je suis d’accord que le SMS en balance aussi beaucoup, mais sur un périmètre beaucoup plus limité (très local, au pire national, certainement pas mondial).
Ça peut effectivement être un problème quand on vit dans un pays totalitaire comme ceux mentionnés par WhisperSystems (Cuba, Égypte, Iran…), ce n’est pas le cas en France (pour le moment en tout cas), alors qu’on sait pertinemment que le réseau Internet, lui, est sous surveillance permanente d’au moins la NSA.
Et je préfère (et de loin) que Free ou Orange connaissent avec qui je discutes que Google…

TextSecure renforce aussi encore l’hégémonie de Google sur l’ensemble de la planète et va à l’encontre des bonnes pratiques en matière de téléphonie (data déconnectée le plus possible)

Bref, utilisez SMSSecure :)
