# frozen_string_literal: true

# == Schema Information
#
# Table name: review_tag_associations
#
#  id            :bigint(8)        not null, primary key
#  review_id     :bigint(8)        not null
#  review_tag_id :bigint(8)        not null
#  sentiment     :integer          not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
# Indexes
#
#  index_review_tag_associations_on_join           (review_id,review_tag_id,sentiment) UNIQUE
#  index_review_tag_associations_on_review_tag_id  (review_tag_id)
#
# Foreign Keys
#
#  fk_rails_...  (review_id => reviews.id)
#  fk_rails_...  (review_tag_id => review_tags.id)
#
class ReviewTagAssociation < ApplicationRecord
  belongs_to :tag, class_name: 'ReviewTag', foreign_key: :review_tag_id, inverse_of: :review_associations
  belongs_to :review, inverse_of: :tag_associations

  enum sentiment: {
    negative: 0,
    positive: 1,
  }
end
