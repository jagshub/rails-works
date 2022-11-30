# frozen_string_literal: true

ActiveAdmin.register ModerationSkip do
  menu label: 'Moderation Skips', parent: 'Others'

  filter :user_username, as: :string, label: 'Moderator'
  filter :subject_id, as: :string
  filter :subject_type, as: :string
  filter :message, as: :string

  actions :index, :destroy

  controller do
    def scoped_collection
      ModerationSkip.includes(:subject, :user)
    end
  end

  index pagination_total: true do
    column :id
    column :user
    column :subject
    column :message
    column :created_at

    column 'Actions' do |skip|
      link_to 'Delete (Un-skip)', admin_moderation_skip_path(skip.id), method: :delete
    end
  end
end
