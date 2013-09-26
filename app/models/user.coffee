config = require 'config'
Model = require 'models/base/model'

module.exports = class User extends Model
  idAttribute: 'id'