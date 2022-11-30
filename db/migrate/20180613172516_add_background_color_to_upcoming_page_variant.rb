class AddBackgroundColorToUpcomingPageVariant < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_variants, :background_color, :string
  end
end
