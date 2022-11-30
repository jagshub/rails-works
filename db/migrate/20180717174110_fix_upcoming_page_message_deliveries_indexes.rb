class FixUpcomingPageMessageDeliveriesIndexes < ActiveRecord::Migration[5.0]
  disable_ddl_transaction!

  def up
    add_index :upcoming_page_message_deliveries, [:subject_type, :subject_id, :upcoming_page_subscriber_id], algorithm: :concurrently, name: 'index_u_p_m_deliveries_on_subject_and_subscriber'
    execute 'DROP INDEX CONCURRENTLY index_u_p_m_deliveries_on_subject_type_and_subject_id'
  end

  def down
    add_index :upcoming_page_message_deliveries, [:subject_type, :subject_id], algorithm: :concurrently, name: 'index_u_p_m_deliveries_on_subject_type_and_subject_id'
    execute 'DROP INDEX CONCURRENTLY index_u_p_m_deliveries_on_subject_and_subscriber'
  end
end
