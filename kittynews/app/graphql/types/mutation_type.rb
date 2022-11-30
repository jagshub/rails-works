module Types
  class MutationType < Types::BaseObject
    # NOTE(rstankov): More about mutations - http://graphql-ruby.org/mutations/mutation_classes.html#example-mutation-class
    
    field :user_update, mutation: Mutations::UserUpdate
    field :up_vote, mutation: Mutations::CreateVote
    field :down_vote, mutation: Mutations::RemoveVote
    field :add_comment, mutation: Mutations::AddComment
  end
end
