class CreateMakerWelcomes < ActiveRecord::Migration[5.0]
  def change
    create_table :maker_welcomes do |t|
      t.belongs_to :welcomee, index: true, null: false
      t.belongs_to :welcomer, index: true, null: false

      t.timestamps
    end

    add_column :users, :maker_welcomers_count, :integer, null: false, default: 0
    add_index :maker_welcomes, [:welcomer_id, :welcomee_id], unique: true
  end
end
