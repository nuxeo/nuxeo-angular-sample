"use strict"
describe "Service: nxSession >", ->

  apiRootPath = "/nuxeo/api/v1"

  $httpBackend = undefined
  session = undefined
  resolved = false



  # load the nxSession's module
  beforeEach module("nxSession")
  

  beforeEach inject(($injector,nxSessionFactory) ->
    $httpBackend = $injector.get('$httpBackend')
    session = nxSessionFactory({'apiRootPath':apiRootPath})
    resolved = false;
    
  )

  afterEach ()->
    $httpBackend.verifyNoOutstandingExpectation()
    $httpBackend.verifyNoOutstandingRequest()
    expect(resolved).toBe true

  describe "basic document CRUD >", ->


    it "should retrieve a document by its path", ()->
    
      $httpBackend.when('GET', apiRootPath + '/path/default-domain').respond 200, jsDocument()
      $httpBackend.when('GET', apiRootPath + '/path/default-domain/workspaces').respond 200, jsDocument()
      

      session.getDocument("/default-domain").fetch()
      session.getDocument("/default-domain/workspaces").fetch().$then (doc)->
        resolved = true
        expect(typeof doc).toBe "object"
      , (cause)->      
        console.log cause

      $httpBackend.flush 2
      
    


    it "should retrieve a document by its id", ()->
      $httpBackend.expectGET(apiRootPath + '/id/12345-6789').respond 200, jsDocument()
      $httpBackend.expectGET(apiRootPath + '/id/67890').respond 200, jsDocument()
      
      session.getDocument("12345-6789").fetch()    
      session.getDocument("67890").fetch().$then (doc)->
        resolved = true
        expect(typeof doc).toBe "object"

      $httpBackend.flush 2    
    

    it "should be able to retrieve a document's children", ()->    
      $httpBackend.expectGET(apiRootPath + '/id/12345-6789/@children').respond 200, jsDocuments(jsDocument("12345"), jsDocument("45678"))
      
      session.getDocument("12345-6789").getChildren().then (children)->
        resolved = true
        expect(children.entries.length).toBe 2
        
        doc = children.entries[0]
        expect(doc.uid).toBe "12345"
      , (error)->
        console.log error

      $httpBackend.flush()


    it "should be able to save a document",()->
      docModified = jsDocument("12345-6789")
      docModified.properties['dc:title'] = "New title"


      $httpBackend.expectGET(apiRootPath + '/id/12345-6789').respond 200, jsDocument("12345-6789")
      $httpBackend.expectPUT(apiRootPath + '/id/12345-6789', docModified ).respond 200, jsDocument("12345-6789")
      session.getDocument("12345-6789").fetch().$then (doc)->
        doc.setPropertyValue("dc:title","New title")
        doc.save().then (doc)->
          expect(doc.uid).toBe "12345-6789"
          resolved = true
        , (error)->
          console.log error

      $httpBackend.flush()


    it "should be able to create a document", ()->
      myDoc =         
        type: "File"
        name: "myDoc"

      $httpBackend.expectPOST(apiRootPath + '/path/folder', myDoc).respond 201, jsDocument("12345-6789")

      session.createDocument("/folder",myDoc).then (doc)->
        expect(doc.uid).toBe "12345-6789"
        resolved = true

      $httpBackend.flush()

      
    it "should be able to delete a document", ()->    
      $httpBackend.expectDELETE(apiRootPath + '/id/12345-6789').respond 200, "parentDoc"

      session.getDocument("12345-6789").delete().then (response)->      
        expect(response.status).toBe 200
        resolved = true
        
      $httpBackend.flush()


  describe "method on docs (search, automation....) >", ->

    it "should be able to run an operation", ()->

      expectedParams = 
        params:
          one: "1"
      
      $httpBackend.expectPOST(apiRootPath + '/id/12345-6789/@op/anOperation',expectedParams).respond 200, "operation result"

      session.getDocument("12345-6789").op("anOperation").param("one","1").execute().then (result)->
        expect(result).toBe "operation result"
        resolved = true

      $httpBackend.flush 1


    it "should be able to search for documents", ()->
      $httpBackend.expectGET(apiRootPath + '/id/12345-6789/@search?q=toto').respond 200, [jsDocument("12345-6789"),jsDocument(56789)]
  
      session.getDocument("12345-6789").search("toto").then (docs)->
        expect(docs.length).toBe 2
        resolved = true

      $httpBackend.flush 1
    


  describe "adapters >", ->

    beforeEach ()->
      $httpBackend.expectGET(apiRootPath + '/id/12345-6789/@bo/BusinessAdapter').respond 200, businessAdapter("12345-6789","Title")

    it "should be able ta get a business adapter", ()->    
      session.getDocument("12345-6789").getAdapter("BusinessAdapter").then (ba)->
        expect(ba.value.title).toBe "Title"
        resolved = true

      $httpBackend.flush 1


    it "should be able to save a document adapter", ()->
      modifiedBA = businessAdapter("12345-6789","New Title")
      $httpBackend.expectPOST(apiRootPath + '/id/12345-6789/@bo/BusinessAdapter', modifiedBA).respond 200, modifiedBA
    
      session.getDocument("12345-6789").getAdapter("BusinessAdapter").then (ba)->
        ba.value.title = "New Title"

        ba.save().then (newBa)->
          expect(newBa.value.title).toBe "New Title"
          resolved = true

      $httpBackend.flush 2




  # Simple document representation
  jsDocument = (uid, title, path, properties)->
    uid = if uid? then uid else "9e50d6aa-8450-4240-bc32-4769df51f7e8"    
    title = if title? then title else "default-domain"
    path = if path? then path else  "/default-domain"
    properties = if properties then properties else
      "common:icon": "/icons/domain.gif"
      "common:icon-expanded": null
      "common:size": null

    result = 
      "entity-type": "document"
      repository: "default"
      uid: uid
      path: path
      type: "Domain"
      state: "project"
      versionLabel: ""
      title: title
      lastModified: "2013-07-12T14:19:12.18Z"
      properties: properties        
      facets: ["SuperSpace","Folderish"]
      changeToken: "1373638752185"
      contextParameters: {}
    result
 
  jsDocuments = (docs...)->
    result = 
      "entity-type": "documents"
      entries: docs

  businessAdapter = (uid,title)->
    uid = if uid? then uid else "9e50d6aa-8450-4240-bc32-4769df51f7e8"    
    title = if title? then title else "default-domain"
    result = 
      "entity-type": "BusinessAdapter"
      value:
        type: "Domain"
        title: title
        id: uid
    result

    