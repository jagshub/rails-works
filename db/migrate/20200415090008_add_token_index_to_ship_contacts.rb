class AddTokenIndexToShipContacts < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    add_index :ship_contacts, :token, algorithm: :concurrently, unique: true
  end
end
