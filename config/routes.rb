Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  mount LibraryDesign::Engine => "/library_design"

  # Defines the root path route ("/")
  root 'welcome#index'
  get 'welcome' => 'welcome#index', as: :home
  get 'search' => 'search#index'
  get 'objects' => 'content_type_objects#show', as: 'object_show'
  get 'meta' => 'meta#index', as: :meta_list
  get 'meta/cookies' => 'meta#cookies', as: :meta_cookies
  get 'meta/coverage' => 'meta#coverage', as: :meta_coverage
  get 'meta/examples' => 'meta#examples', as: :meta_examples
  get 'meta/librarian-tools' => 'meta#librarian_tools', as: :meta_librarian_tools
  get 'meta/roadmap' => 'meta#roadmap', as: :meta_roadmap

  # Error routing enabled
  # Bespoke error pages
  match "403", to: "errors#forbidden", via: [:get, :post]
  match "404", to: "errors#not_found", via: [:get, :post]
  match "500", to: "errors#internal_server_error", via: [:get, :post]

  # Catch-all route for unknown paths & errors without a bespoke page
  match "*path", to: "errors#not_found", via: :all
end
