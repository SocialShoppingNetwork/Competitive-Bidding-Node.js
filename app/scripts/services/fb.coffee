app.factory 'FB', () ->
  # list all the FB API to make a fake version before real version available
  fbCore = [
    # ====
    # Core Methods
    # ===
    'api'
    #'init'
    'ui'
    'getLoginStatus'
    # ====
    # Auth Methods
    # ====
    'login'
    'logout'
    # ====
    # Event Handling
    # ====
  ]
  fbEvent = [
    'subscribe'
    'unsubscribe'
  ]
  # store all the command queue
  queue =
    core: []
    event: []
  FB =
    Event: {}
  for api in fbCore
    FB[api] = ->
      queue.core.push
        method: api
        arguments: arguments
  fbEvent.forEach (api)->
    FB.Event[api] = ->
      queue.event.push
        method: api
        arguments: arguments

  window.fbAsyncInit = ->
    nativeFB = window.FB
    delete window['FB']
    for command in queue.event
      nativeFB.Event[command.method].apply nativeFB.Event, command.arguments

    # init the FB JS SDK
    nativeFB.init
      appId: "350731465045231" # App ID from the App Dashboard
      #cookie: true # set sessions cookies to allow your server to access the session?
      logging: false # disable logging
      status: false # check the login status upon init?
      xfbml: false # parse XFBML tags on this page?
      #channelUrl: "//WWW.YOUR_DOMAIN.COM/channel.html" # Channel File for x-domain communication

    for api in fbCore
      FB[api] = nativeFB[api]
    for api in fbEvent
      FB.Event[api] = nativeFB[api]

    #delete queue

    for command in queue.core
      nativeFB[command.method].apply nativeFB, command.arguments




  # Additional initialization code such as adding Event Listeners goes here

  # Service logic
  # ...

  # Public API here
  FB


# Load the SDK's source Asynchronously
# Note that the debug version is being actively developed and might
# contain some type checks that are overly strict.
# Please report such bugs using the bugs tool.
fn = (d, debug) ->
  js = undefined
  id = "facebook-jssdk"
  ref = d.getElementsByTagName("script")[0]
  return  if d.getElementById(id)
  js = d.createElement("script")
  js.id = id
  js.async = true
  js.src = "//connect.facebook.net/en_US/all" + ((if debug then "/debug" else "")) + ".js"
  ref.parentNode.insertBefore js, ref

fn window.document, false
