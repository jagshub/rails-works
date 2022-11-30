class AddHostToPost < ActiveRecord::Migration
  def change
  	add_column :posts, :url_host, :text, index: true
  end
end