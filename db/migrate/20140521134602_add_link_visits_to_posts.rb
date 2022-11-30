class AddLinkVisitsToPosts < ActiveRecord::Migration
  def change
    add_column :posts, :link_visits, :integer, :default => 0, :null => false
  end
end
