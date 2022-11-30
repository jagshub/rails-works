class AddEmailIndexToShipContacts < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def change
    add_index :ship_contacts, [:email, :email_confirmed], algorithm: :concurrently
  end
end
