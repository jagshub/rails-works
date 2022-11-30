class CarouselToBanners < ActiveRecord::Migration
  def up
    change_table :banners do |t|
      t.integer :appearance, default: 0, null: false

      execute <<-SQL
        UPDATE banners
        SET appearance = 1
        WHERE full_width = true
      SQL

      t.remove :full_width
    end
  end

  def down
    change_table :banners do |t|
      t.remove :appearance
      t.boolean :full_width, default: false, null: false
    end
  end
end
