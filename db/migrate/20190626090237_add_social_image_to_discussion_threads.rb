class AddSocialImageToDiscussionThreads < ActiveRecord::Migration[5.0]
  def change
    add_column :discussion_threads, :social_image_url, :string, null: true
  end
end
