class AddInvitesSecretCategories < ActiveRecord::Migration
  def change
    add_column :invites, :with_secret_categories, :boolean, null: false, default: false
  end
end
