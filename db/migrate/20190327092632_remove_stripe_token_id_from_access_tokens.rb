class RemoveStripeTokenIdFromAccessTokens < ActiveRecord::Migration[5.0]
  def change
    remove_column :access_tokens, :stripe_account_id
  end
end
