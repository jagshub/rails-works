class AddPostEditsToNewsletter < ActiveRecord::Migration
  def change
    add_column :newsletters, :posts, :jsonb, default: [], null: false
  end
end
