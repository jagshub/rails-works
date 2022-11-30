# frozen_string_literal: true

# == Schema Information
#
# Table name: upcoming_page_subscriber_searches
#
#  id               :integer          not null, primary key
#  upcoming_page_id :integer          not null
#  name             :string           not null
#  filters          :jsonb            not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_upcoming_page_subscriber_searches_on_upcoming_page_id  (upcoming_page_id)
#
# Foreign Keys
#
#  fk_rails_...  (upcoming_page_id => upcoming_pages.id)
#

class UpcomingPageSubscriberSearch < ApplicationRecord
  belongs_to :upcoming_page, optional: false

  validates :name, presence: true
end
