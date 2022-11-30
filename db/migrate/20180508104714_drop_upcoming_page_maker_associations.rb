class DropUpcomingPageMakerAssociations < ActiveRecord::Migration[5.0]
  def change
    drop_table :upcoming_page_maker_associations
  end
end
