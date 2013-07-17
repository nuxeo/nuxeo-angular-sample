"use strict"
angular.module("nuxeoAngularSampleApp", ['nxSession'])
.factory("nxSession", ["nxSessionFactory",(nxSessionFactory)->
  nxSessionFactory("/nuxeo/site/api")
])
.config ($routeProvider) ->
  $routeProvider.when("/",
    templateUrl: "views/main.html"
    controller: "MainCtrl"
  ).otherwise redirectTo: "/"
