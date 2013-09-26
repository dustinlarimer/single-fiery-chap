config = require 'config'
Collection = require 'models/base/collection'

module.exports = class Users extends Collection

  initialize: ->
    super
    @firebase = new Backbone.Firebase(config.firebase + '/users')
    # Add this on init since no permissions exist before authentication