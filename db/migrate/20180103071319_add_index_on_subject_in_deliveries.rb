class AddIndexOnSubjectInDeliveries < ActiveRecord::Migration[5.0]
  def change
    add_index :upcoming_page_message_deliveries, %i(subject_type subject_id), name: 'index_u_p_m_deliveries_on_subject_type_and_subject_id'
  end
end
