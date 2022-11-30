# frozen_string_literal: true

class AddDefaultCollectionToUser < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    if !ActiveRecord::Base.connection.column_exists?(:users, :default_collection_id)
      add_reference :users, :default_collection, index: false, foreign_key: { to_table: :collections }, null: true
      add_index :users, :default_collection_id, algorithm: :concurrently
    end
  end
end
