class AddAlternativesCountToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :alternatives_count, :integer, null: false, default: 0
  end
end
