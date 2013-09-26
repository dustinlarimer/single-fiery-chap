Application = require 'application'
routes = require 'routes'

# Initialize the application on DOM ready event.
$ ->
  new Application {
    title: 'Starter App',
    controllerSuffix: '-controller',
    routes
  }
