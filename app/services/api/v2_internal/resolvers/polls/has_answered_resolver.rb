# frozen_string_literal: true

class API::V2Internal::Resolvers::Polls::HasAnsweredResolver < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false if current_user.blank?

    AnswersLoader.for(current_user).load(object)
  end

  class AnswersLoader < GraphQL::Batch::Loader
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
