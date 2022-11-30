class CreateGoldenKittyPeople < ActiveRecord::Migration[5.1]
  def change
    create_table :golden_kitty_people do |t|
      t.belongs_to :user, foreign_key: true, null: false
      t.belongs_to :golden_kitty_category, foreign_key: true, null: false

      t.timestamps
    end

    add_index :golden_kitty_people, [:user_id, :golden_kitty_category_id], unique: true, name: 'index_golden_kitty_people_on_user_id_and_category_id' 
  end
end
