Rails.application.routes.draw do
  resources :sources
  resources :translations
  root to: 'sources#index'
end
