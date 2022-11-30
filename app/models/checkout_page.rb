# frozen_string_literal: true

# == Schema Information
#
# Table name: checkout_pages
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  sku        :string           not null
#  slug       :string           not null
#  body       :text             not null
#  trashed_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  kind       :integer          default("one_time_payment")
#
# Indexes
#
#  index_checkout_pages_on_slug  (slug) UNIQUE
#

class CheckoutPage < ApplicationRecord
  include Sluggable
  include Trashable

  sluggable

  validates :name, presence: true
  validates :sku, presence: true
  validates :body, presence: true

  enum kind: {
    one_time_payment: 0,
    subscription: 100,
  }
end
