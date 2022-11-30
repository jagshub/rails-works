class RemoveNullEditedAtConstrainFromProductRequestsAndRecommendations < ActiveRecord::Migration
  def change
    change_column_null :product_requests, :edited_at, true
    change_column_default :product_requests, :edited_at, nil
    change_column_null :recommendations, :edited_at, true
    change_column_default :recommendations, :edited_at, nil
  end
end
