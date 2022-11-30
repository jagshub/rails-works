class RemoveNotNullConstraintFromDiscussionThreadDescription < ActiveRecord::Migration[5.1]
  def change
    change_column_null :discussion_threads, :description, true
  end
end
