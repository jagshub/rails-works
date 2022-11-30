class RemoveSecretCategories < ActiveRecord::Migration
  def change
    remove_column :invites, :with_secret_categories, :boolean
    remove_column :categories, :visibility, :integer
  end
end
