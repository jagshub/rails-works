class AddDeliveringStatusOnScheduledMails < ActiveRecord::Migration[5.2]
  def change
    safety_assured do 
       add_column :drip_mails_scheduled_mails, :delivering, :boolean, default: false
    end
  end
end
