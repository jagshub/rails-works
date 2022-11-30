# frozen_string_literal: true

# NOTE(DZ): Need to remove from mobile
module API::V2Internal::Types
  class Ads::PromotedEmailCampaignType < BaseNode
    graphql_name 'AdPromotedEmailCampaign'

    implements GraphQL::Types::Relay::Node

    field :title, String, null: false
    field :tagline, String, null: false
    field :cta_text, String, null: true
    field :thumbnail_url, String, null: false
    field :promoted_type, String, null: false
    field :variant, String, null: true
    field :ab_test_name, String, null: true

    def title
      get_ab_variant_data(:title)
    end

    def tagline
      get_ab_variant_data(:tagline)
    end

    def thumbnail_url
      get_ab_variant_data(:thumbnail_url)
    end

    def cta_text
      get_ab_variant_data(:cta_text)
    end

    def ab_test_name
      ab_test = object.promoted_email_ab_test
      return if ab_test.blank?

      "email_capture_#{ ab_test.id }"
    end

    def variant
      return unless object.signup_onboarding?

      context[:current_user].subscriber.email? ? 'checkbox' : 'emailInput'
    end

    private

    def get_ab_variant_data(field)
      record = object.ab_variant.presence || object

      record.send(field)
    end
  end
end
