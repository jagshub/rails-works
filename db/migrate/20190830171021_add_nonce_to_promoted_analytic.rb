class AddNonceToPromotedAnalytic < ActiveRecord::Migration[5.1]
  def change
    add_column :promoted_analytics, :nonce, :string
  end
end
