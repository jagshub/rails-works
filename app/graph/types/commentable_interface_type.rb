# frozen_string_literal: true

module Graph::Types
  module CommentableInterfaceType
    include Graph::Types::BaseInterface

    graphql_name 'Commentable'

    field :id, ID, null: false
    field :can_comment, resolver: Graph::Resolvers::Can.build(:new) { |obj| Comment.new(subject: obj) }
    field :comments_count, Int, null: false
    field :name, String, null: false
    field :threads, Graph::Types::CommentType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Commentables::ThreadsResolver, null: false, connection: true

    # NOTE(ayrton) Not every model (eg AmaEvent) implements a `comments_count` counter cache.
    def comments_count
      object.respond_to?(:comments_count) ? object.comments_count : 0
    end

    def name
      Comments::Commentable.new(object).name
    end
  end
end
