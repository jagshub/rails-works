# frozen_string_literal: true

ActiveAdmin.register Discussion::Thread do
  Admin::UseForm.call self, Discussion::Admin::ThreadForm
  Admin::AddTrashing.call(self)

  menu label: 'Threads', parent: 'Discussion'
  actions :all

  permit_params %i(title description user_id subject_type subject_id anonymous pinned featured_at trending_at)

  config.per_page = 20
  config.paginate = true

  filter :subject_id
  filter :subject_type, as: :select, collection: Discussion::Thread::SUBJECT_TYPES.sort
  filter :featured_at

  scope(:all, default: true)
  scope('Featured Today') { |scope| scope.where(featured_at: Time.current.to_date) }
  scope('Featured') { |scope| scope.where.not(featured_at: nil).order(featured_at: :desc) }
  scope('Pending for approval') { |scope| scope.where(status: 'pending').not_trashed }
  scope :pinned

  controller do
    def scoped_collection
      Discussion::Thread.includes(:subject, :category)
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    end
  end

  index do
    selectable_column

    column :id
    column :title
    column :subject_type
    column :subject_id
    column :user
    column :pinned
    column :anonymous
    column :category
    column :created_at
    column :featured_at
    column :trashed_at
    column :status

    actions
  end

  show do
    attributes_table do
      row :id
      row :title
      row :trashed_at
      row :subject_type
      row :subject_id
      row :user
      row :pinned
      row :anonymous
      row :category
      row :created_at
      row :featured_at
      row :status
    end

    render 'admin/shared/audits'
  end

  form do |f|
    f.inputs 'Details' do
      f.input :subject_type,
              as: :select,
              collection: ::Discussion::Thread::SUBJECT_TYPES,
              include_blank: false,
              selected: params[:subject_type] || f.object&.subject_type || Discussion::Thread::SUBJECT_TYPES.first
      f.input :subject_id, input_html: { value: params[:subject_id] || f.object&.subject_id || nil }
      f.input :title
      f.input :description, as: :text
      f.input :user_id
      f.input :anonymous, as: :boolean
      f.input :pinned, as: :boolean
      f.has_many :category_associations,
                 new_record: true do |r|
        r.input :category,
                as: :select,
                collection: ::Discussion::Category.pluck(:name, :id).to_h,
                hint: 'You may only have one category at a time. If more than one is present on save - only the last one will be used.'
      end
      f.input :featured_at, as: :date_picker
      f.input :trending_at, as: :date_picker
    end

    f.actions
  end

  member_action :hide_in_discussion, method: :put do
    resource.hide
    redirect_to resource_path, notice: 'Thread is now hidden in discussions'
  end

  member_action :approve_discussion, method: :put do
    resource.update! status: 'approved'
    DiscussionsMailer.approval(resource, resource.user).deliver_later

    redirect_to admin_discussion_threads_path(scope: 'pending_for_approval'), notice: 'Thread approved'
  end

  member_action :show_in_discussion, method: :put do
    resource.show
    redirect_to resource_path, notice: 'Thread is now shown in discussions'
  end

  member_action :feature_discussion, method: :put do
    resource.update! featured_at: Time.current.to_date

    redirect_to resource_path, notice: 'Thread featured for hp today'
  end

  member_action :unfeature_discussion, method: :put do
    resource.update! featured_at: nil

    redirect_to resource_path, notice: 'Thread unfeatured'
  end

  action_item :featured_at, only: %i(edit show), if: proc { resource.subject_type == MakerGroup.name } do
    if resource.featured_at?
      link_to 'Unfeature', [:unfeature_discussion, :admin, resource], method: :put
    else
      link_to 'Feature Today', [:feature_discussion, :admin, resource], method: :put
    end
  end

  action_item 'Hide', only: %i(edit show) do
    if resource.hidden?
      link_to 'Show in discussions', [:show_in_discussion, :admin, resource], method: :put
    else
      link_to 'Hide in discussions', [:hide_in_discussion, :admin, resource], method: :put
    end
  end

  action_item 'Approve', only: %i(show) do
    link_to 'Approve Thread', { action: 'approve_discussion' }, method: :put
  end
end
