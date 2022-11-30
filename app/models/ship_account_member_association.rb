# frozen_string_literal: true

# == Schema Information
#
# Table name: ship_account_member_associations
#
#  id              :integer          not null, primary key
#  ship_account_id :integer          not null
#  user_id         :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_ship_account_member_associations_on_user_id        (user_id)
#  ship_account_member_associations_user_id_and_account_id  (ship_account_id,user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (ship_account_id => ship_accounts.id)
#  fk_rails_...  (user_id => users.id)
#

class ShipAccountMemberAssociation < ApplicationRecord
  belongs_to :account, class_name: 'ShipAccount', foreign_key: :ship_account_id, inverse_of: :ship_account_member_associations
  belongs_to :user, inverse_of: :ship_account_member_associations

  validates :user_id, uniqueness: { scope: :ship_account_id }

  attr_readonly :user_id, :ship_account_id
end
