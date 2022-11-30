# frozen_string_literal: true

module API::V2Internal::Mutations
  class FlagCreate < BaseMutation
    class ReasonEnumType < API::V2Internal::Types::BaseEnum
      graphql_name 'FlagReasonEnum'

      Flag.reasons.each do |reason, _k|
        value reason, reason.humanize
      end
    end

    argument :reason, ReasonEnumType, required: true

    node :flaggable

    def perform
      form = Flags.create_form(user: current_user, subject: node)
      form.update! reason: inputs[:reason]

      nil
    end
  end
end
