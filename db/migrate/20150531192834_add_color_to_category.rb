class AddColorToCategory < ActiveRecord::Migration
  def change
    add_column :categories, :color, :text
  end
end
