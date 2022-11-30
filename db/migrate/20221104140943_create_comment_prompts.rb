class CreateCommentPrompts < ActiveRecord::Migration[6.1]
  def change
    create_table :comment_prompts do |t|
      t.string :prompt, null: false
      t.references :post, null: false, foreign_key: true

      t.timestamps
    end
  end
end
