class UpdateFlagsTableForModeration < ActiveRecord::Migration[5.1]
  disable_ddl_transaction!

  def change
    safety_assured {
      add_column :flags, :status, :string, null: false, default: 'unresolved'
    }
    add_index :flags, :status, algorithm: :concurrently, using: :spgist

    add_column :flags, :reason_new, :string
    add_index :flags, :reason_new, algorithm: :concurrently, using: :spgist

    add_reference :flags, :moderator, foreign_key: { to_table: :users }, index: false
    add_index :flags, :moderator_id, algorithm: :concurrently
  end
end
