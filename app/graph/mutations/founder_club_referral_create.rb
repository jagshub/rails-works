# frozen_string_literal: true

module Graph::Mutations
  class FounderClubReferralCreate < BaseMutation
    argument :email, String, required: false

    def perform(email: nil)
      ApplicationPolicy.authorize!(current_user, :create, :referral)

      result = FounderClub.add_referral(email: email, invited_by: current_user)

      case result
      when :already_added then error :email, 'is already invited'
      when FounderClub::AccessRequest then success
      else raise "invalid result #{ result }"
      end
    end
  end
end
