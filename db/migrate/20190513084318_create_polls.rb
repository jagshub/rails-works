class CreatePolls < ActiveRecord::Migration[5.1]
  def change
    create_table :polls do |t|
      t.references :subject, null: false, polymorphic: true, unique: true, index: { name: 'index_polls_on_subject' }

      t.timestamps
    end

    create_table :poll_options do |t|
      t.belongs_to :poll, index: true, foreign_key: true, null: false 
      t.string :text, null: false
      t.string :image_uuid, null: true

      t.timestamps
    end

    create_table :poll_answers do |t|
      t.belongs_to :poll_option, index: true, foreign_key: true, null: false
      t.belongs_to :user, index: true, foreign_key: true, null: false

      t.timestamps
    end

    add_index :poll_answers, %i(poll_option_id user_id), unique: true
  end
end
