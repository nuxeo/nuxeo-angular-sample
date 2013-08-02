angular.module("nuxeoAngularSampleApp")

.controller("breadcrumbCtrl", ['$scope','nxNavigation',($scope,nxNavigation, $routeParams) ->    
  $scope.$on "$routeChangeSuccess", ()->
    $scope.breadcrumb = nxNavigation.getBreadCrumb()

  $scope.setPath = (path)->
    nxNavigation.navigateTo(path)
])