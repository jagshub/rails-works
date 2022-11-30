class AddSubjectToUpcomingPageMessageDeliveries < ActiveRecord::Migration[5.0]
  def change
    add_column :upcoming_page_message_deliveries, :subject_id, :integer, null: true
    add_column :upcoming_page_message_deliveries, :subject_type, :string, null: true
  end
end
