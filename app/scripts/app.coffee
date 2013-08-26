"use strict"
angular.module("nuxeoAngularSampleApp", ['nxSession','ui.bootstrap','blueimp.fileupload'])
.value("nxUrl", "/nuxeo/site/api" )
.factory("nxSession", ["nxSessionFactory","nxUrl",(nxSessionFactory,nxUrl)->
  nxSessionFactory(
    apiRootPath: nxUrl
  )
])
.config ($routeProvider) ->
  $routeProvider
  .when("/nav/*path/edit"
    templateUrl: "views/edit.html"
    controller: "EditCtrl"
  )
  .when("/nav/*path/new"
    templateUrl: "views/edit.html"
    controller: "CreateCtrl"
  )
  .when("/nav/*path"
    templateUrl: "views/main.html"
    controller: "MainCtrl"
  )
  
  .otherwise redirectTo: "/nav/"
