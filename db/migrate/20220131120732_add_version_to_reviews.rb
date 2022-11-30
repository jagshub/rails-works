class AddVersionToReviews < ActiveRecord::Migration[6.1]
  def change
    # Note(AR): The default version is 2, reviews with comments and sentiments,
    # because that's the kind of comments that are currently being created.
    # Versions 1 and 3 will be updated via data migrations.
    add_column :reviews, :version, :integer, null: false, default: 2
  end
end
