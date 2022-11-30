class AddSubjectToEmbeds < ActiveRecord::Migration[5.0]
  def change
    add_column :embeds, :subject_id, :integer
    add_column :embeds, :subject_type, :string

    change_column_null :embeds, :product_id, true

    execute "UPDATE embeds SET subject_id = product_id, subject_type = 'Product'"

    add_index :embeds, %i(subject_type subject_id)
    add_index :embeds, %i(subject_type subject_id clean_url), unique: true
  end
end
