# frozen_string_literal: true

# == Schema Information
#
# Table name: link_trackers
#
#  id                 :integer          not null, primary key
#  post_id            :integer
#  user_id            :integer
#  track_code         :string(255)
#  ip_address         :string(255)
#  created_at         :datetime
#  updated_at         :datetime
#  via_application_id :integer
#
# Indexes
#
#  index_link_trackers_on_post_id     (post_id)
#  index_link_trackers_on_track_code  (track_code)
#  index_link_trackers_on_user_id     (user_id)
#

class LinkTracker < ApplicationRecord
  belongs_to :post, optional: true
  belongs_to :user, optional: true
  belongs_to :via_application, class_name: 'Doorkeeper::Application', optional: true

  before_validation :ensure_valid_application

  private

  def ensure_valid_application
    self.via_application_id = nil if via_application.blank?
  end
end
