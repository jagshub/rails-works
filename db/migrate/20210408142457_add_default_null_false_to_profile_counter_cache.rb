class AddDefaultNullFalseToProfileCounterCache < ActiveRecord::Migration[5.1]
  def change
    safety_assured do
      %i[
        votes_count
        collections_count
        upcoming_pages_count
        subscribed_upcoming_pages_count
        subscribed_collections_count
      ].each do |column|
        change_column_default :users, column, from: 0, to: 0
        change_column_null :users, column, false, 0
      end
    end
  end
end
