Title: Vie privée : et le DNS alors ?
Date: 2015-02-18
Category: privacy
Tags: dns, gafam

# Le DNS, annuaire de l’Internet

Pour ceux qui ne serait pas forcément au courant, le DNS est à la base de tout l’Internet tel qu’on le connaît aujourd’hui.<br/>
Sans lui, nous serions contraint d’apprendre par cœur les adresses IP des serveurs qu’on souhaite consulter.
Et forcément, `62.210.124.124` ou pire `2001:bc8:3f23:100::1`, c’est beaucoup moins sexy que `imirhil.fr`…

Chaque nom de domaine possède un ou plusieurs serveurs appelé « serveur faisant autorité » (*authoritative server* en
anglais), qui publie pour l’ensemble de la planète les données de la zone, avec généralement un serveur primaire
(*master*) et au moins un serveur secondaire (*slave*, pour prendre le relai du master en cas de panne).
Par exemple, les miens sont `ns.imirhil.fr` pour le master et `primary.heberge.info` (merci à
[Benjamin](https://twitter.com/vincib) !) et `nssec.online.net` pour les slaves.<br/>
La beauté de la chose est que ces serveurs sont eux-mêmes renseignés dans la zone DNS qu’ils servent, via les entrées `NS`.
On peut donc les lister avec tout outil permettant de requêter le DNS, `dig` par exemple :

    :::bash
    $ dig NS imirhil.fr.
    ns.imirhil.fr.
    primary.heberge.info.
    nssec.online.net.

À chaque fois que votre machine a besoin de résoudre un nom de domaine pour obtenir les adresse IP correspondantes, elle
demande à son résolveur (généralement celui de votre FAI, mais vous pouvez aussi utiliser un des multiples résolveurs
disponibles sur le net, comme `80.67.169.12` de [FDN](http://www.fdn.fr/) ou `80.67.188.188` de [LDN](http://ldn-fai.net/),
qui ont généralement [moins tendance à mentir](http://blog.fdn.fr/?post/2014/12/07/Filtrer-The-Pirate-Bay-Ubu-roi-des-Internets).<br/>
Soit le résolveur connaît déjà la réponse (mise en cache) et il la donne immédiatement, soit il va se mettre à résoudre
le nom récursivement, disons `blog.imirhil.fr`.<br/>
Il va commencer par interroger [un des 13 serveurs-racines du DNS] (dont il connaît la liste) qui servent la zone `.` :

    :::bash
    $ dig NS .
    . NS f.root-servers.net.
    . NS l.root-servers.net.
    . NS e.root-servers.net.
    . NS i.root-servers.net.
    . NS b.root-servers.net.
    . NS j.root-servers.net.
    . NS m.root-servers.net.
    . NS k.root-servers.net.
    . NS d.root-servers.net.
    . NS h.root-servers.net.
    . NS g.root-servers.net.
    . NS c.root-servers.net.
    . NS a.root-servers.net.

pour demander à n’importe lequel qui sont les serveurs faisant autorité sur la zone `fr.` :

    :::bash
    $ dig NS fr. @f.root-servers.net.
    fr. NS g.ext.nic.fr.
    fr. NS f.ext.nic.fr.
    fr. NS e.ext.nic.fr.
    fr. NS d.ext.nic.fr.
    fr. NS d.nic.fr.

pour ensuite demander à l’un d’eux qui est autoritaire sur `imirhil.fr` :

    :::bash
    $ dig NS imirhil.fr. @g.ext.nic.fr.
    imirhil.fr. NS ns.imirhil.fr.
    imirhil.fr. NS primary.heberge.info.
    imirhil.fr. NS nssec.online.net.

pour ensuite demander à l’un d’eux qui est `blog.imirhil.fr` :

    :::bash
    $ dig A blog.imirhil.fr. @ns.imirhil.fr.
    blog.imirhil.fr   CNAME server.imirhil.fr.
    server.imirhil.fr A     62.210.124.124

# Après l’annuaire, le journal d’appel…

Actuellement, presque tout le monde utilise le résolveur de son FAI, et donc il n’y a pas vraiment de problème de vie
privée. Seul le résolveur du FAI voit que tartampion demandé `youporn.com`, c’est ensuite le résolveur du FAI qui ira
résoudre `youporn.com` auprès du serveur autoritaire de YouPorn (en l’occurence une machine contrôlée par
[UltraDNS](http://www.neustar.biz/services/dns-services/enterprise-dns-services)).

Mais les grands FAI se mettent à mentir, pour de mauvaises raisons (publicité, optimisation de trafic…), volontairement
(appât du gain) ou non (décision de justice). Et donc on ne peut plus leur faire confiance et on doit utiliser notre
propre résolveur.<br/>
Certaines extensions de sécurité du DNS (DNSSec par exemple) nécessite aussi d’avoir un résolveur au plus près de la
machine cliente (le morceau de réseau entre le client et le résolveur doit être de confiance), et donc plutôt dans le
LAN ou carrément sur la machine que du côté du FAI.<br/>
Et du coup, notre vie privée en prend une grosse baffe, puisque c’est **votre** résolveur qui va aller toquer à la porte
du serveur faisant autorité !

Si le serveur autorité de `youporn.com` était dans le réseau qui allait servir la page `www.youporn.com`, vu que 10ms
après avoir demandé « qui est `www.youporn.com` ? » à `X.X.X.53`, `X.X.X.80` verrait arriver une requête HTTP « est-ce
que je peux avoir [/watch/9912017/sexe-alcool-et-vie-privee/](http://www.youporn.com/watch/9912017/sexe-alcool-et-vie-privee/) ? ».
Et donc globalement, à part moi-même et YouPorn, personne ne serait au courant de mon penchant pour les chatons dans les
tuyaux.

Mais le grand ternet étant ce qu’il est, `youporn.com` n’est **pas** servi par une machine YouPorn mais par des machines
UltraDNS :

    :::bash
    $ dig NS youporn.com.
    youporn.com. NS pdns6.ultradns.co.uk.
    youporn.com. NS pdns2.ultradns.net.
    youporn.com. NS pdns1.ultradns.net.
    youporn.com. NS pdns5.ultradns.info.
    youporn.com. NS pdns3.ultradns.org.
    youporn.com. NS pdns4.ultradns.org.

Bien différent de ce qui héberge `www.youporn.com` :

    :::bash
    $ dig A www.youporn.com.
    www.youporn.com. CNAME youporn.com.
    youporn.com.     A     31.192.116.24

    $ whois 31.192.116.24
    inetnum:        31.192.116.24 - 31.192.116.27
    netname:        c3526-VikingHostBV

Et donc je dégeule ma vie privée à de parfaits inconnus n’ayant strictement aucun rapport avec mon sujet…

# Oui, mais un journal d’appel unique et mondial…

Le problème est en fait bien pire que ça.
Et Pour ne pas changer, c’est encore et toujours une simple histoire de centralisation du réseau.<br/>
Il n’y a que très peu d’entités qui hébergent leurs zones DNS en propre, la plupart passe par des entreprises spécialisées,
type [UltraDNS](http://www.neustar.biz/services/dns-services/enterprise-dns-services),
[Amazon](https://aws.amazon.com/fr/route53/), [CloudFlare](https://www.cloudflare.com/dns),
[Akamai](http://www.akamai.com/html/solutions/fast-dns.html) ou [Dyn](http://dyn.com/standard-dns/).<br/>
(Fun-fact du jour : la zone `amazon.com` est servie par… Dyn et UltraDNS ! « Eat your own dog food » comme on dit…)

Et du coup ces entreprises concentrent une grosse partie du trafic Internet mondial, et **peuvent vous suivre à la trace**.
À chaque requête DNS que vous faites, ce sont ces entités qui répondent et peuvent donc dresser une liste de vos consultations.
Comme elles sont présentes quasi-partout, aucune de vos demandes ne leur échappe.

Afin de bien voir l’ampleur de la catastrophe, j’ai développé [un outil](https://gist.github.com/aeris/1a1ba71264c9c1e49e03)
(zone `github.com` résolue par Dyn, donc Dyn est maintenant au courant que vous avez achetez un cadeau à votre petit·e
ami·e sur Amazon pour la Saint-Valentin et que vous savez coder, ce qui vous classe en plus dans le 0.1% des geeks en
couple :P) qui analyse les serveurs autorités des 100.000 sites les plus fréquentés au monde
([liste](http://s3.amazonaws.com/alexa-static/top-1m.csv.zip) fournie par [Alexa](http://www.alexa.com/topsites),
`alexa.com` servie par Amazon, donc en plus on sait maintenant que vous vous intéressez au web).

Après 4h de requétage DNS intensif, le résultat complet est disponible [ici](|filename|/doc/alexa-ns.ods), référençant quelques
23 578 serveurs autorités (pour 100.000 sites ! On devrait en avoir quelques 200.000 si tout le monde s’auto-hébergeait !!!).<br/>
Le résultat est sans appel :

<table>
	<thead>
		<tr>
			<th>Fournisseur</th>
			<th>NS</th>
			<th>%</th>
			<th>% cumulés</th>
		</tr>
	</thead>
	<tbody>
		<tr><th>1. awsdns</th><td>25912</td><td>9,72%</td><td>9,72%</td></tr>
		<tr><th>2. cloudflare.com</th><td>16808</td><td>6,31%</td><td>16,03%</td></tr>
		<tr><th>3. domaincontrol.com</th><td>9626</td><td>3,61%</td><td>19,64%</td></tr>
		<tr><th>4. dnsmadeeasy.com</th><td>8786</td><td>3,30%</td><td>22,94%</td></tr>
		<tr><th>5. dynect.net</th><td>8234</td><td>3,09%</td><td>26,03%</td></tr>
		<tr><th>6. akamai</th><td>7056</td><td>2,65%</td><td>28,68%</td></tr>
		<tr><th>7. ultradns</th><td>4921</td><td>1,85%</td><td>30,52%</td></tr>
		<tr><th>8. registrar-servers.com</th><td>3293</td><td>1,24%</td><td>31,76%</td></tr>
		<tr><th>9. name-services.com</th><td>3079</td><td>1,16%</td><td>32,92%</td>
		<tr><th>10. hichina.com</th><td>3041</td><td>1,14%</td><td>34,06%</td></tr>
	</tbody>
</table>

Amazon héberge à lui tout seul 10% du top 100k.
Le top 10 des fournisseurs représente un tiers du trafic.
Le top 50 intercepte la moitié du trafic DNS.
Il faut attendre d’avoir intercepté plus de 80% du trafic pour enfin voir des gens s’héberger en propre (StackOverflow, Reddit…).<br/>

Si on regarde uniquement le top 10k, les 10 plus gros fournisseurs draînent 43% du trafic, et pire sur le top 1000, les
3 plus gros se taillent la part du lion avec 33% de part de marché…

En bref, il suffit de trouilloter un très petit nombre de prestataires pour pouvoir suivre à la trace une bonne moitié
de la planète…<br/>
On constate même que les marketeux ont bien compris l’intérêt du tracking par DNS, avec par exemple la présence de
[l’Observatoire des marques](http://www.observatoiredesmarques.fr/surveillance.php) (5 NS du top 10k et 77 NS du top 100k)
ou encore [MarkMonitor](https://www.markmonitor.com/services/domain-management.php) (85 NS du top 10k et 693 NS du top
100k) et qui n’ont pour unique but que de surveiller le DNS pour dresser des stats de fréquentation…

Vie privée vous aviez dis ?
