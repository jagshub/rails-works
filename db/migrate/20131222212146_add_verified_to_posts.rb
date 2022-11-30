class AddVerifiedToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :verified, :boolean
  end
end
