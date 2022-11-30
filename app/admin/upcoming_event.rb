# frozen_string_literal: true

ActiveAdmin.register Upcoming::Event do
  actions :all

  menu label: 'Upcoming Events', parent: 'Products'

  permit_params(
    :title,
    :description,
    :banner,
    :banner_mobile,
    :product_id,
    :post_id,
    :user_id,
    :active,
    :status,
  )

  filter :title
  filter :description
  filter :created_at
  filter :updated_at

  controller do
    def update
      super

      return unless resource.saved_change_to_status? && resource.errors.empty?

      ModerationLog.create!(
        reference: resource,
        message: ModerationLog::REVIEWED_IN_ADMIN_MESSAGE,
        moderator: current_user,
      )
    end
  end

  index pagination_total: false do
    selectable_column

    column :id
    column :banner do |event|
      image_tag event.banner_url, width: 130, height: 'auto'
    end
    column 'Mobile Banner' do |event|
      if event.banner_mobile_uuid?
        image_tag event.banner_mobile_url, width: 130, height: 'auto'
      end
    end
    column :title
    column :product
    column :post
    column :user
    column :status
    column :active
    column :created_at
    column :updated_at
    column :schedule_time do |upcoming_event|
      post = upcoming_event.post
      next if post.blank?

      # Note(AR): datetime format in config/initializers/active_admin.rb
      format = '%m/%d/%y %H:%M'
      schedule = post.scheduled? ? '⏳ scheduled' : '✅ visible'

      "#{ post.scheduled_at.strftime(format) }<br>#{ schedule }".html_safe
    end

    actions
  end

  show do
    default_main_content

    render 'admin/shared/audits'
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Details' do
      f.input :banner, as: :file, hint: image_preview_hint(f.object.banner_url, '')
      f.input :banner_mobile, label: 'Mobile banner', as: :file, hint: image_preview_hint(f.object.banner_mobile_url, '')
      f.input :title
      f.input :description, as: :text
      f.input :product_id
      f.input :post_id
      f.input :user_id, as: :hidden, input_html: { value: current_user.id }
      f.input :active, as: :boolean
      f.input :status, as: :select, collection: Upcoming::Event.statuses
    end

    f.actions
  end
end
