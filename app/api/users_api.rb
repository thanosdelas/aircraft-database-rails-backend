class UsersAPI < Grape::API
  resource :users do
    get do
      User.all
    end
  end
end
