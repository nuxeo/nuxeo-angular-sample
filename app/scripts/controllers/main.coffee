
angular.module("nuxeoAngularSampleApp")

.controller("MainCtrl", ['$scope','$filter','nxSession','nxNavigation','$location',
($scope,$filter,nxSession,nxNavigation, $location) ->
    
  $scope.document = nxNavigation.getCurrentDocument().fetch(["dublincore","note","file"])
  $scope.children = []

  $scope.document.$then (doc)->
    if(doc.isFolderish())
      doc.getChildren(["dublincore","common"]).then (children)-> 
        $scope.children = children

  $scope.setPath = (path)->
    nxNavigation.navigateTo(path)

  $scope.newDocument = ()->
    $location.path($location.path() + "/new")

  $scope.editDocument = ()->
    $location.path($location.path() + "/edit")

  $scope.selectedDocs = ()->

    $filter('filter')($scope.children.entries, {checked: true})
    
  $scope.selectAll = ()->
    angular.forEach $scope.children.entries, (entry)->
      entry.checked = $scope.allSelected


  $scope.deleteSelectedDocuments = ()->
    []

  

])

.controller("EditCtrl", 
['$scope','nxNavigation','$routeParams',
($scope,nxNavigation,$routeParams) ->

  # Setup of jqUpload
  $scope.batchId = ["batch",new Date().getTime(),Math.floor(Math.random()*1000)].join "-"

  $scope.options = 
    url: "/nuxeo/site/automation/batch/upload"
    singleFileUploads: true
    multipart: false
    headers: 
      'X-Batch-Id' : $scope.batchId
      'X-File-Idx' : '0'
      'Nuxeo-Transaction-Timeout' : 2*5*60

  if(!jQuery.support.xhrFormDataFileUpload)
    $scope.options.formData = 
      batchId: batchId
      filedIdx: 0




  
  $scope.document = nxNavigation.getCurrentDocument().fetch(["dublincore","note","file"])
  $scope.document.$then (doc)->
    $scope.initialDoc = angular.copy(doc)

  $scope.isClean = ()->
    angular.equals($scope.initialDoc, $scope.document)

  $scope.save = ()->
    $scope.document.save($scope.batchId).then (doc)->
      nxNavigation.navigateTo(doc.path)

  $scope.docancel = ()->
    nxNavigation.navigateTo($scope.document.path)    

  $scope.destroy = ()->
    if(confirm("Do you really want to delete this document ?")) 
      $scope.document.delete().then (doc)->
        nxNavigation.navigateTo(doc.path)
])

 
.controller("CreateCtrl", 
['$scope','nxSession','nxNavigation','$routeParams',
($scope,nxSession,nxNavigation,$routeParams) ->

    # Setup of jqUpload
  $scope.batchId = ["batch",new Date().getTime(),Math.floor(Math.random()*1000)].join "-"

  $scope.options = 
    url: "/nuxeo/site/automation/batch/upload"
    singleFileUploads: true
    multipart: false
    headers: 
      'X-Batch-Id' : $scope.batchId
      'X-File-Idx' : '0'
      'Nuxeo-Transaction-Timeout' : 2*5*60

  if(!jQuery.support.xhrFormDataFileUpload)
    $scope.options.formData = 
      batchId: batchId
      filedIdx: 0


  
  $scope.parentDoc = nxNavigation.getCurrentDocument().fetch(["dublincore"])
  $scope.document = { properties: {}}

  $scope.save = ()->
    $scope.document.name = $scope.document.properties['dc:title']
    nxSession.createDocument($scope.parentDoc.path, $scope.document, $scope.batchId).then (doc)->
      nxNavigation.navigateTo(doc.path)

  $scope.docancel = ()->
    nxNavigation.navigateTo($scope.parentDoc.path)    

       
  
])

.controller "FileDestroyController", ["$scope", "$http", ($scope, $http) ->
  file = $scope.file
  state = undefined
  if file.url
    file.$state = ->
      state

    file.$destroy = ->
      state = "pending"
      $http(
        url: file.deleteUrl
        method: file.deleteType
      ).then (->
        state = "resolved"
        $scope.clear file
      ), ->
        state = "rejected"

  else if not file.$cancel and not file._index
    file.$cancel = ->
      $scope.clear file
]





