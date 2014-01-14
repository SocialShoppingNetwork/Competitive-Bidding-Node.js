###
  @controller
  @refactor
  @todo
    refactor, espscially itemList vs itemDetail
    itemDetail on which is no longer available in list, be can still be query from DB
###
app.controller 'MainCtrl', ['$route', '$scope', 'socket', '$location', 'util', '$dialog', '$rootScope', '$locale', '$interval', '$routeParams', ($route, $scope, socket, $location, util, $dialog, $rootScope, $locale, $interval, $routeParams)->
  socketUser = socket.of '/user'

  ###
  @helpers check if $routeParams.code is available, then display modal with sufficient information, else make sure modal is close
  @refactor
  ###
  openModalIfItemDetail = ->
    if $routeParams.code
      # find item then show modal
      $scope.itemDetail = $scope.itemList.find (item) ->
        item['id'] is $routeParams.code

      if $scope.itemDetail
        $scope.itemModal = true

      else
        $scope.itemModal = false
        $location.path '/'
        error =
          code: -1
          message: 'Item not found'
        return util.error error
    else
      $scope.itemModal = false
  currentRoute = $route.current
  $scope.$on '$locationChangeSuccess', (event) ->
    if currentRoute.controller is $route.current.controller
      $routeParams.code = $route.current.params.code
      $route.current = currentRoute
      openModalIfItemDetail()
  $scope.modalClose = ->
    # @todo re-route without page reload
    $location.path '/'
    # remove timeout of item modal if any
    if $scope.itemDetail?.competitionTimer
      $timeout.cancel $scope.itemDetail.competitionTimer
    $scope.itemModal = false

  competitionHandlerFunc = (data, item, offset) ->
    # setup hide/show values
    item.sponsoring = false
    item.transitioning = false
    item.competing = true

    # if item doesn't have competitor yet, enable 'compete'
    # else keep the value set by competeCheck()
    unless item.competitorList.last()?
      item.competeDisabled = false

    # if the item is competed while in competition phase, reset the timeout
    if data.competitionTimeout
      item.competitionEnd = Date.now() + data.competitionTimeout
    else
      # offset is counted to blur the difference in timeout due to page load time
      item.competitionEnd += offset

    if item.competitorList.isEmpty()
      item.competingMessage = false
    else
      # price in euro
      item.price = item.price / 100
      item.currentWinner = item.competitorList.last().username
      item.competingMessage = true

    # if this is not the first compete, call item.competitionUnregister() to clear previous timeout
    item.competitionUnregister() if item.competitionUnregister
    # then start a new one, to ensure there's only 1 $timeout at a time
    item.competitionUnregister = $interval (now)->
      if item.competitionEnd > now
        item.competitionTime = Math.floor (item.competitionEnd - now) / 1000
      else
        item.competitionUnregister()
        item.competitionUnregister = null
        unless item.competitorList.isEmpty()
          util.warning "Compete for Item: #{item.product.name} ended and the Winner is #{item.competitorList.last().username}."
        else
          util.warning "Compete for Item: #{item.product.name} ended."
        item.competeDisabled = true
        item.sponsorDisabled = true

  transitionHanlderFunc = (item, offset) ->
    # setup hide/show values
    item.sponsoring = false
    item.transitioning = true
    item.competing = false

    # disable 'compete' button before competition phase
    item.competeDisabled = true

    # offset is counted to blur the difference in timeout due to page load time
    item.competitionStart += offset

    item.transitionMessage = 'Waiting for item to be ready...'
    # if this is not the first ::item:update, call item.competitionUnregister() to clear previous timeout
    item.transitionUnregister() if item.transitionUnregister
    # then start a new one, to ensure there's only 1 $timeout at a time
    item.transitionUnregister = $interval (now)->
      # if transition is not yet ended
      if item.competitionStart > now
        item.transitionTime = Math.floor (item.competitionStart - now) / 1000
      else
        item.transitionUnregister()
        item.transitionUnregister = null
        item.transitionMessage = 'Waiting for server...'

        item.sponsoring = false
        item.transitioning = false
        item.competing = true
        item.competeDisabled = false

  # check availability of 'compete' button of an item
  competeCheck = (item) ->
    if $rootScope.session.user?
      if item.competitorList.last()?
        unless item.competitorList.last().userId is $rootScope.session.user.id
          item.competeDisabled = false
        else
          item.competeDisabled = true
      else
        item.competeDisabled = true
  itemRead = ->
    socket.emit 'item:read', null, (err, data, timestamp) ->
      return util.error err if err

      $scope.itemList = data
      offset = Date.now() - timestamp
      $scope.itemList.forEach (item) ->

        # item in sponsore phase
        item.sponsoring = true
        item.transitioning = false
        item.competing = false

        # check last competitor to disabled 'Compete'
        competeCheck item

        now = Date.now()
        # countdown timer for items in competition phase
        if item.competitionEnd > now
          competitionHandlerFunc data, item, offset

        # countdown timer for items in transition phase
        # @todo customer service
        if item.competitionStart > now
          transitionHanlderFunc item, offset

        # 'a few seconds ago' is a bit too long to display
        if moment(item.openAt).fromNow() is 'a few seconds ago'
          item.timeSince = 'Just now'
        else
          item.timeSince = moment(item.openAt).fromNow()

      openModalIfItemDetail()

  localeWatcher = ->
    $locale.id
  $scope.$watch localeWatcher, itemRead

  $scope.compete = ->
    if $routeParams.code
      itemCompete = @itemDetail
    else
      itemCompete = @item

    itemCompete.competeDisabled = true
    data =
      id: itemCompete.id
    socketUser.emit 'item:compete', data, (err, data) ->
      return util.error err if err

      util.success "Successfully compete #{itemCompete.product.name}"

  $scope.sponsor = ->
    if $routeParams.code
      itemSponsor = @itemDetail
      # sponsor in modal is restricted to $10(the default amount) each time
      amountSponsor = 10
    else
      itemSponsor = @item
      amountSponsor = @amount

    title = 'Sponsor Activity'
    msg = 'Please confirm your sponsoring on item: ' + itemSponsor.product.name
    btns = [{result:false, label: 'Cancel'}, {result:true, label: 'OK', cssClass: 'btn-primary'}]

    # popup a confirm dialog
    $dialog.messageBox(title, msg, btns)
      .open()
      # process if user choose 'OK', nothing happens otherwise
      .then (confirm) =>
        if confirm
          itemSponsor.sponsorDisabled = true
          data =
            id: itemSponsor.id
            amount: amountSponsor

          socketUser.emit 'item:sponsor', data, (error, data) =>
            # re-enable regardless the result
            itemSponsor.sponsorDisabled = false

            if error
              # open modal for user to setup a new credit card
              d = $dialog.dialog($scope.creaditOpts)
              d.open().then (data) ->
                if data
                  socketUser.emit 'card:create', data, (error, data) ->
                    return util.error error if error
                    util.success 'Credit card added successfully. Please make your sponsor again.'
              # return null to stop the flow
              return null
            amountSponsor = 10 unless amountSponsor
            util.success "Successfully sponsor #{amountSponsor}"
            amountSponsor = ''

  # listen to item:update event and update correspondent
  $scope.$on '::item:update', (scope, data, timestamp)->
    offset = Date.now() - timestamp

    # iterate through the list and find the correct item
    $scope.itemList.each (item)->
      if item.id is data.id

        # found it, update it
        item = Object.merge item, data

        # check last competitor to disabled 'Compete'
        competeCheck item

        now = Date.now()
        # countdown timer for items in competition phase
        if item.competitionEnd > now
          competitionHandlerFunc data, item, offset

        # countdown timer for items in transition phase
        # @todo customer service
        if item.competitionStart > now
          transitionHanlderFunc item, offset

        # return false to break the loop
        false

  $scope.descOpts =
    backdropFade: true
    dialogFade:true

  $scope.creaditOpts =
    backdrop: true
    keyboard: true
    backdropClick: true
    templateUrl: 'views/dialog/credit.html'
    controller: ['$scope', 'dialog', ($scope, dialog) ->
      $scope.close = () ->
        dialog.close()

      $scope.add = (card) ->
        dialog.close(card)
    ]

  # on new user connect, check lastWinner against the new user id
  $scope.$on ':/user:connect', ->
    $scope.itemList?.forEach (item) ->
      competeCheck item
]
