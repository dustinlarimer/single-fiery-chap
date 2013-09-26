config = require 'config'
utils = require 'lib/utils'
View = require 'views/base/view'

module.exports = class LoggingInView extends View
  template: require './templates/logging-in'
  autoRender: true