# frozen_string_literal: true

# == Schema Information
#
# Table name: product_screenshots
#
#  id         :bigint(8)        not null, primary key
#  product_id :bigint(8)        not null
#  user_id    :bigint(8)
#  image_uuid :string           not null
#  alt_text   :string
#  position   :integer          default(0), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_product_screenshots_on_product_id  (product_id)
#  index_product_screenshots_on_user_id     (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#  fk_rails_...  (user_id => users.id)
#
class Products::Screenshot < ApplicationRecord
  self.table_name = 'product_screenshots'

  default_scope { order(:position) }

  belongs_to :product, inverse_of: :screenshots
  belongs_to :user, inverse_of: :product_screenshots, optional: true

  include Uploadable
  uploadable :image
end
