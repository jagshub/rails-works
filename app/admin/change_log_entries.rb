# frozen_string_literal: true

ActiveAdmin.register ChangeLog::Entry do
  Admin::UseForm.call self, ChangeLog::Admin::EntryForm

  menu label: 'ChangeLog', parent: 'Others'

  config.sort_order = 'date_desc'
  config.batch_actions = false

  filter :state, as: :select, collection: ChangeLog::Entry.states
  filter :title
  filter :date, as: :date_range
  filter :major_update, as: :boolean
  filter :has_discussion, as: :boolean

  scope :published, default: true
  scope :pending

  actions :all, except: :destroy

  order_by :date do |clause|
    if clause.order == 'desc'
      'DATE DESC NULLS LAST'
    else
      'DATE ASC NULLS LAST'
    end
  end

  member_action :unpublish do
    form = ChangeLog::Admin::EntryForm.new(resource)
    form.update(state: :pending)

    redirect_back(
      notice: "Change Log #{ resource.id } has been unpublished!",
      fallback_location: admin_change_log_entries_path,
    )
  end

  member_action :publish do
    form = ChangeLog::Admin::EntryForm.new(resource)
    form.update(state: :published)

    redirect_back(
      notice: "Change Log #{ resource.id } has been published!",
      fallback_location: admin_change_log_entries_path,
    )
  end

  member_action :destroy_media do
    resource.media.find(params[:media_id]).destroy

    redirect_back(
      notice: "Change Log Media #{ params[:media_id] } has been destroyed!",
      fallback_location: admin_change_log_entries_path,
    )
  end

  member_action :bip, method: :put do
    form = ChangeLog::Admin::EntryForm.new(resource)
    form.update(params[:change_log_entry].permit!)

    respond_with_bip resource
  end

  index do
    id_column
    column :date, sortable: :date do |resource|
      best_in_place(
        resource,
        :date,
        as: :date,
        url: bip_admin_change_log_entry_path(resource),
      )
    end
    column :state do |resource|
      if resource.pending?
        status_tag 'Pending', class: 'no'
      elsif resource.published?
        status_tag 'Published', class: 'yes'
      end
    end
    column :title
    column 'Major?', &:major_update
    column 'Discussion' do |resource|
      if resource.discussion.present?
        link_to(
          resource.discussion.id,
          admin_discussion_thread_path(resource.discussion),
        )
      else
        status_tag resource.has_discussion
      end
    end
    column 'Notified?', &:notification_sent

    actions do |resource|
      span link_to 'Publish', publish_admin_change_log_entry_path(resource) if resource.can_publish?
      span link_to 'Unpublish', unpublish_admin_change_log_entry_path(resource) if resource.can_unpublish?
    end
  end

  show do
    default_main_content

    panel 'Media' do
      table_for change_log_entry.media.by_priority do
        column 'Preview' do |media|
          image_tag media.image_url(width: 130, height: 95)
        end
        column :priority
        column :image_url
        column :created_at

        column :destroy do |media|
          link_to(
            'Delete',
            destroy_media_admin_change_log_entry_path(
              resource,
              media_id: media.id,
            ),
          )
        end
      end
    end
  end

  action_item :unpublish, only: :show, if: -> { resource.can_unpublish? } do
    link_to 'Unpublish', unpublish_admin_change_log_entry_path(resource)
  end

  action_item :publish, only: :show, if: -> { resource.can_publish? } do
    link_to 'Publish', publish_admin_change_log_entry_path(resource)
  end

  action_item :in_site, only: :show do
    link_to 'In Site', change_log_path(resource)
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    f.inputs do
      f.input :state, as: :select, collection: ChangeLog::Entry.states
      f.input :title, input_html: { autocomplete: :off }

      f.input :date, as: :datepicker, input_html: { autocomplete: :off }
      f.input :major_update, as: :boolean
      f.input :has_discussion, as: :boolean
      f.input :author_id, as: :select, collection: User.admin
    end

    panel 'Description (markdown)' do
      div class: 'markdown-input' do
        f.input :description_md,
                as: :text,
                label: false,
                input_html: { rows: 50, id: 'markdown-value' }

        div class: 'markdown-preview' do
          tag.iframe(
            '',
            src: Routes.dev_markdown_url,
            width: '100%',
            height: '100%',
          )
        end
      end
    end

    panel 'Media' do
      f.has_many :media,
                 heading: false,
                 sortable: :priority,
                 allow_destroy: true do |m|
        m.input :media,
                as: :file,
                hint: image_preview_hint(m.object.image_url, 'Image')

        m.input :image_url,
                label: 'media_url',
                hint: 'use in markdown editor with ![Alt Name](media_url)',
                input_html: { disabled: true }
      end
    end

    if f.object.persisted? && f.object.has_discussion
      strong 'NOTE: Updating description does not update associated discussion'
    end

    f.actions
  end
end
