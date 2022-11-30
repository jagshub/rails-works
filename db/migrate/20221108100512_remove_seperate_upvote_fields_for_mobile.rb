class RemoveSeperateUpvoteFieldsForMobile < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :mobile_devices, :send_comment_upvotes_push, :boolean
      remove_column :mobile_devices, :send_post_upvotes_push, :boolean
    end
  end
end
