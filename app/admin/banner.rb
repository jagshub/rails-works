# frozen_string_literal: true

ActiveAdmin.register Banner do
  menu label: 'Banners', parent: 'Content'

  permit_params :user_id, :status, :position, :start_date, :end_date, :description, :desktop_image, :wide_image, :tablet_image, :mobile_image, :url

  filter :id
  filter :user_id
  filter :status
  filter :position
  filter :start_date
  filter :end_date

  index pagination_total: false do
    selectable_column

    column :id
    column :user_id
    column :status
    column :position
    column :start_date
    column :end_date
    column :description
    column :desktop_image_uuid
    column :wide_image_uuid
    column :tablet_image_uuid
    column :mobile_image_uuid
    column :url
    column :created_at
    column :updated_at

    actions
  end

  controller do
    def new
      @banner = Banner.new(user: current_user)
    end
  end

  action_item :deactivate_old_banners, priority: 0, only: :index do
    link_to 'Deactivate old banners',  action: :deactivate_old_banners, method: :post
  end

  collection_action :deactivate_old_banners, method: %i(post get) do
    Banner.where('end_date <  ?', Time.zone.today).each do |banner|
      banner.update! status: :inactive
    end
    redirect_to collection_path, alert: 'Any banner with end date before today is marked inactive.'
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Banner Details' do
      f.input :user, as: :select, collection: User.admin
      f.input :status, as: :select, collection: Banner.statuses, hint: 'Testing banner is only shown to admins. It ignores the start and end dates.'
      f.input :position, as: :select, collection: Banner.positions
      f.input :start_date, as: :datepicker, input_html: { autocomplete: :off }
      f.input :end_date, as: :datepicker, input_html: { autocomplete: :off }
      f.input :description, input_html: { rows: 1, autocomplete: :off }
      f.input :desktop_image, label: 'Desktop image', as: :file, hint: image_preview_hint(f.object.desktop_image_url, 'Preferred sizes:&nbsp;<b> Main feed:</b> 1976 x 460 (1100px - 1439px) &nbsp;<b> Side bar:</b> 280 x 300 (≥1100px)')
      f.input :wide_image, label: 'Wide image', as: :file, hint: image_preview_hint(f.object.wide_image_url, 'Preferred sizes:&nbsp;<b> Main feed:</b> 2432 x 460 (≥1440px) &nbsp;<b> Side bar:</b> 280 x 300 (≥1440px)')
      f.input :tablet_image, label: 'Tablet image', as: :file, hint: image_preview_hint(f.object.tablet_image_url, 'Preferred sizes:&nbsp;<b> Main feed:</b> 1392 x 460 (760px - 1099px) &nbsp;<b> Side bar:</b> 460 x 320 (760px - 1099px)')
      f.input :mobile_image, label: 'Mobile image', as: :file, hint: image_preview_hint(f.object.mobile_image_url, 'Preferred sizes:&nbsp;<b> Main feed:</b> 460 x 320 (≤759px) &nbsp;<b> Side bar:</b> 460 x 320 (≤759px)')
      f.input :url, input_html: { rows: 1, autocomplete: :off }
    end
    f.actions
  end
end
