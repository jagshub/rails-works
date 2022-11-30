class AddMakerOfPostToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :maker_of_post_id, :integer
  end
end
