class AddDefaultToNewsetterSubscriptionGroups < ActiveRecord::Migration
  def change
    change_column_default :newsletter_subscriptions, :groups, ''
    change_column_null :newsletter_subscriptions, :groups, false
  end
end
