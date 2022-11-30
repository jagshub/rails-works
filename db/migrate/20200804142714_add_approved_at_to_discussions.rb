class AddApprovedAtToDiscussions < ActiveRecord::Migration[5.1]
  def change
    add_column :discussion_threads, :approved_at, :datetime
  end
end
