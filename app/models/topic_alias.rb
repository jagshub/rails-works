# frozen_string_literal: true

# == Schema Information
#
# Table name: topic_aliases
#
#  id         :integer          not null, primary key
#  topic_id   :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_topic_aliases_on_name         (name) USING gin
#  index_topic_aliases_on_name_unique  (name) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (topic_id => topics.id)
#

class TopicAlias < ApplicationRecord
  extension(
    Search.searchable_association,
    association: :topic,
    if: :saved_change_to_name?,
  )

  belongs_to :topic, inverse_of: :aliases

  validates :name, presence: true, uniqueness: { case_sensitive: false }

  before_save :downcase_name

  private

  def downcase_name
    self.name = name.downcase if name
  end
end
