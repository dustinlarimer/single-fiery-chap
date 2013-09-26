config = require 'config'
ServiceProvider = require './service-provider'
#User = require 'models/user'

module.exports = class Singly extends ServiceProvider
  baseUrl: config.singly.singlyURL

  constructor: ->
    super
    @accessToken = localStorage.getItem 'accessToken'

  load: ->
    @resolve()
    @providers = config.singly.providers
    this

  isLoaded: ->
    true

  ajax: (type, url, data) ->
    #console.log 'ajax', url, @accessToken, this
    url = @baseUrl + url
    url += "?access_token=#{@accessToken}" if @accessToken
    $.ajax {url, data, type, dataType: 'json'}

  triggerLogin: (loginContext) ->
    singly_url = config.singly.singlyURL + '/oauth/authenticate' +
      '?client_id=' + config.singly.clientID + 
      '&redirect_uri=' + config.singly.redirectURI + 
      '&service=' + loginContext + 
      '&response_type=token'
    #console.log singly_url
    singly_url = singly_url + '&access_token=' + @accessToken if @accessToken?
    window.location = singly_url
  
  getUserData: ->
    @ajax 'get', '/profile'
  
  getLoginStatus: (callback = @loginStatusHandler, force = false) ->
    @getUserData().always(callback) if @accessToken?

  loginStatusHandler: (response, status) =>
    if not response or status is 'error'
      @publishEvent 'logout'
    else
      @publishEvent 'serviceProviderSession', _.extend response,
        provider: this
        userId: response.id
        accessToken: @accessToken
      
      ###
      parsed = User::parse.call(null, response)
      @publishEvent 'serviceProviderSession', _.extend parsed,
        provider: this
        userId: response.id
        accessToken: @accessToken
      ###
