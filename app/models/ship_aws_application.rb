# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_aws_applications
#
#  id              :integer          not null, primary key
#  startup_name    :string           not null
#  startup_email   :string           not null
#  ship_account_id :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_ship_aws_applications_on_ship_account_id  (ship_account_id)
#
# Foreign Keys
#
#  fk_rails_...  (ship_account_id => ship_accounts.id)
#

class ShipAwsApplication < ApplicationRecord
  belongs_to :ship_account, optional: false, inverse_of: :aws_application

  validates :startup_name, presence: true
  validates :startup_email, presence: true

  scope :reverse_chronological, -> { order(arel_table[:created_at].desc) }
end
