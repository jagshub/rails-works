class AddHeaderUuidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :header_uuid, :uuid
  end
end
