class CreateModerationSkips < ActiveRecord::Migration[6.1]
  def change
    create_table :moderation_skips do |t|
      t.references :subject, polymorphic: true, null: false
      t.references :user, null: false, index: true, foreign_key: true
      t.string :message, null: true

      t.timestamps null: false

      t.index [:subject_id, :subject_type, :user_id], unique: true, name: 'index_moderation_skips_on_subject_and_user'
    end
  end
end
