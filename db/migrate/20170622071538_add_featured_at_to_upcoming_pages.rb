class AddFeaturedAtToUpcomingPages < ActiveRecord::Migration
  def change
    change_table :upcoming_pages do |t|
      t.datetime :featured_at
    end
  end
end
