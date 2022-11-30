class AddReferenceToChatMessages < ActiveRecord::Migration[5.0]
  def change
    add_column :chat_messages, :reference_type, :text, null: true
    add_column :chat_messages, :reference_id, :string, null: true

    add_index :chat_messages, %i(reference_type reference_id)
  end
end
