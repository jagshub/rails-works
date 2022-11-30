# frozen_string_literal: true

# == Schema Information
#
# Table name: product_scrape_results
#
#  id         :bigint(8)        not null, primary key
#  product_id :bigint(8)        not null
#  url        :string
#  source     :string           not null
#  data       :jsonb            not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_product_scrape_results_on_product_id_and_source  (product_id,source) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (product_id => products.id)
#
class Products::ScrapeResult < ApplicationRecord
  self.table_name = 'product_scrape_results'

  belongs_to :product, class_name: 'Product', inverse_of: :scrape_results

  validates :source, presence: true
  validates :data, presence: true

  scope :by_product_url, ->(product, url) { where(product: product, url: url) }
end
