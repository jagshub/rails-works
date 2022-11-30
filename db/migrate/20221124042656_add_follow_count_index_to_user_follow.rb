class AddFollowCountIndexToUserFollow < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_index(
      :user_friend_associations,
      %i(created_at followed_by_user_id),
      algorithm: :concurrently,
      name: 'index_user_friend_associations_on_created_and_followed_by',
    )
  end
end
