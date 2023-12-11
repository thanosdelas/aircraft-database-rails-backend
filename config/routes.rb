Rails.application.routes.draw do
  root "login#index"

  namespace :admin do
    root "admin#index", controller: '/admin'
    resources :users, only: [:index, :show, :new, :create, :destroy]
  end

  get "admin", to: "admin#index", module: :admin
  post "/" => "login#create", :as => :create_session
  get "/user" => "user#show", :as => :user_page
  get "/logout" => "user#delete"

  # API Routes
  mount BaseAPI, at: '/'
end
