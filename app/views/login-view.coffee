config = require 'config'
utils = require 'lib/utils'
View = require 'views/base/view'

module.exports = class LoginView extends View
  template: require './templates/login'
  autoRender: true

  initialize: (options) ->
    super
    @delegate 'click', 'ul.providers a', @authenticate

  authenticate: (e) =>
    provider = $(e.target).attr('class').substr(5)
    @publishEvent 'login:pickService', provider
    @publishEvent '!login', provider
    false