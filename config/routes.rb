Rails.application.routes.draw do

  resources :best_awards
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get "yelp_search", to: "yelp#search"

end
