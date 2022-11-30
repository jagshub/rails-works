# frozen_string_literal: true

# == Schema Information
#
# Table name: product_links
#
#  id           :bigint(8)        not null, primary key
#  url          :string           not null
#  source       :string           not null
#  url_kind     :string           not null
#  clicks_count :integer          default(0), not null
#  product_id   :bigint(8)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_product_links_on_product_id  (product_id)
#  index_product_links_on_url         (url)
#
class Products::Link < ApplicationRecord
  self.table_name = 'product_links'

  belongs_to :product, inverse_of: :links

  enum source: { stacks: 'stacks', user: 'user', scraper: 'scraper' }
  enum url_kind: { store: 'store', social: 'social', other: 'other' }, _prefix: true
end
