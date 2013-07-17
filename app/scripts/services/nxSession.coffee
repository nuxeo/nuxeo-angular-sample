angular.module('nxSession',['ng'])


.factory "nxSessionFactory", ['$http','$q',($http,$q) ->
  nxSessionFactory = (apiRootPath) ->
    
    apiRootPath = apiRootPath
    Session = {}


    class nxChain
      constructor: (@chainName, @doc)->
        @params= {}

      param: (key, value)->
        @params[key] = value
        @

      execute: (resultType)->
        resultType = if resultType? then resultType else "blob"

        $http.post(apiRootPath + @doc.getResourceUrl() + "/@op/" + @chainName, {params: @params}).then (response)->
          #TODO Add deserialization and encapsulation based on expected resultType
          response.data


    class nxAdapter
      constructor: (json)->
        angular.extend this,json

      save: ()->
        doc = Session.getDocument(@id)
        self = @
        $http.post(apiRootPath + doc.getResourceUrl() + "/@ba/" + @['entity-type'], @).then (response)->
          angular.extend self, response.data
          self







    class nxDocument
      constructor: (pathOrId, jsonDoc) ->
        if jsonDoc? then angular.extend @,jsonDoc
        @pathOrId = pathOrId

      fetch: ()->
        self = @
        $http.get(apiRootPath + @getResourceUrl()).then (response)->
          angular.extend self, response.data
          delete self.pathOrId
          self

      _getPathOrId: ()->
        if @uid? then @uid else @pathOrId


      getResourceUrl: ()->
        if @uid? then "/id/" + @uid else if(@_getPathOrId()[0] == "/")
          "/path" + @pathOrId
        else
          "/id/" + @pathOrId            

      getChildren: ()->
        $http.get(apiRootPath + @getResourceUrl() + "/@children").then (response)->
          docs = response.data
          if(angular.isArray(docs.entries))
            docs.entries.map( (jsonDoc)-> new nxDocument(jsonDoc.uid, jsonDoc))
          else
            $q.reject("Response was not a collection")

      save: ()->
        $http.put(apiRootPath + "/id/" + @uid , @).then (response)->
          new nxDocument(response.data.uid, response.data)

      delete: ()->
        $http.delete(apiRootPath + @getResourceUrl(), @)
          


      setPropertyValue: (property, value)->
        @properties[property] = value

      op: (chainName)->
        new nxChain(chainName, @)


      search: (query)->
        $http.get(apiRootPath + @getResourceUrl() + "/@search?q="+query).then (response)->
          docs = response.data
          if(angular.isArray(docs))
            docs.map( (response)-> new nxDocument(response))
          else
            $q.reject("Response was not a collection")


      getAdapter: (adapterName)->
        $http.get(apiRootPath + @getResourceUrl() + "/@ba/"+adapterName).then (response)->
          new nxAdapter(response.data)
        



        

    


    Session.getDocument = (pathOrId)->
      new nxDocument(pathOrId)

    Session.createDocument = (parentPath, name, type)->
      $http.post(apiRootPath + "/path" + parentPath, {type: type, name: name}).then (response)->
        new nxDocument(response.data.uid, response.data)
        






    Session

  nxSessionFactory
]





