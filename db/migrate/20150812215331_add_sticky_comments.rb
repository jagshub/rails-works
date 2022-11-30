class AddStickyComments < ActiveRecord::Migration
  def change
    add_column :comments, :sticky, :boolean, null: false, default: false
  end
end
