class AddDefaultToDiscussionStatus < ActiveRecord::Migration[6.1]
  def change
    change_column_default :discussion_threads, :status, from: nil, to: 'pending'
    change_column_null :discussion_threads, :status, false
  end
end
