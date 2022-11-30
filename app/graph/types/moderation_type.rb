# frozen_string_literal: true

module Graph::Types
  class ModerationType < BaseObject
    field :post_queue,
          PostType.connection_type,
          max_page_size: 20,
          resolver: Graph::Resolvers::Moderation::PostsResolver, null: false

    field :seo_posts,
          PostType.connection_type,
          max_page_size: 20,
          resolver: Graph::Resolvers::Moderation::SeoPostsResolver, null: false

    field :seo_structured_data_validation,
          Seo::StructuredData::ValidationMessageType.connection_type,
          max_page_size: 20,
          resolver: Graph::Resolvers::Moderation::SeoStructuredDataValidationResolver, null: false

    field :duplicate_post_request,
          Graph::Types::ModerationDuplicatePostType.connection_type,
          null: false,
          connection: true,
          max_page_size: 20

    def duplicate_post_request
      ::Moderation::DuplicatePostRequest
        .where(approved_at: nil)
        .order(:created_at)
    end

    field :team_claims,
          Team::RequestType.connection_type,
          max_page_size: 20,
          resolver: Graph::Resolvers::Moderation::TeamClaimsResolver,
          null: false

    field :upcoming_events,
          resolver: Graph::Resolvers::Moderation::UpcomingEventsResolver,
          max_page_size: 20

    field :discussions,
          Discussion::ThreadType.connection_type,
          max_page_size: 40,
          resolver: Graph::Resolvers::Moderation::DiscussionsResolver, null: false

    field :product_associations,
          resolver: Graph::Resolvers::Moderation::ProductAssociationsResolver,
          null: false,
          max_page_size: nil

    field :reverse_product_associations,
          resolver: Graph::Resolvers::Moderation::ReverseProductAssociationsResolver,
          null: false,
          max_page_size: nil

    field :product_association_suggestions,
          [Graph::Types::ProductType],
          null: false do
      argument :product_id, ID, required: true
    end

    def product_association_suggestions(product_id:)
      product = Product.find_by(id: product_id)
      return [] if product.nil?

      ::Moderation.product_association_suggestions(product: product)
    end

    field :product_association_search,
          resolver: Graph::Resolvers::Moderation::ProductAssociationSearchResolver,
          null: false

    field :reverse_product_association_search,
          resolver: Graph::Resolvers::Moderation::ReverseProductAssociationSearchResolver,
          null: false

    field :post_status, Graph::Types::ModerationPostStatusType, null: true do
      argument :post_id, ID, required: true
    end

    def post_status(post_id:)
      Post.find_by(id: post_id)
    end

    field :flags,
          FlagType.connection_type,
          resolver: Graph::Resolvers::Moderation::FlagsResolver,
          null: false

    field :flags_stats,
          ModerationFlagsStatsType,
          resolver: Graph::Resolvers::Moderation::FlagsStatsResolver,
          null: false
  end
end
