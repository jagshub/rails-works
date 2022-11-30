class AddHiddenAtToGoals < ActiveRecord::Migration[5.1]
  def change
    add_column :goals, :hidden_at, :datetime

    add_index :goals, :hidden_at
  end
end
