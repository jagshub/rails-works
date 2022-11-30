# frozen_string_literal: true

module Graph::Mutations
  class Dismiss < BaseMutation
    argument :dismissable_group, String, required: true
    argument :dismissable_key, String, required: true

    returns Graph::Types::DismissType

    def perform(dismissable_group:, dismissable_key:)
      DismissContent.call(cookies: context[:cookies], dismissable_group: dismissable_group, dismissable_key: dismissable_key, user: current_user)
    end
  end
end
