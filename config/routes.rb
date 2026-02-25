Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  mount LibraryDesign::Engine => "/library_design"

  # Defines the root path route ("/")
  root 'welcome#index'
  get 'welcome' => 'welcome#index', as: :home

  get 'search' => 'search#index'
  get 'objects' => 'content_type_objects#show', as: 'object_show'

  get 'errors/500' => 'errors#internal_server_error'
  get 'errors/404' => 'errors#not_found'
  get 'errors/401' => 'errors#not_authorized'

  get 'examples' => 'meta#examples', as: :examples
  get 'meta' => 'meta#index', as: :meta_list
  get 'cookies' => 'meta#cookies', as: :meta_cookies
  get 'coverage' => 'meta#coverage', as: :coverage
  get 'backlog' => 'meta#backlog', as: :backlog
end
