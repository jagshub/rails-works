class AddColorToCollections < ActiveRecord::Migration
  def up
    add_column :collections, :color, :integer, default: 0, null: false

    random_colors_sql = <<-SQL
      UPDATE collections
         SET color = (id % 5)
    SQL

    execute random_colors_sql
  end

  def down
    remove_column :collections, :color
  end
end
