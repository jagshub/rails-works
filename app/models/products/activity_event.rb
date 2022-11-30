# frozen_string_literal: true

# == Schema Information
#
# Table name: product_activity_events
#
#  id                :bigint(8)        not null, primary key
#  product_id        :bigint(8)        not null
#  subject_type      :string           not null
#  subject_id        :bigint(8)        not null
#  occurred_at       :datetime         not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  votes_count       :integer          default(0), not null
#  comments_count    :integer          default(0), not null
#  nominations_count :integer          default(0), not null
#  title             :string
#
# Indexes
#
#  index_product_activities_unique           (product_id,subject_type,subject_id) UNIQUE
#  index_product_activity_events_on_subject  (subject_type,subject_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class Products::ActivityEvent < ApplicationRecord
  self.table_name = 'product_activity_events'

  SUBJECTS = [
    Post,
    Badges::TopPostBadge,
    Badges::GoldenKittyAwardBadge,
    Products::ReviewSummary,
    Anthologies::Story,
  ].freeze

  belongs_to :product, inverse_of: :activity_events
  belongs_to_polymorphic :subject, allowed_classes: SUBJECTS

  def self.order_for_feed
    badges_first = <<~SQL
      (
        CASE subject_type
        WHEN 'Badges::TopPostBadge'          THEN 1
        WHEN 'Badges::GoldenKittyAwardBadge' THEN 2
        WHEN 'Post'                          THEN 3
        END
      )
    SQL
    order('DATE(occurred_at) DESC').order(Arel.sql(badges_first))
  end

  validates :product, :subject, :occurred_at, presence: true
end
