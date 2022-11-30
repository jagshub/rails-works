class AddExpireAtToAccessRequest < ActiveRecord::Migration[5.1]
  def change
    add_column :founder_club_access_requests, :expire_at, :datetime
  end
end
