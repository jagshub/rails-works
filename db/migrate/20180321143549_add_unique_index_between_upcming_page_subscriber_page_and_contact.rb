class AddUniqueIndexBetweenUpcmingPageSubscriberPageAndContact < ActiveRecord::Migration[5.0]
  def change
    add_index :upcoming_page_subscribers, %i(upcoming_page_id ship_contact_id), unique: true, name: 'index_upcoming_page_subscribers_on_page_id_and_contact_id'
  end
end
