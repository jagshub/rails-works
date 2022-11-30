class AddDiscussionsCountToMakerGroups < ActiveRecord::Migration[5.1]
  def change
    add_column :maker_groups, :discussions_count, :integer, null: false, default: 0
  end
end
