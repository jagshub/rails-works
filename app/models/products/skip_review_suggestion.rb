# frozen_string_literal: true

# == Schema Information
#
# Table name: products_skip_review_suggestions
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  product_id :bigint(8)        not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_products_skip_review_suggestions_on_product_id  (product_id)
#  index_skip_review_suggestions_on_user_and_product     (user_id,product_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (user_id => users.id)
#

class Products::SkipReviewSuggestion < ApplicationRecord
  include Namespaceable

  belongs_to :user, inverse_of: :product_skip_review_suggestions
  belongs_to :product, inverse_of: :skip_review_suggestions
end
