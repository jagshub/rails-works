class CreateOAuthRequests < ActiveRecord::Migration[5.1]
  def change
    create_table :oauth_requests do |t|
      t.datetime :last_request_at, null: false

      t.references :user, foreign_key: true, index: false
      t.references :application, foreign_key: { to_table: :oauth_applications }, null: false, index: false
    end

    add_index :oauth_requests, :application_id, unique: true, where: 'user_id IS NULL'
    add_index :oauth_requests, [:application_id, :user_id], unique: true, name: 'index_oauth_requests_application_id_user_id'
  end
end
