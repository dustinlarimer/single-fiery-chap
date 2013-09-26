config =
  development:
    firebase: 'https://single-fiery-chap.firebaseio.com'
    singly:
      singlyURL: 'https://api.singly.com'
      clientID: '<your-singly-clientID>'
      redirectURI: 'http://localhost:3333/auth-callback'
      providers: ['Facebook', 'Google', 'LinkedIn', 'Twitter']
  production:
    firebase: ''
    singly:
      singlyURL: 'https://api.singly.com'
      clientID: ''
      redirectURI: ''

switch window.location.hostname
  when '<your-production-domain>'
    env = "production"
  else env = "development"

module.exports = config[env]