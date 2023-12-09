class UsersAPI < Grape::API
  resource :users do
    params do
      optional :sort, type: String, default: 'created_at'
    end
    get do
      @articles = Article.all
      # {"test": "test"}
      @articles
    end
  end
end
