app.filter 'emo', [->
  # Use the browser's built-in functionality to quickly and safely escape the string
  # @todo refactor
  escapeHtml = (str) ->
    div = document.createElement("div")
    div.appendChild document.createTextNode(str)
    div.innerHTML

  emotify = undefined
  EMOTICON_RE = undefined
  emoticons = {}
  lookup = []

  # Function: emotify
  #
  # Turn text into emotified html. You know, like, with smileys.
  #
  # Usage:
  #
  #  > var html = emotify( text [, callback ] );
  #
  # Arguments:
  #
  #  text - (String) Non-HTML text containing emoticons to be parsed.
  #  callback - (Function) If specified, this will be called once for each
  #    emoticon with four arguments: img, title, smiley and text. The img and
  #    title arguments are the matched emoticon's stored image url and title
  #    text. The smiley argument is the primary smiley, and the text argument
  #    is the original text that was replaced. If unspecified, the default
  #    emotification function is used.
  #
  # Returns:
  #
  #  (String) An HTML string containing inline emoticon image HTML.
  emotify = (txt, callback) ->
    callback = callback or (img, title, smiley, text) ->
      title = (title + ", " + smiley).replace(/"/g, "&quot;").replace(/</g, "&lt;")
      "<span class='#{img}'>#{smiley}</span>"

    txt = escapeHtml txt
    txt.replace EMOTICON_RE, (a, b, text) ->
      i = 0
      smiley = text
      e = emoticons[text]

      # If smiley matches on manual regexp, reverse-lookup the smiley.
      unless e
        i++  while i < lookup.length and not lookup[i].regexp.test(text)
        smiley = lookup[i].name
        e = emoticons[smiley]

      # If the smiley was found, return HTML, otherwise the original search string
      if e
        b + callback(e[0], e[1], smiley, text)
      else
        a


  # Method: emotify.emoticons
  #
  # By default, no emoticons are registered with <emotify>. This method allows
  # you to add one or more emoticons for future emotify parsing.
  #
  # Usage:
  #
  #  > emotify.emoticons( [ base_url, ] [ replace_all, ] [ smilies ] );
  #
  # Arguments:
  #
  # base_url (String) - An optional string to prepend to all image urls.
  # replace_all (Boolean) - By default, added smileys only overwrite existing
  #   smileys with the same key, leaving the rest. Set this to true to first
  #   remove all existing smileys before adding the new smileys.
  # smilies (Object) - An object containing all the smileys to be added. If
  #   smilies is omitted, the method does nothing but return the current
  #   internal smilies object.
  #
  # Returns:
  #
  #  (Object) The internal smilies object. Do not modify this object directly,
  #  use the emotify.emoticons method instead.
  #
  # A sample emotify.emoticons call and smilies object:
  #
  #  > emotify.emoticons( "/path/to/images/", {
  #  >
  #  >   // "smiley": [ image_url, title_text [, alt_smiley ... ] ]
  #  >
  #  >   ":-)": [ "happy.gif", "happy" ],
  #  >   ":-(": [ "sad.gif", "sad", ":(", "=(", "=-(" ]
  #  > });
  #
  # In the above example, the happy.gif image would be used to replace all
  # occurrences of :-) in the input text. The callback would be called with the
  # arguments "happy.gif", "happy", ":-)", ":-)" and would generate this html
  # by default: <img src="happy.gif" title="happy, :-)" alt="" class="smiley"/>
  #
  # The sad.gif image would be used to replace not just :-( in the input text,
  # but also :( and :^(. If the text =( was matched, the callback would be called
  # with the arguments "sad.gif", "sad", ":-(", "=(" and would generate this
  # html by default: <img src="sad.gif" title="sad, :-(" alt="" class="smiley"/>
  #
  # Visit this URL for a much more tangible example.
  #
  # http://benalman.com/code/projects/javascript-emotify/examples/emotify/
  emotify.emoticons = ->
    args = Array::slice.call(arguments)
    base_url = (if typeof args[0] is "string" then args.shift() else "")
    replace_all = (if typeof args[0] is "boolean" then args.shift() else false)
    smilies = args[0]
    e = undefined
    arr = []
    alts = undefined
    i = undefined
    regexp_str = undefined
    if smilies
      if replace_all
        emoticons =
          {}
        lookup = []
      for e, v of smilies
        e = escapeHtml e
        emoticons[e] = v
        emoticons[e][0] = base_url + emoticons[e][0]

      # Generate the smiley-match regexp.
      for e of emoticons
        # Generate regexp from smiley.
        regexp_str = e.replace(/(\W)/g, "\\$1")
        arr.push regexp_str
      EMOTICON_RE = new RegExp("(^|\\s)(" + arr.join("|") + ")(?=(?:$|\\s))", "g")
    emoticons

  smilies =
    "<3": ["Heart"]

  emotify.emoticons "emo-", smilies
  (input) ->
    emotify input
]
