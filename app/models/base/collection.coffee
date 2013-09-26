Model = require './model'

module.exports = class Collection extends Chaplin.Collection
  _.extend @prototype, Chaplin.SyncMachine
  model: Model