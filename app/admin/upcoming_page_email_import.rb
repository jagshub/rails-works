# frozen_string_literal: true

ActiveAdmin.register UpcomingPageEmailImport do
  config.batch_actions = false

  actions :index, :show

  config.per_page = 20
  config.paginate = true

  menu label: 'Subscriber Imports', parent: 'Ship'

  filter :id
  filter :upcoming_page_id
  filter :state, as: :select, collection: UpcomingPageEmailImport.states
  filter :created_at
  filter :updated_at

  index pagination_total: false do
    selectable_column

    column :id
    column :upcoming_page
    column :state
    column :emails_count
    column :created_at
    column :updated_at

    actions
  end

  show do
    attributes_table do
      row :id
      row :upcoming_page
      row :state
      row :emails_count
      row :failed_count
      row :imported_count
      row :duplicated_count
      row :created_at
      row :updated_at
    end

    panel 'CSV Data' do
      importer = UpcomingPages::Importer.new(upcoming_page_email_import)
      importer.parse_csv
      simple_format importer.subscriber_emails.join("\n")
    end

    active_admin_comments
  end

  action_item :accept_import, only: :show, if: proc { resource.in_review? } do
    link_to 'Accept Import', action: :accept_import
  end

  action_item :reject_import, only: :show, if: proc { resource.in_review? } do
    link_to 'Reject Import', action: :reject_import
  end

  member_action :accept_import do
    resource.reviewed!
    UpcomingPages::ImportWorker.perform_later(resource)
    redirect_to resource_path, notice: 'Accepted import. The user has been notified.'
  end

  member_action :reject_import do
    resource.rejected!
    redirect_to resource_path, notice: 'Rejected import. Please follow-up with the user manually.'
  end
end
