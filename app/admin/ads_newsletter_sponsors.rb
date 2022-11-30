# frozen_string_literal: true

ActiveAdmin.register Ads::NewsletterSponsor, as: 'Newsletter Sponsor' do
  menu label: 'Ads -> Newsletter Topline Sponsorship', parent: 'Revenue'

  permit_params :active, :weight

  config.clear_action_items!
  config.batch_actions = false

  filter :active
  filter :weight

  scope :active, default: true
  scope :inactive

  controller do
    before_action { @page_title = 'Newsletter Topline Sponsorship' }
  end

  index do
    id_column
    column :budget
    column :weight do |resource|
      bip_tag(
        resource,
        :weight,
        reload: true,
        url: admin_newsletter_sponsor_path(resource),
      )
    end
    column :active do |resource|
      bip_status_tag(
        resource,
        :active,
        reload: true,
        url: admin_newsletter_sponsor_path(resource),
      )
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :budget
      row :description_html
      row :url
      row :url_params
      row :cta
      row :weight do |resource|
        bip_tag(
          resource,
          :weight,
          reload: true,
          url: admin_newsletter_sponsor_path(resource),
        )
      end
      row :active do |resource|
        bip_status_tag(
          resource,
          :active,
          reload: true,
          url: admin_newsletter_sponsor_path(resource),
        )
      end
      row :image do |resource|
        image_preview_hint(resource.image_url, 'Brought to you by image')
      end
      row :body_image do |resource|
        image_preview_hint(resource.body_image_url, 'Body Image')
      end
      row :created_at
      row :updated_at
    end

    render 'admin/shared/audits'
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    div do
      strong 'For full form, visit budget edit page'
      span link_to(f.object.budget.id, edit_admin_budget_path(f.object.budget))
    end

    f.inputs 'Sponsorship configuration' do
      f.input :weight
      f.input :active
    end

    f.actions
  end
end
