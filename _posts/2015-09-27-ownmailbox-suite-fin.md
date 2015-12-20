---
title: Own-Mailbox, suite (et fin ?)
---

Histoire d’être plus précis pour les utilisateurs qui pourraient se poser des questions et être plus constructif, un dernier billet pour bien préciser la chose.\\
Déjà que ma position est partagée par beaucoup de monde, j’ai parlé de mon étude à mon entourage touchant au milieu en question (journalistes traitant de la surveillance de masse, développeurs crypto, animateurs café-vie-privée…) et tous
 partagent ma vision des choses.\\
Ensuite, je ne demande pas à Own-Mailbox d’être parfait, la perfection n’existant malheureusement pas en ce bas-monde.

# Sécurité

Pour se prévaloir d’une amélioration de la sécurité de ses utilisateurs, Own-Mailbox doit « simplement » corriger d’urgence au moins un des deux problèmes suivants et si possibles les deux :

 * Interdire techniquement qu’ils puissent avoir accès aux boîtiers une fois déployés. Ceci est valable pour les accès directs comme une prise de contrôle à distance pour assister leurs utilisateurs, mais aussi pour les accès indirects comme une éventuelle mise-à-jour d’un composant sous leur contrôle (leur version modifiée de RoundCube par exemple).
 * Retirer du boîtier tout stockage ou génération de la clef privée GPG, qui doivent se faire exclusivement sur la machine cliente de l’utilisateur (et encore moins sur une carte SD amovible…)

Ces deux points cumulés font que ce boîtier est une véritable bombe à retardement sécuritaire.
En effet, volontairement ou non (contrainte judiciaire, mise sous tutelle par la NSA & cie…), la prise de contrôle à distance couplée à la présence de la clef privée sur le boîtier fait que cette clef peut se retrouver compromise sans
 que l’utilisateur n’en soit informé.
La correction d’un des deux problèmes permettrait d’apporter au moins la sécurité des échanges de mail chiffrés, mais seule la fermeture des deux permet la protection des échanges non chiffrés.  
Je me ferai une joie d’aider le projet Own-Mailbox à travailler sur le premier point, puisque je suis moi-même concerné par cette problématique sur un de mes projets.
La correction de ce point signifie aussi indiquer clairement aux utilisateurs que les mises-à-jour de sécurité et la surveillance du système sont à leur propre charge.
Le second point est très difficilement corrigeable sans une formation correcte des utilisateurs à l’utilisation de GPG.

Sans correction d’au moins un de ces points, l’équipe du projet doit immédiatement avertir explicitement ses utilisateurs que leur solution ne leur permet pas d’être considérée comme fiable pour l’échange de correspondance critique.

D’autres problèmes subsisteront mais sont d’un degré beaucoup moins critique que ces deux-là réunis.

# Vie privée

Own-Mailbox ne pourra jamais se prévaloir d’être meilleur qu’une autre solution de mail, le trafic mail échangé restant le même qu’un échange fait via un GAYFAM ou autre service hébergé, et passe en particulier par le même matériel
 d’espionnage potentiel.
Leur mode PLM n’apporte rien sur cette partie, les méta-données étant les mêmes (émetteur et destinataire visibles) et circulant sur les mêmes canaux non fiabilisés.

L’équipe du projet doit donc informer explicitement ses utilisateurs que leur boîtier n’est pas une solution de protection vis-à-vis de la surveillance de masse mise en place par la NSA ou par les boîtes noires de la loi sur le renseignement en France.

# Centralisation

L’implémentation actuelle de Own-Mailbox n’est pas une décentralisation d’Internet, puisque si Own-Mailbox tombe, la très grosse majorité des boîtiers tombent avec (cause tunnel de port et nom de domaine gérés par le projet).
Seul le mode 100% auto-géré (nom de domaine personnel sans tunnel de port) peut être considéré comme une véritable décentralisation.

Own-Mailbox doit indiquer clairement ce fait à ses utilisateurs, en particulier qu’ils conservent le droit de vie ou de mort sur le trafic mail géré (volontairement ou sous la contrainte), en particulier le mail non chiffré.

Même sans amélioration des points précédents, le projet Own-Mailbox reste une bonne solution pour sortir des GAYFAM et reprendre a minima le contrôle de ses données, sous réserve qu’il remette à jour sa communication pour ne pas jouer sur cette corde sensible alors qu’il n’a pas les moyens de ses ambitions, et donc tombe dans la catégorie « charlatan ».

À partir du moment où vous n’utiliserez pas ce boîtier pour des communications critiques, achetez-le sans aucun soucis.
Considérez uniquement l’émetteur, le destinataire et le sujet du message comme circulant en clair dans le réseau et accessibles par tout un chacun et le contenu du mail potentiellement lisible par un tiers avec un peu de moyen.
Si vous devez échanger des communications à contenu critique ou dont les parties en présence doivent rester confidentielles, passez votre chemin, cette solution n’apporte strictement aucune garantie là-dessus.  
Le projet doit communiquer en ce sens ou corriger son implémentation technique :)

Je me réserve aussi le droit de contacter Kickstarter — comme cela avait été fait pour Anonabox — pour leur signaler le problème.
Ils jugeront par eux-même si ce projet doit être bloqué ou non, pour la sécurité des utilisateurs.

*[Épisode 1]({% post_url 2015-09-25-ownmailbox-charlatanisme-incompetence %})* —
*[La réponse à la réponse de Own-Mailbox]({% post_url 2015-09-27-ownmailbox-reponse %})*
