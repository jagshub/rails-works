# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class Poll::HasAnswered < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(options)
      answered_ids = @user.poll_answers.where(poll_option_id: options.map(&:id)).pluck(:poll_option_id)

      options.each do |option|
        fulfill option, answered_ids.include?(option.id)
      end
    end
  end
end
