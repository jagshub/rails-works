class AddBrandColorToUpcomingPages < ActiveRecord::Migration
  def change
    change_table :upcoming_pages do |t|
      t.string :brand_color, null: true
    end
  end
end
