app.directive("overflowable", ->
  controller: ['$element', '$scope', '$rootScope', ($element, $scope, $rootScope) ->
    # add watcher, when there is new chat message, scroll to bottom
    watcher = ->
      $scope.messageList.last()?.message.last()
    alertWatcher = ->
      $rootScope.alertList.last()

    $scope.$watch watcher, ->
      fn = ->
        $element[0].scrollTop = 60000
      setTimeout fn, 0
    $scope.$watch alertWatcher, ->
      fn = ->
        $element[0].scrollTop = 60000
      setTimeout fn, 0
  ]
)
