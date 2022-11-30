# frozen_string_literal: true

module Graph::Mutations
  class FounderClubReferralDestroy < BaseMutation
    argument :email, String, required: true

    def perform(email:)
      ApplicationPolicy.authorize!(current_user, :destroy, :referral)
      result = FounderClub.remove_referral(email: email, invited_by: current_user)

      case result
      when :not_found then error :email, 'was not invited by you'
      when :already_claimed then error :referral, 'has been already claimed'
      else success
      end
    end
  end
end
