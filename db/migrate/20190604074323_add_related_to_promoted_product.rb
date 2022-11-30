class AddRelatedToPromotedProduct < ActiveRecord::Migration[5.1]
  def change
    add_column :promoted_products, :promoted_type, :integer, null: false, default: 0
    add_column :promoted_products, :start_date, :datetime
    add_column :promoted_products, :end_date, :datetime
    add_column :promoted_products, :topic_bundle, :string

    add_index :promoted_products, %i(promoted_type topic_bundle), where: 'topic_bundle IS NOT NULL'
  end
end
