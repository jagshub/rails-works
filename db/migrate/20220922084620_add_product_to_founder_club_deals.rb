class AddProductToFounderClubDeals < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_reference(
      :founder_club_deals,
      :product,
      null: true,
      index: false,
      foreign_key: { to_table: :products, on_delete: :nullify }
    )

    add_index :founder_club_deals, :product_id, algorithm: :concurrently, if_not_exists: true
  end
end
