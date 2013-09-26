Collection = require 'models/base/collection'
FirebaseModel = require 'models/base/firebase-model'

module.exports = class FirebaseCollection extends Collection
  _(@prototype).extend Backbone.Firebase.Collection
  model: FirebaseModel
  
  initialize: ->
    console.log 'init FirebaseCollection'
    super