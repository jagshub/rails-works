# frozen_string_literal: true

# == Schema Information
#
# Table name: product_stacks
#
#  id         :bigint(8)        not null, primary key
#  product_id :bigint(8)        not null
#  user_id    :bigint(8)        not null
#  source     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_product_stacks_on_product_id_and_user_id  (product_id,user_id) UNIQUE
#  index_product_stacks_on_user_id                 (user_id)
#
class Products::Stack < ApplicationRecord
  self.table_name = 'product_stacks'

  belongs_to :product, class_name: 'Product', inverse_of: :stacks, counter_cache: true
  belongs_to :user, class_name: 'User', inverse_of: :stacks

  validates :source, presence: true
end
