# frozen_string_literal: true

module Graph::Mutations
  class PollAnswerDestroy < BaseMutation
    argument_record :option, PollOption, required: true

    returns Graph::Types::Poll::PollType

    require_current_user

    def perform(option:)
      option.poll.answers.find_by(user_id: current_user)&.destroy!
      option.poll
    end
  end
end
