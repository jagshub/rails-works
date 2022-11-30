# frozen_string_literal: true

module Graph::Types
  class NewsletterKindType < BaseEnum
    graphql_name 'NewsletterKind'

    ::Newsletter.kinds.keys.each do |kind|
      value kind
    end
  end

  class NewsletterSectionType < BaseObject
    graphql_name 'NewsletterSection'

    field :subtitle, String, null: true
    field :title, String, null: true
    field :content, String, null: true
    field :image_uuid, String, null: true
    field :url, String, null: true
    field :layout, String, null: false
    field :cta, String, null: true
    field :tracking_label, String, null: true
  end

  class NewsletterPostType < BaseObject
    graphql_name 'NewsletterPost'

    field :name, String, null: false
    field :tagline, String, null: false
    field :post, Graph::Types::PostType, null: false
  end

  class NewsletterType < BaseObject
    graphql_name 'Newsletter'

    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::ShareableInterfaceType

    field :id, ID, null: false
    field :subject, String, null: false
    field :slug, String, null: false
    field :sponsor_title, String, null: false
    field :date, Graph::Types::DateTimeType, null: true
    field :top_items, [Graph::Types::NewsletterPostType], null: false
    field :sections, [Graph::Types::NewsletterSectionType], null: false
    field :kind, Graph::Types::NewsletterKindType, null: false
    field :sponsor, resolver: Graph::Resolvers::Ads::Sponsor
    field :ad, resolver: Graph::Resolvers::Ads::NewsletterPost
    field :anthologies_story, Graph::Types::Anthologies::StoryType, null: true
    field :previous_newsletters, Graph::Types::NewsletterType.connection_type, max_page_size: 20, resolver: Graph::Resolvers::Newsletters, null: false, connection: true

    field :image_uuid, String, null: true

    def sections
      object.sections.sort
    end
  end
end
