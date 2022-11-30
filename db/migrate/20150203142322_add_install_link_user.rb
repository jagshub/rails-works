class AddInstallLinkUser < ActiveRecord::Migration
  def change
    add_reference :install_links, :user, null: false
    add_index :install_links, :post_id
  end
end
