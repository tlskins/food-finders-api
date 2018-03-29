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
    put 'update_relationship', on: :member
    post 'publish_draft_social_entry', on: :member
  end
  resources :hierarchy_trees, only: :index
  resources :tags do
    get 'all_roots', on: :collection
  end
  resources :entities do
    get 'yelp_businesses_search', on: :collection
    get 'yelp_businesses', on: :collection
  end
  resources :food_rating_metrics
  resources :food_rating_types
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
