# frozen_string_literal: true

ActiveAdmin.register NewsletterExperiment do
  menu label: 'A/B Testing', parent: 'Newsletters'
  actions :all

  permitted_params = %i(
    newsletter_id
    test_count
  )

  permit_params(*permitted_params)

  config.batch_actions = false
  config.per_page = 40
  config.paginate = true

  filter :newsletter_id

  controller do
    def scoped_collection
      NewsletterExperiment.includes(:newsletter, :variants)
    end
  end

  index do
    column :id
    column 'Newsletter' do |newsletter_experiment|
      link_to newsletter_experiment.newsletter_id, admin_newsletter_path(newsletter_experiment.newsletter)
    end
    column :status
    column :test_count
    column 'Total Variants' do |newsletter_experiment|
      newsletter_experiment.variants.count
    end
    column do |newsletter_experiment|
      [
        link_to('View', admin_newsletter_experiment_path(newsletter_experiment)),
        link_to('Edit', edit_admin_newsletter_experiment_path(newsletter_experiment)),
        link_to('Variants', admin_newsletter_variants_path('q[newsletter_experiment_id_eq]': newsletter_experiment.id)),
      ].compact.join('  ').html_safe
    end
  end

  show do
    default_main_content

    panel 'Logs' do
      table_for newsletter_experiment do
        column 'Count' do
          newsletter_experiment.deliveries_count
        end
      end
    end

    panel 'Variants' do
      table_for newsletter_experiment.variants do
        column :id
        column :subject
        column :status
        column 'Opened' do |variant|
          variant.opened.count
        end
        column 'Delivered' do |variant|
          variant.delivered.count
        end
        column 'Ratio', &:open_ratio
        column do |variant|
          [
            link_to('View', admin_newsletter_variant_path(variant)),
            link_to('Edit', edit_admin_newsletter_variant_path(variant)),
          ].compact.join('  ').html_safe
        end
      end
    end
  end

  form do |f|
    f.inputs do
      f.semantic_errors(*f.object.errors.attribute_names)
      f.input :newsletter_id, required: true
      f.input :test_count, required: true, hint: 'Total number of people for testing. Make sure the count is divisble by the number of variants.'
    end

    f.actions
  end

  action_item :new, only: :show do
    link_to 'Add Variant', new_admin_newsletter_variant_path
  end

  action_item :send_experiment, only: :show, if: proc { newsletter_experiment.sendable? } do
    link_to 'Send Experiment', send_experiment_admin_newsletter_experiment_path(newsletter_experiment), data: { confirm: "Would you like to send experiment with #{ newsletter_experiment.variants.count } variants?" }
  end

  action_item :finish_experiment, only: :show, if: proc { newsletter_experiment.sent? } do
    link_to 'Finish Experiment', finish_experiment_admin_newsletter_experiment_path(newsletter_experiment)
  end

  member_action :send_experiment do
    sent = Newsletter::Experiment::Send.call resource

    redirect_to admin_newsletter_experiment_path(resource), notice: sent ? 'Experiment sent!' : 'Sending experiment failed. Please check number of variants or test count'
  end

  member_action :finish_experiment do
    finished = Newsletter::Experiment::Finish.call resource

    redirect_to finished ? admin_newsletter_path(resource.newsletter) : admin_newsletter_experiment_path(resource), notice: finished ? 'Newsletter updated. Review & click on SEND to send to the rest of the subscribers.' : 'We got some error. Please make sure to select a winner in the variant page'
  end
end
