class AddPrivacyPolicyLinkToUpcomingPage < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_pages, :privacy_policy_link, :string
  end
end
