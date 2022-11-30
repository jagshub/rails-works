class AddAngellistUidToUsers < ActiveRecord::Migration
  def change
    add_column :users, :angellist_uid, :string
  end
end
