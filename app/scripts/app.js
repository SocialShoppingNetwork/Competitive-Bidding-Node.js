'use strict';

var app = angular.module('exhibiaApp', ['angular-l10n', 'ngCookies', 'ui.bootstrap.dropdownToggle', 'ui.bootstrap.alert', 'ui.bootstrap.modal',
                                        'ui.bootstrap.transition', 'ui.bootstrap.dialog', 'ui.bootstrap.accordion', 'ui.bootstrap.collapse']);

app.config(['$routeProvider', function ($routeProvider) {
  $routeProvider
    .when('/', {
      templateUrl: 'views/main.html',
      controller: 'MainCtrl'
    })
    .when('/item/:code', {
      templateUrl: 'views/main.html',
      controller: 'MainCtrl'
    })
    .when('/about', {
      templateUrl: 'views/about.html',
      controller: 'AboutCtrl'
    })
    .when('/admin/:model', {
      templateUrl: 'views/admin.html',
      controller: 'AdminCtrl'
    })
    .when('/admin/:model/:code', {
      templateUrl: 'views/admin.html',
      controller: 'AdminCtrl'
    })
    .when('/user/:model', {
      templateUrl: 'views/user.html',
      controller: 'UserCtrl'
    })
    .when('/user/:model/:code', {
      templateUrl: 'views/user.html',
      controller: 'UserCtrl'
    })
    .otherwise({
      redirectTo: '/'
    });
}]);
