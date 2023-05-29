Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  
  get 'search-prototype/search' => 'search#form', :as => 'form'
  get 'search-prototype/results' => 'search#results', :as => 'results'
  get 'search-prototype/objects/:object' => 'search#object', :as => 'object_show'
end
