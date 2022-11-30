class DropDripMailsScheduleMailsStatColumns < ActiveRecord::Migration[6.1]
  def change
    safety_assured do
      remove_column :drip_mails_scheduled_mails, :opened_at
      remove_column :drip_mails_scheduled_mails, :clicked_at
    end
  end
end
