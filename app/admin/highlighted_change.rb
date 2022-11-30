# frozen_string_literal: true

ActiveAdmin.register HighlightedChange do
  menu label: 'Highlighted Changes', parent: 'Content'

  permit_params :title, :cta_text, :cta_url, :body, :platform, :user_id, :status, :start_date, :end_date, :desktop_image, :tablet_image, :mobile_image

  filter :id
  filter :title
  filter :user_id
  filter :status
  filter :platform
  filter :start_date
  filter :end_date

  index pagination_total: false do
    selectable_column

    column :id
    column :user_id
    column :title
    column :status
    column :platform
    column :start_date
    column :end_date
    column :created_at
    column :updated_at

    actions
  end

  controller do
    def new
      @highlighted_change = HighlightedChange.new(user: current_user)
    end
  end

  action_item :deactivate_old_changes, priority: 0, only: :index do
    link_to 'Deactivate old changes',  action: :deactivate_old_changes, method: :post
  end

  collection_action :deactivate_old_changes, method: %i(post get) do
    HighlightedChange.where('end_date < ?', Time.zone.today).each do |change|
      change.update! status: :inactive
    end
    redirect_to collection_path, alert: 'Any change with end date before today is marked inactive.'
  end

  form do |f|
    f.inputs 'Highlighted Change Details' do
      f.input :user, as: :select, collection: User.admin
      f.input :title, hint: 'Max 50 characters'
      f.input :body, hint: 'Max 500 characters'
      f.input :cta_text, label: 'CTA text', hint: 'Max 20 characters'
      f.input :cta_url, label: 'CTA link', hint: 'Must be a valid URL, (starts with http:// or https://)'
      f.input :platform, as: :select, collection: HighlightedChange.platforms
      f.input :status, as: :select, collection: HighlightedChange.statuses, hint: 'Testing change is only shown to admins and ignores the start and end dates.'
      f.input :start_date, as: :datepicker, input_html: { autocomplete: :off }
      f.input :end_date, as: :datepicker, input_html: { autocomplete: :off }
      f.input :desktop_image, label: 'Desktop image', as: :file, hint: image_preview_hint(f.object.desktop_image_url, 'Preferred width:&nbsp; 450px-500px')
    end
    f.actions
  end
end
