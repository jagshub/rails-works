class RenameDripMailsToNamespace < ActiveRecord::Migration[5.2]
  def change
    safety_assured do 
      rename_table :drip_mails, :drip_mails_scheduled_mails
    end
  end
end
