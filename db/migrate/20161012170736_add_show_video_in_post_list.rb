class AddShowVideoInPostList < ActiveRecord::Migration
  def change
    change_table :posts do |t|
      t.boolean :show_video_in_post_list, default: false, null: false
    end
  end
end
