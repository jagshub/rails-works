# frozen_string_literal: true

ActiveAdmin.register ModerationLock do
  menu label: 'Moderation Locks', parent: 'Others'

  filter :user_username, as: :string, label: 'Moderator'
  filter :subject_id, as: :string
  filter :subject_type, as: :string

  actions :index, :destroy

  controller do
    def scoped_collection
      ModerationLock.includes(:subject, :user)
    end
  end

  index pagination_total: true do
    column :id
    column :user
    column :subject
    column :created_at
    column :expires_at

    column 'Actions' do |lock|
      link_to 'Delete (Clear lock)', admin_moderation_lock_path(lock.id), method: :delete
    end
  end
end
