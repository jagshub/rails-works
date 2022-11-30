class AddLayoutToLists < ActiveRecord::Migration
  def change
    add_column :lists, :layout, :string, null: false, default: 'list'
  end
end
