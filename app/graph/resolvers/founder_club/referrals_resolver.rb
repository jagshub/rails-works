# frozen_string_literal: true

module Graph::Resolvers
  class FounderClub::ReferralsResolver < Graph::Resolvers::Base
    class ReferralType < Graph::Types::BaseObject
      graphql_name 'FounderClubReferral'

      field :email, String, null: false
      field :invite_code, String, null: false
      field :has_accepted, Boolean, null: false
      field :user, Graph::Types::UserType, null: true

      def has_accepted
        object.used_code? || object.subscribed?
      end
    end

    type [ReferralType], null: false

    def resolve
      return [] if current_user.blank?

      current_user.founder_club_referrals
    end
  end
end
