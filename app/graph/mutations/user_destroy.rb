# frozen_string_literal: true

module Graph::Mutations
  class UserDestroy < BaseMutation
    argument :reason, String, required: false
    argument :feedback, String, required: false

    returns Graph::Types::UserType

    require_current_user

    def perform(inputs)
      ApplicationPolicy.authorize!(current_user, :destroy, current_user)

      form = Users::DestroyForm.new(current_user)
      form.update inputs
      form
    end
  end
end
