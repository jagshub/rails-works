class AddVoteSandboxed < ActiveRecord::Migration
  def change
    add_column :post_votes, :sandboxed, :boolean, default: false, null: false
  end
end
