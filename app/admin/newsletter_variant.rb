# frozen_string_literal: true

ActiveAdmin.register NewsletterVariant do
  menu label: 'Test Variants', parent: 'Newsletters'
  actions :all

  permitted_params = [
    :newsletter_experiment_id,
    :variant_winner,
    :subject,
    sections: %i(layout title url content image_uuid),
  ]

  permit_params(*permitted_params)

  config.batch_actions = false
  config.per_page = 40
  config.paginate = true

  filter :newsletter_experiment_id

  controller do
    def scoped_collection
      NewsletterVariant.includes(:newsletter_experiment)
    end

    def new
      @newsletter_variant = NewsletterVariant.new
      @newsletter_variant.sections = Newsletter::Section.default_sections
      @newsletter_variant
    end
  end

  index do
    column :id
    column 'Experiment ID' do |newsletter_variant|
      link_to newsletter_variant.newsletter_experiment_id, admin_newsletter_experiment_path(newsletter_variant.newsletter_experiment_id)
    end
    column :variant_winner
    column :subject
    column :status
    column do |newsletter_variant|
      [
        link_to('View', admin_newsletter_variant_path(newsletter_variant)),
        link_to('Edit', edit_admin_newsletter_variant_path(newsletter_variant)),
      ].compact.join('  ').html_safe
    end
  end

  sidebar 'Result', only: :show do
    attributes_table_for newsletter_variant do
      row 'Opened' do |newsletter_variant|
        newsletter_variant.opened.count
      end
      row 'Delivered' do |newsletter_variant|
        newsletter_variant.delivered.count
      end
    end
  end

  form do |f|
    f.inputs 'Variant' do
      f.input :newsletter_experiment_id, required: true
    end

    f.inputs 'Subject Testing' do
      f.input :subject
    end

    div render('builder', newsletter: f.object)

    if f.object.persisted?
      f.inputs 'Winner' do
        f.input :variant_winner
      end
    end

    f.actions
  end

  action_item :view, only: :show do
    link_to 'View Experiment', admin_newsletter_experiment_path(newsletter_variant.newsletter_experiment)
  end

  action_item :test_send, only: :show do
    link_to 'Test Send', test_admin_newsletter_variant_path(newsletter_variant) if newsletter_variant.subject.present? && newsletter_variant.newsletter_experiment.sendable?
  end

  member_action :test, method: :get do
  end

  member_action :test_send, method: :post do
    if Newsletter::Email.deliver_test resource, params[:user][:email]
      redirect_to admin_newsletter_variant_path(resource), notice: 'Test email sent!'
    else
      redirect_to admin_newsletter_variant_path(resource), alert: 'We got some error!'
    end
  end
end
