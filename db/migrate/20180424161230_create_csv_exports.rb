class CreateCsvExports < ActiveRecord::Migration[5.0]
  def change
    create_table :file_exports do |t|
      t.belongs_to :user, null: false, foreign_key: true, index: true
      t.string :file_key, null: false, index: { unique: true }
      t.string :file_name, null: false
      t.datetime :expires_at, null: false, index: true
      t.string :note
      t.timestamps null: false
    end
  end
end
