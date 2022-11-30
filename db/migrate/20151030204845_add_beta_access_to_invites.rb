class AddBetaAccessToInvites < ActiveRecord::Migration
  def change
    add_column :invites, :beta_access, :boolean, default: false, null: false
  end
end
