angular.module('nuxeoAngularSampleApp')


.factory "nxNavigation", ['nxSession', '$routeParams', '$location', 
(nxSession, $routeParams, $location)->


  
  nxNavigation = {}

  nxNavigation.getBreadCrumb = ()->
    breadcrumb = [{name: "Root", path: "/"}]
    path = getPath()

    if(angular.isUndefined(path)) then return []
    
    if(path != "/") 
      pathes = path.replace(/^\//,'').split("/")
      fullPath = []
      for path in pathes      
        fullPath.push(path)
        breadcrumb.push
          path: "/" + fullPath.join("/")
          name: if path then path else "Root"

    breadcrumb


  getPath = ()->    
    if angular.isDefined($routeParams.path) then  "/" + $routeParams.path.replace(/\/$/,'') else undefined
    
  nxNavigation.navigateTo = (path)->    
    $location.path "nav" + path
    
  nxNavigation.getCurrentDocument = ()->    
    nxSession.getDocument(getPath())

  nxNavigation
]


