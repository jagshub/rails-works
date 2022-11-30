class RemoveProductIdFromEmbeds < ActiveRecord::Migration[5.0]
  def change
    remove_column :embeds, :product_id, :integer

    change_column_null :embeds, :subject_id, false
    change_column_null :embeds, :subject_type, false
  end
end
