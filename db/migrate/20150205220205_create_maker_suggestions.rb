class CreateMakerSuggestions < ActiveRecord::Migration
  def change
    create_table :maker_suggestions do |t|
      t.references :approved_by, index: true
      t.references :invited_by
      t.references :maker, index: true
      t.references :post, index: true
      t.references :product_maker
      t.string :maker_username

      t.timestamps null: false
    end

    add_index :maker_suggestions, [:post_id, :maker_id, :maker_username], unique: true, name: 'maker_suggestions_post_maker'
  end
end
