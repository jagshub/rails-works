class CreateUpcomingPageConversationMessages < ActiveRecord::Migration[5.0]
  def change
    create_table :upcoming_page_conversation_messages do |t|
      t.text :body, null: false

      t.references :upcoming_page_conversation, null: false, index: { name: 'index_u_p_conversation_messages_on_u_p_conversation_id' }, foreign_key: true
      t.references :upcoming_page_email_reply, null: true, index: { name: 'index_u_p_conversation_messages_on_u_p_email_reply_id' }, foreign_key: true

      t.references :upcoming_page_subscriber, null: true, index: { name: 'index_u_p_conversation_messages_on_u_p_sub_id' }, foreign_key: true
      t.references :user, null: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
