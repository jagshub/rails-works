# frozen_string_literal: true

module API::V2Internal::Mutations
  class UserConfirmAge < BaseMutation
    returns API::V2Internal::Types::ViewerType

    def perform
      return error :base, :access_denied if current_user.nil?

      current_user.update!(confirmed_age: true) unless current_user.confirmed_age

      current_user
    end
  end
end
