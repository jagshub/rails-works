class AddGroupsToNewsletterSubscriptions < ActiveRecord::Migration
  def change
    add_column :newsletter_subscriptions, :groups, :hstore
  end
end
