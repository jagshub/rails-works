# frozen_string_literal: true

class Graph::Resolvers::Polls::HasAnsweredPollResolver < Graph::Resolvers::Base
  type Boolean, null: false

  def resolve
    return false if current_user.blank?

    AnswersLoader.for(current_user).load(object)
  end

  class AnswersLoader < GraphQL::Batch::Loader
    def initialize(user)
      @user = user
    end

    def perform(polls)
      answered_ids = @user
                     .poll_answers
                     .joins(:poll_option)
                     .where('poll_options.poll_id in (?)', polls.pluck(:id))
                     .pluck(Arel.sql('DISTINCT poll_options.poll_id'))

      polls.each do |poll|
        fulfill poll, answered_ids.include?(poll.id)
      end
    end
  end
end
