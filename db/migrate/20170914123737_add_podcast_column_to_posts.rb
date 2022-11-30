class AddPodcastColumnToPosts < ActiveRecord::Migration
  def change
    change_table :posts do |t|
      t.boolean :podcast, null: false, default: false
    end
  end
end
