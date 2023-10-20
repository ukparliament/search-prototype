Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'content_objects#index'

  get 'search-prototype/search' => 'search#form', :as => 'form'
  get 'search-prototype/results/:document_type' => 'search#results', :as => 'results'
  get 'search-prototype/objects' => 'content_objects#show', :as => 'object_show'
  
  get 'search-prototype/meta' => 'meta#index', :as => 'meta_list'
  get 'search-prototype/meta/about' => 'meta#about', :as => 'meta_about'
  get 'search-prototype/meta/coverage' => 'meta#coverage', :as => 'meta_coverage'
  get 'search-prototype/meta/contact' => 'meta#contact', :as => 'meta_contact'
end
