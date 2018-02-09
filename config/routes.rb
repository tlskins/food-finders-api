Rails.application.routes.draw do
  devise_for :users, defaults: { format: 'json' }, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    confirmations: 'users/confirmations',
    passwords: 'users/passwords'
  }
  resources :users, except: :create do
    get 'newsfeed', on: :member
    get 'match_relationships', on: :member
    post 'publish_draft_social_entry', on: :member
  end
  resources :tags
  resources :entities
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'yelp_search', to: 'yelp#search'
end
