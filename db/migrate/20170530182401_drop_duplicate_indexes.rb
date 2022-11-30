class DropDuplicateIndexes < ActiveRecord::Migration
  def up
    remove_index :friendly_id_slugs, name: :index_friendly_id_slugs_on_slug_and_sluggable_type

    remove_index :maker_suggestions, name: :index_maker_suggestions_on_post_id

    remove_index :product_makers, name: :index_product_makers_on_user_id

    remove_index :recommended_products, name: :index_recommended_products_on_product_request_id

    remove_index :related_post_associations, name: :index_related_post_associations_on_post_id

    remove_index :user_achievement_associations, name: :index_user_achievement_associations_on_user_id

    remove_index :user_follow_product_request_associations, name: :index_user_follow_product_requests_on_user
  end
end
