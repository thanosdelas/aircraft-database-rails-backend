Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  root "login#index"
  post "/" => "login#create", :as => :create_session
  get "/user" => "user#show", :as => :user_page
  get "/logout" => "user#delete"

  # API Routes
  mount BaseAPI, at: '/'
end
