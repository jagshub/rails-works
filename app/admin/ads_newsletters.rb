# frozen_string_literal: true

ActiveAdmin.register Ads::Newsletter do
  menu label: 'Ads -> Newsletter In-Feed Sponsorship', parent: 'Revenue'

  permit_params :active, :weight

  config.clear_action_items!
  config.batch_actions = false

  filter :active
  filter :weight

  scope :active, default: true
  scope :inactive

  controller do
    before_action { @page_title = 'Newsletter In-Feed Sponsorship' }
  end

  index do
    id_column
    column :budget
    column :newsletter do |resource|
      if resource.newsletter_id&.present?
        newsletter = resource.newsletter
        link_to newsletter.id, admin_newsletter_path(newsletter)
      else
        status_tag 'Auto', class: 'yes'
      end
    end
    column :weight do |resource|
      bip_tag(
        resource,
        :weight,
        reload: true,
        url: admin_ads_newsletter_path(resource),
      )
    end
    column :active do |resource|
      bip_status_tag(
        resource,
        :active,
        reload: true,
        url: admin_ads_newsletter_path(resource),
      )
    end
    actions
  end

  show do
    default_main_content do
      row :weight do |resource|
        bip_tag(
          resource,
          :weight,
          reload: true,
          url: admin_ads_newsletter_path(resource),
        )
      end
      row :active do |resource|
        bip_status_tag(
          resource,
          :active,
          reload: true,
          url: admin_ads_newsletter_path(resource),
        )
      end
    end

    render 'admin/shared/audits'
  end

  form do |f|
    f.semantic_errors *f.object.errors.attribute_names

    div do
      strong 'For full form, visit budget edit page'
      span link_to(f.object.budget.id, edit_admin_budget_path(f.object.budget))
    end

    f.inputs 'Post Ad configuration' do
      f.input :weight
      f.input :active
    end

    f.actions
  end
end
