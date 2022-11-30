class DropSearchSearchableConversion < ActiveRecord::Migration[6.1]
  def change
    drop_table :search_searchable_conversions
    safety_assured { remove_column :search_user_searches, :conversions_count }
  end
end
