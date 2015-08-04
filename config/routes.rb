Rails.application.routes.draw do
  match "sources/update_by_text_and_lang" => "sources#update_by_text_and_lang", via: [:put, :patch]
  resources :sources

  root to: 'sources#index'
end
