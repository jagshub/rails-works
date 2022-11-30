class AddWelcomeEmailSentToUsers < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :welcome_email_sent, :boolean
  end
end
