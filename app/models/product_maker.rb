# frozen_string_literal: true

# == Schema Information
#
# Table name: product_makers
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  post_id    :integer          not null
#  created_at :datetime
#  updated_at :datetime
#
# Indexes
#
#  index_product_makers_on_post_id              (post_id)
#  index_product_makers_on_user_id_and_post_id  (user_id,post_id) UNIQUE
#

# TODO(DZ): Rename to PostMaker
class ProductMaker < ApplicationRecord
  belongs_to :user, touch: true, counter_cache: true
  belongs_to :post, touch: true, counter_cache: :makers_count
  has_one :maker_suggestion, dependent: :destroy

  validates :user_id, uniqueness: { scope: :post_id, message: 'This user is already a maker for this post' }

  scope :of_visible_posts, -> { joins(:post).merge(Post.visible) }
end
