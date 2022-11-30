class AddSuggestedProductToPostDraft < ActiveRecord::Migration[6.1]
  def change
    add_reference :post_drafts, :suggested_product, foreign_key: { to_table: :products }, index: false
    add_column :post_drafts, :connect_product, :boolean, default: false, null: false
  end
end
