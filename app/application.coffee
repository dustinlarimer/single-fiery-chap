config = require 'config'
mediator = require 'mediator'
Layout = require 'views/layout'

module.exports = class Application extends Chaplin.Application

  initLayout: (options = {}) =>
    options.title ?= @title
    @layout = new Layout options

  initMediator: ->
    mediator.firebase = new Firebase(config.firebase)
    mediator.users = null
    mediator.current_user = null
    super