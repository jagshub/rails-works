class RemoveResultsCountFromUserSearches < ActiveRecord::Migration[6.1]
  def change
    safety_assured { remove_column :search_user_searches, :results_count }
  end
end
