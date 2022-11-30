class AddDateTruncIndexOnAdsInteractions < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  INDEX_NAME = :index_ads_interactions_created_at_kind_created_month

  def up
    # NOTE (emilov): skip index creation if already exists
    return if ActiveRecord::Base.connection.indexes(:ads_interactions).select { |i| i.name == INDEX_NAME.to_s }.any?

    add_index(
      :ads_interactions,
      "created_at, kind, date_trunc('month', created_at)",
      name: INDEX_NAME,
      algorithm: :concurrently,
    )
  end

  def down
    remove_index(:ads_interactions, name: INDEX_NAME)
  end
end
