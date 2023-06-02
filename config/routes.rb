Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  
  get 'search-prototype/' => 'search#form', :as => 'home'
  get 'search-prototype/search' => 'search#form', :as => 'form'
  get 'search-prototype/results/:document_type' => 'search#results', :as => 'results'
  get 'search-prototype/objects/:object' => 'search#object', :as => 'object_show'
  
  get 'search-prototype/meta' => 'meta#index', :as => 'meta_list'
  get 'search-prototype/meta/about' => 'meta#about', :as => 'meta_about'
  get 'search-prototype/meta/coverage' => 'meta#coverage', :as => 'meta_coverage'
  get 'search-prototype/meta/contact' => 'meta#contact', :as => 'meta_contact'
  get 'search-prototype/meta/schema' => 'meta#schema', :as => 'meta_schema'
  get 'search-prototype/meta/adding-document-types' => 'meta#adding_document_types', :as => 'meta_adding_document_types'
end
