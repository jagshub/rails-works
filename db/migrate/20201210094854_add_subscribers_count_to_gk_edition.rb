class AddSubscribersCountToGkEdition < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      add_column :golden_kitty_editions, :subscribers_count, :integer, null: false, default: 0
      add_column :golden_kitty_editions, :followers_count, :integer, null: false, default: 0
    end
  end
end
