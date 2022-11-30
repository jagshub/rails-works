class CreateFlags < ActiveRecord::Migration
  def change
    create_table :flags do |t|
      t.integer :reason, null: false
      t.text :subject_type, null: false
      t.integer :subject_id, null: false
      t.references :user, index: true, foreign_key: false, null: false
      t.timestamps null: false
    end

    add_index :flags, [:subject_type, :subject_id, :user_id], unique: true
  end
end
