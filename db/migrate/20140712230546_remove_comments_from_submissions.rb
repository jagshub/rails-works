class RemoveCommentsFromSubmissions < ActiveRecord::Migration
  def change
    remove_column :submissions, :comment, :text
  end
end
