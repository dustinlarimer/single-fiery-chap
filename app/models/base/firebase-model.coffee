Model = require 'models/base/model'

module.exports = class FirebaseModel extends Model
  _(@prototype).extend Backbone.Firebase.Model