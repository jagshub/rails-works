# frozen_string_literal: true

# == Schema Information
#
# Table name: poll_answers
#
#  id             :bigint(8)        not null, primary key
#  poll_option_id :bigint(8)        not null
#  user_id        :bigint(8)        not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_poll_answers_on_poll_option_id_and_user_id  (poll_option_id,user_id) UNIQUE
#  index_poll_answers_on_user_id                     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (poll_option_id => poll_options.id)
#  fk_rails_...  (user_id => users.id)
#

class PollAnswer < ApplicationRecord
  extension RefreshExplicitCounterCache, :poll_option, :answers_count
  extension RefreshExplicitCounterCache, :poll, :answers_count

  belongs_to :poll_option, inverse_of: :answers
  belongs_to :user, inverse_of: :poll_answers

  delegate :poll, to: :poll_option

  validates :user_id, uniqueness: { scope: :poll_option }

  class << self
    def graphql_type
      Graph::Types::Poll::AnswerType
    end

    def graph_v2_internal_type
      Mobile::Graph::Types::Poll::PollType
    end
  end
end
