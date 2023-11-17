Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'content_objects#index'

  get 'search' => 'search#index'
  get 'objects' => 'content_objects#show', as: 'object_show'
end
