# frozen_string_literal: true

module Graph::Types
  class Poll::PollOptionType < BaseObject
    field :id, ID, null: false
    field :text, String, null: false
    field :image_uuid, String, null: true
    field :answers_count, Integer, null: false
    field :answers_percent, Float, null: false
    field :has_answered, Boolean, null: false, resolver: Graph::Resolvers::Polls::HasAnsweredResolver

    def answers_percent
      return 0 if object.poll.answers_count == 0

      (object.answers_count.to_f / object.poll.answers_count.to_f).round(2) * 100
    end
  end
end
