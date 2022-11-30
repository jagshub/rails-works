class AddIndexCreatedAtOnProducts < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    return if Rails.env.production? and Rails.env.staging?
    add_index :products, :created_at, algorithm: :concurrently, if_not_exists: true
  end
end
