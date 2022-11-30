class CreateSubjectMediaModifications < ActiveRecord::Migration[5.2]
  def change
    create_table :subject_media_modifications do |t|
      t.string :subject_type
      t.integer :subject_id
      t.string :subject_column
      t.string :original_image_uuid
      t.string :modified_image_uuid
      t.boolean :modified, default: false

      t.timestamps
    end

    add_index :subject_media_modifications, :subject_type
    add_index :subject_media_modifications, :subject_id
    add_index :subject_media_modifications, :subject_column
  end
end
