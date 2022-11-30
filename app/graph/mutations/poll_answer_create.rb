# frozen_string_literal: true

module Graph::Mutations
  class PollAnswerCreate < BaseMutation
    argument_record :option, PollOption, required: true

    require_current_user

    returns Graph::Types::Poll::PollType

    def perform(option:)
      HandleRaceCondition.call do
        create_answer_for(option)
      end

      option.poll
    end

    private

    def create_answer_for(option)
      answer = option.poll.answers.find_by user_id: current_user

      return if answer && answer.poll_option.id == option.id

      ActiveRecord::Base.connection.transaction do
        answer&.destroy!
        option.answers.create! user: current_user
      end
    end
  end
end
