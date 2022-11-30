# frozen_string_literal: true

module Graph::Mutations
  class ModerationFlagResolve < BaseMutation
    argument_record :flag, Flag, authorize: :moderate

    returns Graph::Types::FlagType

    def perform(flag:)
      Flags.resolve_by_moderator flag: flag, moderator: current_user
    end
  end
end
