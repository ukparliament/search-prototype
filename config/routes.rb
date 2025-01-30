Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'welcome#index'
  get 'welcome' => 'welcome#index'
  get 'examples' => 'content_type_objects#index'
  get 'search' => 'search#index'
  get 'objects' => 'content_type_objects#show', as: 'object_show'
  get 'errors/500' => 'errors#internal_server_error'
  get 'errors/404' => 'errors#not_found'
  get 'errors/401' => 'errors#not_authorized'
end
