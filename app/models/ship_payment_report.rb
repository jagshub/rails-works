# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_payment_reports
#
#  id          :integer          not null, primary key
#  net_revenue :integer          not null
#  date        :datetime         not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ShipPaymentReport < ApplicationRecord
  validates :net_revenue, presence: true
  validates :date, presence: true
end
