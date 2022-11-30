# frozen_string_literal: true

# == Schema Information
#
# Table name: questions
#
#  id         :bigint(8)        not null, primary key
#  post_id    :bigint(8)        not null
#  slug       :string           not null
#  title      :string           not null
#  answer     :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_questions_on_post_id  (post_id)
#  index_questions_on_slug     (slug) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#
class Question < ApplicationRecord
  include Sluggable
  include RandomOrder

  sluggable candidate: :title

  belongs_to :post, inverse_of: :questions, optional: false

  scope :with_post, ->(post_id) { where(post_id: post_id) }

  validates :title, presence: true
  validates :answer, presence: true
  validates :slug, presence: true
end
