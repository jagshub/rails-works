# frozen_string_literal: true

module Graph::Mutations
  class TeamInviteCreate < BaseMutation
    argument_record :product, Product, required: true, authorize: :edit
    argument :username, String, required: false

    returns Graph::Types::Team::InviteType

    require_current_user

    def perform(product:, username: '')
      user = User.find_by_username(username.to_s.strip)

      return error :user, 'We could not find this user.' if user.blank?

      Teams.invite_create(
        product: product,
        user: user,
        referrer: current_user,
      )
    rescue Teams::Invites::CreateError => e
      error :user, e.message
    end
  end
end
