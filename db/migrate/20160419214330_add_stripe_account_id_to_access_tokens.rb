class AddStripeAccountIdToAccessTokens < ActiveRecord::Migration
  def change
    add_column :access_tokens, :stripe_account_id, :string, null: true
  end
end
