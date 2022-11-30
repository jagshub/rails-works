class AddUserAgentToPromotedAnalytic < ActiveRecord::Migration[5.1]
  def change
    add_column :promoted_analytics, :user_agent, :string
  end
end
