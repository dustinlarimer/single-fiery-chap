config = require 'config'
Controller = require './base/controller'
User = require 'models/user'
Profile = require 'models/profile'

UserPageView = require 'views/user/user-page-view'
UserSettingsView = require 'views/user/user-settings-view'
UserSetupView = require 'views/user/user-setup-view'

module.exports = class UsersController extends Controller

  beforeAction: (params, route) ->
    super
    if route.action in ['settings']
      return @requireLogin(params, route)
      # Auth lookup in base controller

  initialize: ->
    super
    @profilesRef = Chaplin.mediator.firebase.child('profiles')
    @subscribeEvent 'userRegistered', @join


  show: (params) ->
    console.log 'UsersController#show', params
    @profilesRef.child(params.handle).once "value", (snapshot) =>
      if snapshot.val()?
        @model = new Profile snapshot.val()
        @view = new UserPageView { model: @model, region: 'main' }
      else
        console.log 'User does not exist'
        # @view = new UserUnavailableView { autoRender: true }

  settings: ->
    console.log 'UsersController#settings'
    _username = Chaplin.mediator.current_user.get('profile_id')    
    @profilesRef.child(_username).on "value", (snapshot) =>
      if snapshot.val()?
        @model = new Profile snapshot.val()
        @view = new UserSettingsView { model: @model, region: 'main' }
        @view.bind 'profile:update', (data) =>
          @profilesRef.child(_username).update 
            display_name: data.display_name
            location: data.location
            about: data.about
            url: data.url
          , (error) =>
            unless error?
              @redirectTo 'users#show', [_username]
            else
              alert 'error!' + error.message
  
  join: (params) ->
    console.log 'UsersController#join', params
    if !params.id?
      @redirectTo 'home#index'
      return false
    console.log 'Let\'s create a profile for User#' + params.id + ':'
    
    @model = new Profile {display_name: params.name, handle: params.handle}    
    @view = new UserSetupView {model: @model, region: 'main'}    
    @view.bind 'user:create', (data) =>
      newProfile = _.pick(params, 'location', 'thumbnail_url', 'url')
      newProfile.display_name = data.display_name
      newProfile.handle = data.handle
      newProfile.user_id = params.id
      
      _new = new Profile newProfile.handle
      _new.save newProfile,
        success: (model, response) =>
          console.log 'success', response
          Chaplin.mediator.current_user.save {profile_id: response.handle}
          @redirectTo 'home#index'
          #window.location = window.location.pathname
        error: (model, response) ->
          console.log 'error', response
          @view.render()
      @view.dispose()
    @view.render()
