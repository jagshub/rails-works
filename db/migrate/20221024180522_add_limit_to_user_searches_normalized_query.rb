class AddLimitToUserSearchesNormalizedQuery < ActiveRecord::Migration[6.1]
  def change
    # NOTE(DZ): Migration reverted due to downtime caused to demos
    # safety_assured do
    #   change_column :search_user_searches, :normalized_query, :string, limit: 255
    # end
  end
end
