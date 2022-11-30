class AddIconToGkCategory < ActiveRecord::Migration[6.1]
  def change
    change_column_null :golden_kitty_categories, :emoji, true
    add_column :golden_kitty_categories, :icon_uuid, :string
  end
end
