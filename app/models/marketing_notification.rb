# frozen_string_literal: true

# == Schema Information
#
# Table name: marketing_notifications
#
#  id         :bigint(8)        not null, primary key
#  sender_id  :bigint(8)        not null
#  user_ids   :string           not null
#  heading    :string           not null
#  body       :string
#  one_liner  :string
#  deeplink   :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_marketing_notifications_on_sender_id  (sender_id)
#
# Foreign Keys
#
#  fk_rails_...  (sender_id => users.id)
#

class MarketingNotification < ApplicationRecord
  validates :sender_id, presence: true
  validates :user_ids, presence: true
  validates :heading, presence: true
end
