config = require 'config'
FirebaseModel = require 'models/base/firebase-model'

module.exports = class Profile extends FirebaseModel
  idAttribute: 'handle'
  #firebase: new Backbone.Firebase(config.firebase + '/profiles')
  
  initialize: ->
    super
    @firebase = new Backbone.Firebase(config.firebase + '/profiles')