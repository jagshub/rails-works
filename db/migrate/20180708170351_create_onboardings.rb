class CreateOnboardings < ActiveRecord::Migration[5.0]
  def change
    create_table :onboardings do |t|
      t.string :name, null: false
      t.belongs_to :user, foreign_key: true, index: true, null: false

      t.timestamps
    end

    add_index :onboardings, [:user_id, :name], unique: true
  end
end
