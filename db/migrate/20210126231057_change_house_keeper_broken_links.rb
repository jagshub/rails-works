class ChangeHouseKeeperBrokenLinks < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_reference :house_keeper_broken_links, :product_link, null: false, index: false, foreign_key: true
    add_index :house_keeper_broken_links, :product_link_id, algorithm: :concurrently

    safety_assured { remove_reference :house_keeper_broken_links, :post }
  end
end
