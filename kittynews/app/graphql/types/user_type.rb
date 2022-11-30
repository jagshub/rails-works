module Types
  class UserType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: false
    field :followees, [Types::UserType], null:true
    field :followers, [Types::UserType], null:true
    field :votes, [Types::VoteType], null: false, resolve: -> (user, args, ctx) do
      BatchLoader::GraphQL.for(user.id).batch(default_value: []) do |user_ids, loader|
        Vote.where(user_id: user_ids).each do |user|
          loader.call(user.id) { |u| u << user }
        end
      end
      end
  end
end
