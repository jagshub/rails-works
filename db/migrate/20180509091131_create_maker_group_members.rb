class CreateMakerGroupMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :maker_group_members do |t|
      t.belongs_to :maker_group, foreign_key: true, index: true, null: false
      t.belongs_to :user, foreign_key: true, index: true, null: false

      t.timestamps
    end

    add_column :maker_groups, :members_count, :integer, null: false, default: 0
    add_index :maker_group_members, [:user_id, :maker_group_id], unique: true
  end
end
