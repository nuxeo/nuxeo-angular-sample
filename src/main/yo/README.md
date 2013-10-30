# nuxeo-angular-sample

This is a very simple application that shows how to browse a Nuxeo repository using AngularJS.  Allowable types are Workspace, Folder, Note and File. 


## How to build

Build is based on [Yeoman](http://yeoman.io/) tooling that encapsulates grunt and bower to build the applicaiton.

In order to build, you have to :

 * install [Yeoman](http://yeoman.io/) (which involves installing npm, bower and grunt).

 * Download and Run a recent Nuxeo distribution (>= 5.7.2), that will run on port 8080.

 * clone this repository :

      git clone http https://github.com/nuxeo/nuxeo-angular-sample

 * install the necessary dependencies :

      npm install
      bower install

 * In the clone repository, launch :

      grunt server

This will launch nodeJs serving your application at `http://localhost:9000` (a browser should open automatically after launch). 

You can launch the app by launching `grunt server`, it should open a browser on the app on port 9000. All calls to the `/nuxeo/` context will be proxied to http://localhost:8080/nuxeo/. See `Gruntfile.js` for configuration 


## How it works

Grunt serves the HTML app by using NodeJS. In order to avoid CORS issues, a proxy is setup in `Gruntfile.js` to proxy all calls to `/nuxeo` to the backend Nuxeo server on port 8080 

    +---------+       +----------------------+  proxy    +--------------------+
    | Browser | --->  | NodeJS on port 9000  |---------> | Nuxeo on port 8080 |
    +---------+       |   call to /nuxeo are |           +--------------------+
                      |   proxied            |
                      +----------------------+

This means that in the code, all API calls will be done on `/nuxeo` without specifying a special http host. 
