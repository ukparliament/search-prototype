Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  
  get 'search' => 'search#form', :as => 'form'
  get 'results' => 'search#results', :as => 'results'
end
