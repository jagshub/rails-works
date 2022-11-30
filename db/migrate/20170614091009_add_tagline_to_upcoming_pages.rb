class AddTaglineToUpcomingPages < ActiveRecord::Migration
  def change
    change_table :upcoming_pages do |t|
      t.string :tagline
    end
  end
end
