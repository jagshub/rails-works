# frozen_string_literal: true

# == Schema Information
#
# Table name: poll_options
#
#  id            :bigint(8)        not null, primary key
#  poll_id       :bigint(8)        not null
#  text          :string           not null
#  image_uuid    :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  answers_count :integer          default(0), not null
#
# Indexes
#
#  index_poll_options_on_poll_id  (poll_id)
#
# Foreign Keys
#
#  fk_rails_...  (poll_id => polls.id)
#

class PollOption < ApplicationRecord
  include ExplicitCounterCache

  belongs_to :poll, inverse_of: :options, counter_cache: :options_count

  has_many :answers, class_name: 'PollAnswer', dependent: :destroy, inverse_of: :poll_option

  validates :text, presence: true, length: { maximum: 255, allow_blank: false }
  validates :text, uniqueness: { scope: :poll_id }

  explicit_counter_cache :answers_count, -> { answers }
end
