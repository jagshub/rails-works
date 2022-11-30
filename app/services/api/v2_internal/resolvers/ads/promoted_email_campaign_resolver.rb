# frozen_string_literal: true

# NOTE(DZ): Need to remove from mobile
class API::V2Internal::Resolvers::Ads::PromotedEmailCampaignResolver < Graph::Resolvers::Base
  type API::V2Internal::Types::Ads::PromotedEmailCampaignType, null: true

  class PromotedTypes < Graph::Types::BaseEnum
    graphql_name 'PromotedEmailTypes'

    value 'SIGNUP_ONBOARDING'
    value 'HOMEPAGE'
  end

  argument :promoted_type, PromotedTypes, required: true, camelize: false

  def resolve(*)
    nil
  end
end
