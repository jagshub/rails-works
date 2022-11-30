# frozen_string_literal: true

module API::V2Internal::Mutations
  class PollAnswerDestroy < BaseMutation
    argument :option_id, ID, required: true, camelize: false

    returns API::V2Internal::Types::Poll::PollType

    def perform
      return error :base, :access_denied if current_user.nil?

      option = PollOption.find(inputs[:option_id])
      option.poll.answers.find_by(user_id: current_user)&.destroy
      option.poll
    end
  end
end
