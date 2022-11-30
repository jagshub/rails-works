# frozen_string_literal: true

# == Schema Information
#
# Table name: users_crypto_wallets
#
#  id         :bigint(8)        not null, primary key
#  user_id    :bigint(8)        not null
#  address    :string           not null
#  provider   :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_users_crypto_wallets_on_address  (address) UNIQUE
#  index_users_crypto_wallets_on_user_id  (user_id) UNIQUE
#
class Users::CryptoWallet < ApplicationRecord
  include Namespaceable
  belongs_to :user, inverse_of: :crypto_wallet

  enum provider: {
    ethereum: 'ethereum',
  }
end
