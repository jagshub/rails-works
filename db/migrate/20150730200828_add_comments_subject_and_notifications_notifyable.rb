class AddCommentsSubjectAndNotificationsNotifyable < ActiveRecord::Migration
  def change
    # Note(LukasFittl): Populated using a data migration, hence these are NULL
    add_column :comments, :subject_type, :text, null: true
    add_column :comments, :subject_id, :integer, null: true
    add_column :notifications, :notifyable_type, :text, null: true
    add_column :notifications, :notifyable_id, :integer, null: true
  end
end
