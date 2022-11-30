class UpdateEmailsTableFormat < ActiveRecord::Migration[5.0]
  def change
    rename_column :emails, :source, :source_kind
    add_column :emails, :source_reference_id, :string
    add_index :emails, [:source_kind, :source_reference_id]
  end
end
