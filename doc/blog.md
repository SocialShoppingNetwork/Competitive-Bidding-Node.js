# 2013-02-22
- angular controller should be declared only once, either in app.js or in the view
- always run brew doctor, remember to check $PATH

# 2013-02-23
- angular controllers can be nested
- socket.join('room') to handle 1 user with many tabs (https://github.com/LearnBoost/socket.io/wiki/Rooms)

# 2013-02-24
- ng-include for nested template (http://docs.angularjs.org/api/ng.directive:ngInclude). Example usage:
    <div>{{url}}</div>
    <div ng-include ng-src="url"></div>
  or with constant value:
    <div ng-include src="'views/template.html'"></div>

# Upload to S3
- 'process.env.ENV_VAR' to access environment variable
  use this to set access_id, access_key for S3

# 2013-02-25
- In for loop, initiate varable with `undefined`, otherwise in thenext step of
  loop, old variables remain

- All mongoose schemas should have version

- Setup mongodb replica set, instruction at
  http://docs.mongodb.org/manual/tutorial/deploy-replica-set/
  Replica set for Hipaise includes 2 members and 1 arbitrary

- Setup redis replication, intruction at: http://redis.io/topics/replication

# 2013-02-26
- Callback fn for emit event

- db.getCollectionNames() to list all mongo collection

- In config, $ for public, _ for private var

- 'sudo mongod' to start a thread for mongodb (on Mac)

- socket.io-based is different from traditional express/django web framework
  to emulate "signed cookie", a `cookie.key` was created by
  `crypto.randomBytes(256)`

- crypto is suck with update() vs final(). Call final() with more-than-15-char
  string messes thing up. Correct exmample
  ```
  data = 'Made with Gibberish ặ'
  crypto = require 'crypto'
  cip = crypto.createCipher 'aes256', key
  enc = cip.update data, 'utf8', 'base64'
  enc += cip.final 'base64'
  console.log enc, 'enc'

  dec = crypto.createDecipher 'aes256', key
  pla = dec.update enc, 'base64'
  pla += dec.final 'utf8'

  console.log pla
  ```

- every time a controller is switched, a new $scope (with incremental id) is
  created, if we listen to events and modify old (orphan) $scope, memory leak
  will soon occured. Also, listner will be duplicate everytime a controller is
  switched back. The combination of these issues is worse for Socket.io-based
  design
- because every time a controller is switched back, the whole code block inside
  is executed again, this code codeblock must NOT contain any listner. Listener
  should be put into `app.run` as init codeblock. Inside controller, there
  should be `emit` with callback only.

# 2013-02-27

- Run 'grunt config' everytime after changing the config

- **deprecated** with socket.io, never use empty-data event
  ```
  # emitting side
  socket.emit 'myevent', {}, fn

  # listening side
  socket.on 'myevent', (data, fn)->
    # do something
    fn()
  ```
  Use message with pseudo event name as data
  ```
  # emitting side
  socket.message 'myevent', fn

  # listening side
  socket.on 'message', (eventName, fn)->
    if eventName is 'myevent'
      # do something
      fn()
  ```

- As of today, `socket.message()` does not support acknowledge function

- ng-cloak to hide all ng-show and ng-hide til all angular and $scope are fully loaded

- ngSubmit to listen to '13' keyup event instead of declaring a custom 'onKeyUp' directive

- Using Angular Bootstrap: include component's src; declare its dependency in app.js

- Using admin namespace: declare new $routeParams.model in AdminCtrl; declare new controller in its own view

# 2013-02-28
- Mongoose res is a set of object thus can't be stringify toJSON
  We must stringify each object in the set

- Mongoose 'getter' is not applicable. Virtual object is used as a temporary
 solution (deprecated, see #2012-03-02)

# 2013-03-02

- http://mongoosejs.com/docs/api.html#document_Document-toObject how to use
  getter

# 2013-03-03

- Item code must not be unique if AuctionSchema to inherit from ItemSchema.
  It gives err 4001: 'Item code duplicated'

# 2013-03-05

- 3rd party listners should never be used in controllers, because everytime the
  controller is navigated into, a similar handler will be added to each event.
  Cleaning up listeners is also difficult, because 3rd party listners must be
  wrapped inside $rootScope.$apply. Instead, all 3rd party events should be
  listened in an angular service, then broadcast to root scope, and then in
  controller, use $scope.$on to handle, and these listners will be cleaned up
  automatically
  ```
  # third-party-service.coffee
  thirdParty.on 'anEvent', (arg) ->
    $rootScope.$apply $rootScope.$broadcast 'thirdParty:anEvent', arg

  # controller.coffee
  $scope.$on 'thirdParty:anEvent', (scope, arg) ->
    # do something with arg
  ```

# 2013-03-07

- query for MongoDB $push to ebedded array:
  $push: addressSet: data
- query for MongoDB $pull from ebedded array:
  $pull: addressSet: _id: addressId

- GIT: squash commits with rebase in cli
  http://gitready.com/advanced/2009/02/10/squashing-commits-with-rebase.html

# 2013-03-11

- $timeout service: the fn excuted by $timeout don't need to be in $scope but one excuting the $timeout need to be
  eg: item.myTimeout = $timeout timeoutfn, 1000
- to cancel a $timeout
  eg: $timeout.cancel item.myTimeout

#

- use `<button type='button'>{text}</button>` instead of `<input class='btn' type='button' value='{text}' />`
- use {var}Set or {var}List instead of {var}s

# 2013-03-19

- Get facebook avatar url from:
  graph.facebook.com/facebookId(or username)/picture?type=square(or small, large)

#  2012-03-20
-          message: 'Unknown error from MongoDB #{err.code}'
+          message: "Unknown error from MongoDB #{err.code}"
in order to use, interpolation, only double quote (not single quote) can be used

# 2013-03-24

- After import users to db, run braintree-sync.coffee on server
  New created user should be added immediately to braintree

# 2013-03-29

- Increasing price by €0.01 have a problem with 'Machince Precision':
  http://en.wikipedia.org/wiki/Floating_point#Machine_precision
  but the different is too small which hardly affect our system.
  By using angular filter currency limits the floating point to 2, the problem is solved.
  Further more, the service is neccessary for l10n

# 2013-04-05
- http://stackoverflow.com/questions/3092610/div-inside-link-a-href-tag
- change grunt-contrib-htmlmin dependency html-minifer to 0.5.0
- fix bug endTag to allow dash (-) in html-minifer
