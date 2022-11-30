# frozen_string_literal: true

module Graph::Types
  class Ads::NewsletterType < BaseNode
    graphql_name 'AdNewsletter'

    field :post, PostType, null: true

    field :name, String, null: false
    field :tagline, String, null: false
    field :thumbnail_uuid, String, null: false
    field :url, String, null: false

    def name
      return object.name if object.instance_of? ::Ads::Newsletter

      object.newsletters_title
    end

    def tagline
      return object.tagline if object.instance_of? ::Ads::Newsletter

      object.newsletter_description
    end

    def thumbnail_uuid
      return object.thumbnail_uuid if object.instance_of? ::Ads::Newsletter

      object.newsletter_image
    end

    # TODO(DZ): N+1
    def post
      return object.budget.campaign.post if object.instance_of? ::Ads::Newsletter

      object.post
    end

    def url
      redirect = Routes.ads_newsletter_redirect_url(object)
      return redirect if object.instance_of? ::Ads::Newsletter

      object.build_short_url 'newsletter'
    end
  end
end
