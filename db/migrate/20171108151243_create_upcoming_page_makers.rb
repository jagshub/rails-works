class CreateUpcomingPageMakers < ActiveRecord::Migration[5.0]
  def change
    create_table :upcoming_page_maker_associations do |t|
      t.references :upcoming_page, null: false
      t.references :user, null: false
      t.timestamps null: false
    end

    add_index :upcoming_page_maker_associations, %i(upcoming_page_id user_id), unique: true, name: 'upcoming_page_maker_assocaitions_user_id_and_page_id'

    add_foreign_key :upcoming_page_maker_associations, :users
    add_foreign_key :upcoming_page_maker_associations, :upcoming_pages
  end
end
