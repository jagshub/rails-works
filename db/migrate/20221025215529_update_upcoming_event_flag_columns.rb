class UpdateUpcomingEventFlagColumns < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :upcoming_events, :active, :boolean, default: false, null: false
    add_column :upcoming_events, :status, :string, default: 'pending', null: false

    add_index(
      :upcoming_events,
      %i(product_id post_id active status),
      name: 'index_on_upcoming_event_query_columns',
      unique: true,
      algorithm: :concurrently,
    )

    add_index(
      :upcoming_events,
      %i(product_id active),
      unique: true,
      where: 'active = true',
      algorithm: :concurrently,
    )
  end
end
