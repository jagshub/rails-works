# frozen_string_literal: true

# == Schema Information
#
# Table name: house_keeper_broken_links
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  product_link_id :bigint(8)        not null
#  reason          :text
#
# Indexes
#
#  index_house_keeper_broken_links_on_product_link_id  (product_link_id)
#
# Foreign Keys
#
#  fk_rails_...  (product_link_id => legacy_product_links.id)
#

class HouseKeeperBrokenLink < ApplicationRecord
  belongs_to :product_link, class_name: 'LegacyProductLink', inverse_of: :house_keeper_broken_links

  # NOTE(DZ): House Keeping task runs every month. Add few days to bugger
  MONTH_BUFFER = 32.days

  scope :previous_month_failure, lambda { |product_link|
    where(product_link: product_link)
      .where_time_gteq(:created_at, MONTH_BUFFER.ago)
  }
end
