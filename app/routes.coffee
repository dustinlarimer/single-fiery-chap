module.exports = (match) ->
  match '', 'home#index'
  match 'auth-callback', 'auth#callback'
  match 'login', 'auth#login'
  match 'logout', 'auth#logout'
  match 'settings', 'users#settings'
  match 'join', 'users#join'
  match ':handle', 'users#show'