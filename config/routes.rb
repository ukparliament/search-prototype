Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'content_objects#index'

  get 'search' => 'search#form', :as => 'form'
  get 'results/:document_type' => 'search#results', :as => 'results'
  get 'objects' => 'content_objects#show', :as => 'object_show'
  
  get 'meta' => 'meta#index', :as => 'meta_list'
  get 'meta/about' => 'meta#about', :as => 'meta_about'
  get 'meta/coverage' => 'meta#coverage', :as => 'meta_coverage'
  get 'meta/contact' => 'meta#contact', :as => 'meta_contact'
end
