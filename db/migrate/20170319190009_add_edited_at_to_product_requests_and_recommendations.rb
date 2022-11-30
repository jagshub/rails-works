class AddEditedAtToProductRequestsAndRecommendations < ActiveRecord::Migration
  # https://github.com/rails/rails/issues/27077
  CREATE_TIMESTAMP = 'timestamp without time zone NOT NULL DEFAULT CURRENT_TIMESTAMP'.freeze

  def change
    add_column :product_requests, :edited_at, CREATE_TIMESTAMP
    add_column :recommendations, :edited_at, CREATE_TIMESTAMP
  end
end
