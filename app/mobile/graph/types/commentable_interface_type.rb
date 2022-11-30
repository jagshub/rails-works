# frozen_string_literal: true

module Mobile::Graph::Types
  module CommentableInterfaceType
    include Mobile::Graph::Types::BaseInterface

    graphql_name 'Commentable'

    field :id, ID, null: false
    field :can_comment, resolver: Mobile::Graph::Utils::CanResolver.build(:new) { |obj| Comment.new(subject: obj) }
    field :comments_count, Int, null: false
    field :commenters, Mobile::Graph::Types::UserType.connection_type, null: false, connection: true
    field :comments, Mobile::Graph::Types::CommentType.connection_type, resolver: Mobile::Graph::Resolvers::Commentables::Comments

    def comments_count
      object.respond_to?(:comments_count) ? object.comments_count : 0
    end

    def commenters
      user_ids = object.comments.visible.pluck(:user_id).uniq

      scope = User.where(id: user_ids)
      scope = scope.where.not(id: current_user.id).order_by_friends(current_user) if current_user.present?
      scope
    end
  end
end
