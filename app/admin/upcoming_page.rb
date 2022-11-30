# frozen_string_literal: true

ActiveAdmin.register UpcomingPage do
  config.batch_actions = false

  actions :all

  config.per_page = 20
  config.paginate = true

  menu label: 'Upcoming Pages', parent: 'Ship'

  scope(:pending_featuring)

  permit_params(*Admin::UpcomingPageForm.attribute_names)

  filter :id
  filter :name
  filter :slug
  filter :user_id
  filter :created_at
  filter :status
  filter :featured_at
  filter :trashed_at

  index pagination_total: false do
    selectable_column

    column :id

    column :name do |upcoming_page|
      link_to upcoming_page.name, upcoming_page_path(upcoming_page)
    end

    column :slug
    column :tagline

    column :user do |upcoming_page|
      link_to upcoming_page.user.username, admin_user_path(upcoming_page.user)
    end

    column :status
    column :featured_at
    column :trashed_at

    actions
  end

  member_action :trash, method: :put do
    resource.trash
    redirect_to resource_path, notice: "Upcoming page has been trashed, can no longer be seen anywhere on the site. Click 'Restore Upcoming Page' to undo."
  end

  member_action :restore, method: :put do
    resource.restore
    redirect_to resource_path, notice: 'Upcoming page has been restored!'
  end

  member_action :delete_subscribers, method: :delete do
    Admin::DeleteUpcomingPageSubscribers.perform_later(resource)
  end

  action_item 'Trash Post', only: %i(edit show) do
    if resource.trashed?
      link_to 'Restore Post', restore_admin_upcoming_page_url(resource), method: :put
    else
      link_to 'Trash Post (Can be restored)', trash_admin_upcoming_page_url(resource), method: :put
    end
  end

  action_item 'Delete Imported Subscribers', only: %i(show), if: proc { resource.subscribers.where(source_kind: 'import').present? } do
    link_to 'Delete Imported Subscribers', delete_subscribers_admin_upcoming_page_url(resource), data: { method: :delete, confirm: 'Are you sure you want to do this?' }
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :name
      f.input :user_id, as: :reference, label: 'User ID'
      f.input :ship_account_id, as: :reference, label: 'Ship account ID'
      f.input :inbox_slug, hint: "Delivery email address: #{ f.object.inbox_slug }"

      unless f.object.new_record?
        f.input :tagline
        f.input :slug
        f.input :hiring
        f.input :status
        f.input :featured_at, as: :datetime_picker, hint: 'If you provide a date in future it won\'t appear before that'
      end
    end

    f.actions
  end

  show do
    default_main_content

    panel 'Moderation Log' do
      table_for upcoming_page.moderation_logs.with_preloads.order(created_at: :desc) do
        column 'Action', :message
        column :moderator
        column :created_at
      end
    end
  end

  controller do
    def find_resource
      scoped_collection.friendly.find(params[:id])
    end

    def scoped_collection
      UpcomingPage.includes [:user]
    end

    def create
      user = User.find(permitted_params[:upcoming_page][:user_id])

      upcoming_page = UpcomingPage.create!(
        name: permitted_params[:upcoming_page][:name],
        user: user,
        account: user.ship_account,
      )

      UpcomingPages::MakerTasks.bootstrap(upcoming_page)

      respond_with upcoming_page, location: admin_upcoming_pages_path
    end

    def update
      @upcoming_page = Admin::UpcomingPageForm.new find_resource, current_user
      @upcoming_page.update permitted_params[:upcoming_page]

      respond_with @upcoming_page, location: admin_upcoming_pages_path
    end

    def destroy
      if resource.trashed?
        redirect_to admin_upcoming_pages_path, notice: 'ERROR: Upcoming Page is already trashed, ask a developer if you need to restore them'
        return
      end

      resource.trash
      redirect_to admin_upcoming_pages_path, notice: 'Upcoming Page trashed'
    end
  end
end
