# frozen_string_literal: true

module Mobile::Graph::Mutations
  class FlagCreate < BaseMutation
    argument_record :subject, Flag::SUBJECTS, required: true
    argument :reason, Mobile::Graph::Types::FlagReasonEnumType, required: true

    def perform(subject:, reason:)
      form = Flags.create_form(user: current_user, subject: subject)
      form.update! reason: reason

      nil
    end
  end
end
