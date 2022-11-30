# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_topic_associations
#
#  id               :integer          not null, primary key
#  upcoming_page_id :integer          not null
#  topic_id         :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  upcoming_page_topic_associations_upcoming_page_topic  (upcoming_page_id,topic_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (topic_id => topics.id)
#  fk_rails_...  (upcoming_page_id => upcoming_pages.id)
#

class UpcomingPageTopicAssociation < ApplicationRecord
  belongs_to :upcoming_page, optional: false
  belongs_to :topic, optional: false

  validates :topic_id, uniqueness: { scope: :upcoming_page_id }
end
