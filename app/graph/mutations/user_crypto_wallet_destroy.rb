# frozen_string_literal: true

module Graph::Mutations
  class UserCryptoWalletDestroy < BaseMutation
    returns Graph::Types::SettingsType

    require_current_user

    def perform
      return current_user if current_user.crypto_wallet.nil?

      current_user.crypto_wallet.destroy!
    end
  end
end
