# frozen_string_literal: true

module API::V2Internal::Mutations
  class PollAnswerCreate < BaseMutation
    argument :option_id, ID, required: false, camelize: false

    returns API::V2Internal::Types::Poll::PollType

    def perform
      return error :base, :access_denied if current_user.nil?

      option = PollOption.find inputs[:option_id]

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
