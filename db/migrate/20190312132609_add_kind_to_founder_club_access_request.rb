class AddKindToFounderClubAccessRequest < ActiveRecord::Migration[5.0]
  def change
    add_column :founder_club_access_requests, :source, :integer, null: false, default: 0
    add_column :founder_club_access_requests, :invited_by_user_id, :integer, null: true

    add_index :founder_club_access_requests, :invited_by_user_id, where: 'invited_by_user_id IS NOT NULL'
    add_foreign_key :founder_club_access_requests, :users, column: :invited_by_user_id
  end
end
