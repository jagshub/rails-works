class AddPromotedAtToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :promoted_at, :datetime
  end
end
