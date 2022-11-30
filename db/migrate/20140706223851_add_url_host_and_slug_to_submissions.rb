class AddUrlHostAndSlugToSubmissions < ActiveRecord::Migration
  def change
    add_column :submissions, :url_host, :text
    add_column :submissions, :slug, :string
  end
end
