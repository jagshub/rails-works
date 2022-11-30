# frozen_string_literal: true

# == Schema Information
#
# Table name: maker_reports
#
#  id                      :integer          not null, primary key
#  user_id                 :integer          not null
#  post_id                 :integer          not null
#  activity_created_after  :datetime         not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  activity_created_before :datetime         not null
#
# Indexes
#
#  index_maker_reports_on_post_id  (post_id)
#  index_maker_reports_on_user_id  (user_id)
#

class MakerReport < ApplicationRecord
  belongs_to :user, optional: false
  belongs_to :post, optional: false

  validates :activity_created_after, presence: true

  scope :reverse_chronological, -> { order(arel_table[:created_at].desc) }
end
