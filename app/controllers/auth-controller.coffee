mediator = require 'mediator'
Controller = require 'controllers/base/controller'
LoginView = require 'views/login-view'

module.exports = class AuthController extends Controller

  callback: (params) =>
    _.extend params, _.object window.location.hash
      .slice(1).split('&')
      .map((string) -> string.split('='))
    console.log 'AuthController#callback', params
    if params.error?
      @redirectTo 'auth#login', [params.error]
    else
      @publishEvent 'setTokens', params
      @redirectTo 'home#index'
      window.location = window.location.pathname
    
  login: (params) =>
    @publishEvent '!showLogin', params

  logout: =>
    @publishEvent '!logout'
    @redirectTo 'home#index'