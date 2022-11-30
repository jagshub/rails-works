# frozen_string_literal: true

# NOTE(DZ): Need to remove from mobile
module API::V2Internal::Mutations
  class PromotedEmailSignupCreate < BaseMutation
    node :campaign, type: PromotedEmail::Campaign

    argument :email, String, required: false, camelize: false
    argument :ab_test_name, String, required: false, camelize: false

    returns API::V2Internal::Types::Ads::PromotedEmailCampaignType

    def perform
      email = inputs[:email] || current_user&.subscriber&.email
      return error :email, :blank if email.blank?

      node
    end
  end
end
