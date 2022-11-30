class AddAcceptedDuplicateToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :accepted_duplicate, :boolean, default: false, nil: false
  end
end
