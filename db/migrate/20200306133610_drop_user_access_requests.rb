class DropUserAccessRequests < ActiveRecord::Migration[5.1]
  def change
    drop_table :user_access_requests
  end
end
