# frozen_string_literal: true

module Graph::Mutations
  class FounderClubInviteCodeEnter < BaseMutation
    argument :code, String, required: false

    returns String

    require_current_user

    def perform(code: nil)
      result = FounderClub.accept_referral_code(code)
      case result
      when :success then code
      else error :code, result
      end
    end
  end
end
