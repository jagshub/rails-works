# frozen_string_literal: true

module Graph::Mutations
  class ProfileHeaderSync < BaseMutation
    argument :medium, String, required: true

    def perform(medium:)
      Users.sync_header(current_user, medium: medium, overwrite: true) if current_user
      nil
    end
  end
end
