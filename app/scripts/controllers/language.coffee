app.controller 'LanguageCtrl', ['$scope', '$locale', 'socket', 'util', '$cookies', ($scope, $locale, socket, util, $cookies)->
  # init language by $locale.id
  $scope.language = $locale.id

  $scope.setLanguage = ()->
    $locale.id = $scope.language
    util.cookie 'language', $scope.language, 9999
    socket.emit 'language:change', $scope.language
]
app.run ['$rootScope', '$locale', '$cookies', ($rootScope, $locale, $cookies)->
  $rootScope.languageMap =
    'en': 'English'
    'fi': 'Suomi'
    'es': 'Español'
    'vi': 'Tiếng Việt'

  # init language by cookies
  if $cookies.language
    $locale.id = $cookies.language
]
