class ChangeAdsInteractionsKindIndexToSpGist < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :ads_interactions, :kind, using: :spgist, algorithm: :concurrently
  end
end
