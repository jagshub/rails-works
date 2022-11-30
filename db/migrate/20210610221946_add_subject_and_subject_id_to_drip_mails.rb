class AddSubjectAndSubjectIdToDripMails < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!
  
  def change
    add_column :drip_mails, :subject, :string, null: false
    add_column :drip_mails, :subject_id, :integer, null: false
    
    remove_index :drip_mails, name: 'index_drip_mails_on_user_id_and_mailer_name_and_drip_kind'
    add_index :drip_mails, 
      [:user_id, :mailer_name, :drip_kind, :subject, :subject_id],
      unique: true,
      name: 'index_drip_mails_on_mailer_drip_and_subject',
      algorithm: :concurrently
  end
end
