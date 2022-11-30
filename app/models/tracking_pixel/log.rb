# frozen_string_literal: true

# == Schema Information
#
# Table name: tracking_pixel_logs
#
#  id              :bigint(8)        not null, primary key
#  kind            :integer          not null
#  host            :string           not null
#  url             :string           not null
#  last_seen_at    :datetime         not null
#  embeddable_type :string           not null
#  embeddable_id   :bigint(8)        not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_kind_and_host_and_e_type_and_e_id                         (kind,host,embeddable_type,embeddable_id) UNIQUE
#  index_tracking_pixel_logs_on_embeddable_type_and_embeddable_id  (embeddable_type,embeddable_id)
#

class TrackingPixel::Log < ApplicationRecord
  include Namespaceable

  belongs_to :embeddable, polymorphic: true

  enum kind: %i(upcoming_widget default_post_badge featured_post_badge top_post_badge golden_kitty_badge review_post_badge top_post_topic_badge)

  validates :kind, presence: true
  validates :host, presence: true
  validates :url, presence: true
  validates :embeddable_type, presence: true
  validates :embeddable_id, presence: true
  validates :last_seen_at, presence: true
  validates :host, uniqueness: { scope: %i(kind embeddable_type embeddable_id) }

  scope :by_fresh, -> { where('last_seen_at >= ?', 30.days.ago) }
end
