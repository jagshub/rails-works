class MigrateBannerConditions < ActiveRecord::Migration
  def change
    change_table :banners do |t|
      t.boolean :user_logged_out, default: false, null: false
      t.boolean :user_logged_in, default: false, null: false
      t.boolean :user_has_invites, default: false, null: false
      t.boolean :user_profile_incomplete, default: false, null: false
      t.boolean :user_not_following_collection, default: false, null: false
      t.boolean :user_not_upvoted_post, default: false, null: false

      t.string :user_role
      t.string :user_not_subscribed_to_newsletter_group

      t.remove :conditions
    end
  end
end
