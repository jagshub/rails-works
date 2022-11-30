# frozen_string_literal: true

# == Schema Information
#
# Table name: checkout_page_logs
#
#  id               :integer          not null, primary key
#  checkout_page_id :integer          not null
#  user_id          :integer          not null
#  billing_email    :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_checkout_page_logs_on_checkout_page_id  (checkout_page_id)
#  index_checkout_page_logs_on_user_id           (user_id)
#

class CheckoutPageLog < ApplicationRecord
  belongs_to :user, optional: false
  belongs_to :checkout_page, optional: false

  validates :billing_email, presence: true
end
