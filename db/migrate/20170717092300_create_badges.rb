class CreateBadges < ActiveRecord::Migration
  def change
    create_table :badges do |t|
      t.string :subject_id, null: false
      t.string :subject_type, null: false
      t.string :type, null: false
      t.jsonb :data, null: false
      t.timestamps null: false
    end

    add_index :badges, [:subject_type, :subject_id]
  end
end
