# frozen_string_literal: true

module Graph::Mutations
  class ModerationUserMarkAsCompany < BaseMutation
    argument_record :user, User, authorize: :moderate, required: true

    returns Boolean

    def perform(user:)
      return error :id, 'User not found.' if user.blank?
      return true if user.company?

      Spam::SpamUserWorker.perform_later(
        {
          user: user,
          kind: 'manual',
          level: 'spammer',
          current_user: current_user,
          remarks: "User is marked as company by #{ current_user.username }",
        },
        role: 'company',
        actions: %w(mark_votes remove_product_makers),
      )
      UserMailer.company_account(user).deliver_later

      true
    end
  end
end
