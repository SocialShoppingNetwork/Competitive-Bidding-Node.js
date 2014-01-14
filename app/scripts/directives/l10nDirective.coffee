#first, checks if it isn't implemented yet
unless String::format
  String::format = ->
    args = arguments
    @replace /{(\d+)}/g, (match, number) ->
      (if typeof args[number] isnt "undefined" then args[number] else match)

app.directive "l10nPlaceholder", ["$locale", "$interpolate", 'translation', ($locale, $interpolate, translation) ->

  BRACE = /{}/g
  # return
  restrict: "EA"
  link: (scope, element, attr) ->
    numberExp = attr.l10nPlaceholderCount
    # this is because we have {{}} in attrs
    params = element.attr(attr.$attr.l10nPlaceholderParams)?.split(',') or []
    whenTextExp = attr.l10nPlaceholder
    offset = attr.offset or 0
    whensTextExpFns = {}

    whensTextExpFnsBuild = ->
      whensText = translation[$locale.id]?[whenTextExp]

      # if cannot find, it is it...
      unless whensText
        whensText = whenTextExp

      # convert non-plural implicit translation
      if typeof whensText is 'string'
        whensText =
          other: whensText

      startSymbol = $interpolate.startSymbol()
      endSymbol = $interpolate.endSymbol()
      for key, expression of whensText
        e = String::format.apply expression, params
        if numberExp
          e = e.replace(BRACE, startSymbol + numberExp + "-" + offset + endSymbol)
        whensTextExpFns[key] = $interpolate(e)

    whensTextExpFnsBuild()
    localeChangeWatch = ->
      $locale.id
    scope.$watch localeChangeWatch, whensTextExpFnsBuild

    ngPluralizeWatch = ->
      value = parseFloat(scope.$eval(numberExp))
      unless isNaN(value)

        #if explicit number rule such as 1, 2, 3... is defined, just use it. Otherwise,
        #check it against pluralization rules in $locale service
        value = $locale.pluralCat(value - offset)  unless whensText[value]
        whensTextExpFns[value] scope, element, true
      else
        whensTextExpFns['other'] scope, element, true

    ngPluralizeWatchAction = (newVal) ->
      element.attr 'placeholder', newVal

    scope.$watch ngPluralizeWatch, ngPluralizeWatchAction

]

app.directive "l10n", ["$locale", "$interpolate", 'translation', '$rootScope', ($locale, $interpolate, translation) ->

  BRACE = /{}/g

  # return
  restrict: "EA"
  link: (scope, element, attr) ->
    numberExp = attr.l10nCount
    # this is because we have {{}} in attrs
    params = element.attr(attr.$attr.l10nParams)?.split(',') or []
    whenTextExp = element.text()

    offset = attr.offset or 0
    startSymbol = $interpolate.startSymbol()
    endSymbol = $interpolate.endSymbol()
    whensTextExpFns = {}

    whensTextExpFnsBuild = ->
      whensText = translation[$locale.id]?[whenTextExp]

      # if cannot find, it is it...
      unless whensText
        whensText = whenTextExp

      # convert non-plural implicit translation
      if typeof whensText is 'string'
        whensText =
          other: whensText

      for key, expression of whensText
        e = String::format.apply expression, params
        if numberExp
          e = e.replace(BRACE, startSymbol + numberExp + "-" + offset + endSymbol)
        whensTextExpFns[key] = $interpolate(e)

    whensTextExpFnsBuild()
    localeChangeWatch = ->
      $locale.id
    scope.$watch localeChangeWatch, whensTextExpFnsBuild

    ngPluralizeWatch = ->
      value = parseFloat(scope.$eval(numberExp))
      unless isNaN(value)

        #if explicit number rule such as 1, 2, 3... is defined, just use it. Otherwise,
        #check it against pluralization rules in $locale service
        value = $locale.pluralCat(value - offset)  unless whensText[value]
        whensTextExpFns[value] scope, element, true
      else
        whensTextExpFns['other'] scope, element, true

    ngPluralizeWatchAction = (newVal) ->
      element.text newVal

    scope.$watch ngPluralizeWatch, ngPluralizeWatchAction


]
