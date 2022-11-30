class CreateMentions < ActiveRecord::Migration[5.0]
  def change
    create_table :mentions do |t|
      t.references :user, null: false
      t.text :subject_type, null: false
      t.integer :subject_id, null: false

      t.timestamps null: false
    end

    add_index :mentions, [:user_id, :subject_type, :subject_id], unique: true
  end
end
