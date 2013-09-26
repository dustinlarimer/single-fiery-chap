PageView = require '../base/view'

module.exports = class UserSetupView extends PageView
  containerMethod: 'html'
  template: require './templates/user-setup'
  
  initialize: ->
    super
    @delegate 'click', 'button', @sendForm
    #console.log @model
  
  sendForm: =>
    data=
      display_name: @$('input#display_name').val()
      handle: @$('input#handle').val()
    @trigger 'user:create', data