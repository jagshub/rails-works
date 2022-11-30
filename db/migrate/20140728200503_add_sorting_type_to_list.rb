class AddSortingTypeToList < ActiveRecord::Migration
  def change
    add_column :lists, :sorting_type, :integer, default: 0, nil: false
  end
end
