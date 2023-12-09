class UsersAPI < Grape::API
  resource :users do
    params do
      optional :sort, type: String, default: 'created_at'
    end
    get do
     User.all
    end
  end
end
