
angular.module("nuxeoAngularSampleApp").controller "MainCtrl", 
['$scope','$http','nxSession',($scope,$http,nxSession) ->
  

  $scope.$watch "path", ()->
    $scope.document = nxSession.getDocument($scope.path).fetch()
    $scope.children = nxSession.getDocument($scope.path).getChildren()


    
  $scope.setPath = (path)->
    $scope.path = path

  $scope.path = "/default-domain"

  
]


