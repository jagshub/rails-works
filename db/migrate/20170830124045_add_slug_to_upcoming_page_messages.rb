class AddSlugToUpcomingPageMessages < ActiveRecord::Migration
  def change
    add_column :upcoming_page_messages, :slug, :string, null: true
  end
end
