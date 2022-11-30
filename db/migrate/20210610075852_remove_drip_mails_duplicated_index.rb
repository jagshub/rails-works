class RemoveDripMailsDuplicatedIndex < ActiveRecord::Migration[5.2]
  def change
    remove_index :drip_mails, name: 'index_drip_mails_on_user_id', column: :user_id
  end
end
