# frozen_string_literal: true

module API::V2::Types
  class QueryType < BaseObject
    description 'The query root for Product Hunt API V2 schema'

    field :collection, CollectionType, 'Look up a Collection(only published).', resolver: API::V2::Resolvers::SlugOrIdResolver.for(Collection.published)
    field :collections, CollectionType.connection_type, 'Look up Collections by various parameters.', null: false, resolver: API::V2::Resolvers::Collections::SearchResolver

    field :comment, CommentType, 'Look up a Comment.', resolver: API::V2::Resolvers::FindByIdResolver.for(Comment)

    field :goal, GoalType, 'Look up a Goal.', resolver: API::V2::Resolvers::FindByIdResolver.for(Goal)
    field :goals, GoalType.connection_type, 'Look up Goals by various parameters.', null: false, resolver: API::V2::Resolvers::Goals::SearchResolver

    field :maker_group, MakerGroupType, 'Look up a MakerGroup.', resolver: API::V2::Resolvers::FindByIdResolver.for(MakerGroup)
    field :maker_groups, MakerGroupType.connection_type, 'Look up MakerGroups by various parameters.', null: false, resolver: API::V2::Resolvers::MakerGroups::SearchResolver

    field :post, PostType, 'Look up a Post.', resolver: API::V2::Resolvers::SlugOrIdResolver.for(Post.not_trashed)
    field :posts, PostType.connection_type, 'Look up Posts by various parameters.', null: false, resolver: API::V2::Resolvers::Posts::SearchResolver

    field :topic, TopicType, 'Look up a Topic.', resolver: API::V2::Resolvers::SlugOrIdResolver.for(Topic)
    field :topics, TopicType.connection_type, 'Look up Topics by various parameters.', null: false, resolver: API::V2::Resolvers::Topics::SearchResolver

    field :user, UserType, 'Look up a User.', resolver: API::V2::Resolvers::UserResolver

    field :viewer, ViewerType, 'Top level scope for currently authenticated user. Includes `goals`, `makerGroups`, `makerProjects` & `user` fields.', null: true

    def viewer
      current_user if private_scope_allowed?
    end
  end
end
