class AddWinnerToGkPerson < ActiveRecord::Migration[6.1]
  def change
    add_column :golden_kitty_people, :winner, :boolean, default: false, null: false
  end
end
