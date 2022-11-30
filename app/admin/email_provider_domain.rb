# frozen_string_literal: true

ActiveAdmin.register EmailProviderDomain do
  menu label: 'Email Provider Domains', parent: 'Others'

  sidebar :description do
    html do
      div 'Email Provider Domains list.'
      br
      div 'This is used to disable Team Claims automatic approval process for email-provider products.'
      br
      div 'Products with website domain matching any of the email provider domains will be disabled for automatic claims approval.'
    end
  end

  config.batch_actions = true
  config.per_page = 20
  config.paginate = true

  permit_params %i(
    value
    added_by_id
  )

  filter :value

  controller do
    def scoped_collection
      EmailProviderDomain.includes :added_by
    end

    def new
      @email_provider_domain = EmailProviderDomain.new added_by: current_user
    end

    def create
      input = permitted_params.dig(:email_provider_domain, :value)
      values = input.split(',').map(&:strip).reject(&:blank?)

      values.each do |value|
        EmailProviderDomain.create value: value, added_by: current_user
      end

      admin_email_provider_domains_path

      redirect_to admin_email_provider_domains_path, notice: 'Email Provider Domain value added'
    end
  end

  index do
    selectable_column

    column :id
    column :value
    column :added_by

    actions
  end

  show do
    attributes_table do
      row :id
      row :value
      row :added_by
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      if f.object.new_record?
        f.input :value, as: :text, hint: 'Comma-separated list of email provider domains. Example: gmail.com, yahoo.com, msn.com'
      else
        f.input :value
      end

      f.input :added_by_id, as: :hidden
    end

    f.actions
  end
end
