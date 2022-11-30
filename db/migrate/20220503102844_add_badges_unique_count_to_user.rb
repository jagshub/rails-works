class AddBadgesUniqueCountToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :badges_unique_count, :integer, null: false, default: 0
  end
end
