# frozen_string_literal: true

module Graph::Types
  class MakersFestival::EditionType < BaseNode
    implements Graph::Types::DiscussableInterfaceType

    graphql_name 'MakersFestivalEdition'

    field :name, String, null: false
    field :slug, String, null: false
    field :tagline, String, null: false
    field :tagline_text, String, null: false, resolver_method: :tagline_text
    field :share_text, String, null: false, resolver_method: :share_text
    field :description, String, null: false
    field :prizes, String, null: false
    field :sponsor, String, null: true
    field :categories, [Graph::Types::MakersFestival::CategoryType], null: false
    field :period, String, null: false
    field :participant, Graph::Types::MakersFestival::ParticipantType, null: true
    field :timeline, Graph::Types::JsonType, null: false
    field :banner_uuid, String, null: true
    field :social_banner_uuid, String, null: true
    field :discussion_preview_uuid, String, null: true
    field :embed_url, String, null: true
    field :result_url, String, null: true
    field :showcase_posts, [Graph::Types::PostType], null: false
    field :maker_group, Graph::Types::MakerGroupType, null: true

    field :discussions,
          Graph::Types::Discussion::ThreadType.connection_type,
          resolver: Graph::Resolvers::Discussion::SearchResolver, null: false

    def tagline_text
      Sanitizers::HtmlToText.call object.tagline
    end

    def period
      ::MakersFestival::Utils.period object
    end

    def timeline
      ::MakersFestival::Utils.timeline_for_festival object
    end

    def participant
      current_user = context[:current_user]

      return if current_user.blank?

      ::MakersFestival::Participant.find_by(
        user: current_user,
        makers_festival_category_id: object.category_ids,
      )
    end

    def showcase_posts
      if object.slug == 'green-earth'
        ::Post.where(slug: ['big-green-company', 'climate-finder', 'ecocart', 'treecard', 'sliced', 'showyourstripes']).sample(5)
      elsif object.slug == 'snapchat'
        ::Post.where(slug: ['anchor-3-0', 'squad-5', 'wishupon-2-0', 'reddit-app', 'new-shazam']).shuffle
      elsif object.slug == 'wfh'
        ::Post.where(slug: ['the-coronavirus-shopping-list-generator', 'mask-match', 'self-quarantine-book-club', 'give-local', 'help-with-covid']).shuffle
      else
        []
      end
    end

    def share_text
      object.share_text || "Makers Festival #{ Sanitizers::HtmlToText.call(object.tagline) } is here! https://producthunt.com/makers-festival/#{ object.slug } via @ProductHunt #MakersFestival"
    end
  end
end
