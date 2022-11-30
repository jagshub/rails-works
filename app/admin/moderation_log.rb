# frozen_string_literal: true

ActiveAdmin.register ModerationLog do
  menu label: 'Moderation Logs', parent: 'Others'

  filter :moderator_username, as: :string, label: 'Moderator'
  filter :reference_id, as: :string
  filter :reference_type, as: :string
  filter :reason, as: :string
  filter :message, as: :string

  actions :index

  controller do
    def scoped_collection
      ModerationLog.includes(:reference, :moderator)
    end
  end

  index pagination_total: true do
    column :id
    column :moderator
    column :reference
    column :message
    column :reason
    column :created_at
  end
end
