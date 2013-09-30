config = require 'config'
utils = require 'lib/utils'
Singly = require 'lib/services/singly'
Controller = require 'controllers/base/controller'

Users = require 'models/users'
User = require 'models/user'
#Profile = require 'models/profile'

LoginView = require 'views/login-view'
LoggingInView = require 'views/logging-in-view'

module.exports = class SessionController extends Controller
  # Service provider instances as static properties
  # This just hardcoded here to avoid async loading of service providers.
  # In the end you might want to do this.
  @serviceProviders = {
    singly: new Singly()
    # facebook: new Facebook()
  }

  # Was the login status already determined?
  loginStatusDetermined: false

  # This controller governs the LoginView
  loginView: null

  # Current service provider
  serviceProviderName: null

  redirect: null

  initialize: ->
        
    # Login flow events
    @subscribeEvent 'serviceProviderSession', @serviceProviderSession

    # Handle login
    @subscribeEvent 'logout', @logout
    #@subscribeEvent 'userData', @userData

    # Handler events which trigger an action
    @subscribeEvent 'setTokens', @setTokens

    # Show the login dialog
    @subscribeEvent '!showLogin', @showLoginView
    # Try to login with a service provider
    @subscribeEvent '!login', @triggerLogin
    # Initiate logout
    @subscribeEvent '!logout', @triggerLogout

    # Session User Loaded
    @subscribeEvent 'userLoaded', @publishLogin

    # Determine the logged-in state
    @getSession()

  setTokens: (params) =>
    #console.log 'setting tokens...'
    localStorage.setItem 'accessToken', params.access_token
    localStorage.setItem 'firebaseToken', params.firebase

  getTokens: ->
    tokens=
      accessToken: localStorage.getItem 'accessToken'
      firebaseToken: localStorage.getItem 'firebaseToken'
    return tokens
  
  removeTokens: =>
    localStorage.removeItem 'accessToken'
    localStorage.removeItem 'firebaseToken'

  # Load the libraries of all service providers
  loadServiceProviders: ->
    for name, serviceProvider of SessionController.serviceProviders
      serviceProvider.load()

  # Try to get an existing session from one of the login providers
  getSession: ->
    @loadServiceProviders()
    for name, serviceProvider of SessionController.serviceProviders
      serviceProvider.done serviceProvider.getLoginStatus

  # Handler for the global !showLogin event
  showLoginView: (redirect_data) ->
    return if @loginView
    @loadServiceProviders()

    @redirect = params: redirect_data.params, route: redirect_data.route if redirect_data?
    if @redirect.params? or @redirect.route?
      return @loginView = new LoggingInView region: 'main' if @getTokens()?
    @loginView = new LoginView region: 'main', serviceProviders: SessionController.serviceProviders


  # Handler for the global !login event
  # Delegate the login to the selected service provider
  triggerLogin: (serviceProviderName) =>

    # Publish a global loginAttempt event
    @publishEvent 'loginAttempt', serviceProviderName

    # Delegate to service provider
    SessionController.serviceProviders.singly.triggerLogin(serviceProviderName)

  # Handler for the global serviceProviderSession event
  serviceProviderSession: (session) =>
    # Save the session provider used for login
    @serviceProviderName = session.provider.name

    # Hide the login view
    @disposeLoginView() if @redirect?.route?

    # Transform session into user attributes and create a user
    session.id = session.userId
    delete session.userId
    
    @authenticateFirebase session

  authenticateFirebase: (session) =>
    firebase_token = @getTokens().firebaseToken
    Chaplin.mediator.firebase.auth firebase_token, (err, authData) =>
        unless err
          @findOrCreateUser session
        else
          @redirectTo 'auth#login', [err.message]

  findOrCreateUser: (session) =>
    console.log 'SessionController#findOrCreateUser', session
    
    # Grab the attributes you want for this user's record...
    newUser = _.pick(session, 'id', 'email')
    
    Chaplin.mediator.users = new Users
    Chaplin.mediator.current_user = new User newUser
    
    Chaplin.mediator.users.add Chaplin.mediator.current_user
    Chaplin.mediator.users.sync 'update', Chaplin.mediator.current_user,
      success: (model, response) =>
        Chaplin.mediator.users.fetch 
          success: (model, response) => 
            unless Chaplin.mediator.current_user.get('profile_id')?
              @redirectTo 'users#join', session
            @publishLogin()
      error: (model, response) =>
        console.log 'Error! ', model


  # Publish an event to notify all application components of the login
  publishLogin: ->
    @loginStatusDetermined = true

    # Publish a global login event passing the user
    @publishEvent 'login', Chaplin.mediator.current_user
    @publishEvent 'loginStatus', true
    
    if @redirect?.route?
      @redirectTo @redirect.route.name, @redirect.params
    #@redirectTo @redirect.route.name if @redirect?.route?

  # Logout
  # ------

  # Handler for the global !logout event
  triggerLogout: ->
    # Just publish a logout event for now
    @publishEvent 'logout'

  # Handler for the global logout event
  logout: =>
    @removeTokens()
    @loginStatusDetermined = true
    @disposeUser()

    # Discard the login info
    @serviceProviderName = null

    # Show the login view again
    # @showLoginView()

    @publishEvent 'loginStatus', false

  
  # Disposal
  # --------

  disposeLoginView: ->
    return unless @loginView
    @loginView.dispose()
    @loginView = null

  disposeUser: ->
    return unless Chaplin.mediator.current_user
    # Dispose the user model
    Chaplin.mediator.current_user.dispose()
    # Nullify property on the mediator
    Chaplin.mediator.current_user = null