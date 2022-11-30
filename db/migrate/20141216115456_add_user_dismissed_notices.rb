class AddUserDismissedNotices < ActiveRecord::Migration
  def change
    create_table :user_dismissed_notice_associations do |t|
      t.references :user, null: false
      t.references :notice, null: false
      t.timestamps
    end

    add_index :user_dismissed_notice_associations, :user_id
  end
end
