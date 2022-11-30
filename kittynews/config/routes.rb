Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  post "/graphql", to: "graphql#execute"

  devise_for :users

  resources :posts, only: %(show)
  resources :user, only: %(edit)

  root to: 'posts#index'
end
