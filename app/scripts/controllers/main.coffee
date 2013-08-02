
angular.module("nuxeoAngularSampleApp")

.controller("MainCtrl", ['$scope','nxSession','nxNavigation','$location',
($scope,nxSession,nxNavigation, $location) ->
    
  $scope.document = nxNavigation.getCurrentDocument().fetch(["dublincore","note"])

  $scope.document.$then (doc)->
    if(doc.isFolderish())
      $scope.children = doc.getChildren(["dublincore"])

  $scope.setPath = (path)->
    nxNavigation.navigateTo(path)

  $scope.newDocument = ()->
    $location.path($location.path() + "/new")

  $scope.editDocument = ()->
    $location.path($location.path() + "/edit")

  

])

.controller("EditCtrl", 
['$scope','nxNavigation','$routeParams',
($scope,nxNavigation,$routeParams) ->
  
  $scope.document = nxNavigation.getCurrentDocument().fetch(["dublincore","note"])
  $scope.document.$then (doc)->
    $scope.initialDoc = angular.copy(doc)

  $scope.isClean = ()->
    angular.equals($scope.initialDoc, $scope.document)

  $scope.save = ()->
    $scope.document.save().then (doc)->
      nxNavigation.navigateTo(doc.path)

  $scope.cancel = ()->
    nxNavigation.navigateTo(doc.path)    

  $scope.destroy = ()->
    if(confirm("Do you really want to delete this document ?")) 
      $scope.document.delete().then (doc)->
        nxNavigation.navigateTo(doc.path)
])

 
.controller("CreateCtrl", 
['$scope','nxSession','nxNavigation','$routeParams',
($scope,nxSession,nxNavigation,$routeParams) ->
  
  $scope.parentDoc = nxNavigation.getCurrentDocument().fetch(["dublincore"])
  $scope.document = { properties: {}}

  $scope.save = ()->
    $scope.document.name = $scope.document.properties['dc:title']
    nxSession.createDocument($scope.parentDoc.path, $scope.document).then (doc)->
      nxNavigation.navigateTo(doc.path)

  $scope.cancel = ()->
    nxNavigation.navigateTo($scope.parentDoc.path)    

       
  
])





