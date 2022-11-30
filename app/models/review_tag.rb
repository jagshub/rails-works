# frozen_string_literal: true

# == Schema Information
#
# Table name: review_tags
#
#  id             :bigint(8)        not null, primary key
#  property       :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  positive_label :string
#  negative_label :string
#
# Indexes
#
#  index_review_tags_on_property  (property) UNIQUE
#
class ReviewTag < ApplicationRecord
  has_many :review_associations, class_name: 'ReviewTagAssociation', inverse_of: :tag, dependent: :destroy
  has_many :reviews, through: :review_associations
end
