class AddTeamEmailConfirmedToTeamRequests < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :team_requests, :team_email_confirmed, :boolean, default: false, null: false
    add_column :team_requests, :verification_token, :string
    add_column :team_requests, :verification_token_generated_at, :datetime

    add_index :team_requests, :verification_token, algorithm: :concurrently
    add_index :team_requests, :team_email_confirmed, algorithm: :concurrently
  end
end
