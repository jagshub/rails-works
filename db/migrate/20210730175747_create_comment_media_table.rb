class CreateCommentMediaTable < ActiveRecord::Migration[5.2]
  def change
    create_table :comment_media do |t|
      t.references :user, index: true
      t.references :comment, index: true
      t.integer :media_type, null: false
      t.string :image_uuid, null: false
      t.integer :priority, null: false
      t.integer :original_width, null: false
      t.integer :original_height, null: false

      t.timestamps
    end
  end
end
