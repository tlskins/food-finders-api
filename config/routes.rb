Rails.application.routes.draw do
  resources :tags
  resources :social_entries
  resources :hashtags
  resources :votes
  resources :users do
    get 'newsfeed', on: :member
    post 'publish_draft_social_entry', on: :member
  end
  resources :entities
  resources :foods
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get 'yelp_search', to: 'yelp#search'
end
