class RenameDripMailsScheduleMailSubjectColumn < ActiveRecord::Migration[5.2]
  def change
    safety_assured do 
      rename_column :drip_mails_scheduled_mails, :subject, :subject_type
    end
  end
end
