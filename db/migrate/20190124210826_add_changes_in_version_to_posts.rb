class AddChangesInVersionToPosts < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :changes_in_version, :string
  end
end
