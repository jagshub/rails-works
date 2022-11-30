class AddSourceToUserFollowProductRequestAssociations < ActiveRecord::Migration
  def change
    add_reference :user_follow_product_request_associations, :source, index: false
  end
end
