class AddPublishedAtIndexToSips < ActiveRecord::Migration[5.0]
  def change
    add_index :sips, :published_at
  end
end
