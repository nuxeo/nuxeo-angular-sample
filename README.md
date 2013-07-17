# nuxeo-angular-sample
======================


Build is based on [Yeoman](http://yeoman.io/) tooling that encapsulates grunt and bower to build the applicaiton.

In order to build, you have to install Yeoman (which involves installing npm, bower and grunt).

You can launch the app by launching `grunt server`, it should open a browser on the app on port 9000. All calls to the `/nuxeo/` context will be proxied to http://localhost:8080/nuxeo/. See `Gruntfile.js` for configuration 
