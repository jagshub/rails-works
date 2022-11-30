# frozen_string_literal: true

# == Schema Information
#
# Table name: product_alternative_suggestions
#
#  id                     :bigint(8)        not null, primary key
#  product_id             :bigint(8)        not null
#  alternative_product_id :bigint(8)        not null
#  user_id                :bigint(8)
#  source                 :string           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_alternative_suggestions_on_from_product_id_and_to_product  (product_id,alternative_product_id) UNIQUE
#  index_product_alternative_suggestions_on_alternative_product_id  (alternative_product_id)
#  index_product_alternative_suggestions_on_user_id                 (user_id)
#
class Products::AlternativeSuggestion < ApplicationRecord
  self.table_name = 'product_alternative_suggestions'

  belongs_to :product, class_name: 'Product', inverse_of: :alternative_suggestions
  belongs_to :alternative_product, class_name: 'Product', inverse_of: :reverse_alternative_suggestions
  belongs_to :user, class_name: 'User', inverse_of: :alternative_suggestions, optional: true

  validates :source, presence: true
end
