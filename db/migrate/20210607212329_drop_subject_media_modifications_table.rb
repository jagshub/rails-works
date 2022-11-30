class DropSubjectMediaModificationsTable < ActiveRecord::Migration[5.2]
  def up
    drop_table :subject_media_modifications
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
