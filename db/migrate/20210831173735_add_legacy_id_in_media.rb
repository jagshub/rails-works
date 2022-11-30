class AddLegacyIdInMedia < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    add_reference :media, :legacy, polymorphic: true, index: false
    add_index :media, [:legacy_type, :legacy_id], unique: true, algorithm: :concurrently
  end
end
