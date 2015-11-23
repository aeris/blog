---
---
$ ->
	$('a[rel="popover"]').popover
		html: true
		trigger: 'hover'

	$('#flattr').click ->
		$.getScript '//api.flattr.com/js/0.6/load.js?mode=auto', ->
			FlattrLoader.render {
				'uid': 'aeris'
				'url': document.URL
				'title': document.title
			}, 'flattr', 'replace'
		$(this).hide()

	$('#tweeter').click ->
		$.getScript '//platform.twitter.com/widgets.js'
		$(this).after '<a href="https://twitter.com/share" class="twitter-share-button" data-count="vertical" data-via="aeris22">Tweeter</a>'
		$(this).hide()

	$('#google').click ->
		$(this).after "<div class=\"g-plus\" data-action=\"share\" data-annotation=\"vertical-bubble\" data-href=\"#{document.URL}\"></div>"
		window.___gcfg = lang: 'fr'
		po = document.createElement('script')
		po.type = 'text/javascript'
		po.async = true
		po.src = 'https://apis.google.com/js/plusone.js'
		s = document.getElementsByTagName('script')[0]
		s.parentNode.insertBefore po, s
		$(this).hide()
