# frozen_string_literal: true

Rails.application.routes.draw do
  get '/accounts/:id/balance', to: 'accounts#balance'
  post '/accounts', to: 'accounts#create'
  post '/accounts/transfer', to: 'transfers#create'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
