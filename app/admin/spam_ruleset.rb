# frozen_string_literal: true

ActiveAdmin.register Spam::Ruleset do
  menu label: 'Rules', parent: 'Spam'

  config.batch_actions = true
  config.per_page = 20
  config.paginate = true

  permit_params :name,
                :note,
                :added_by_id,
                :active,
                :for_activity,
                :action_on_activity,
                :action_on_actor,
                :ignore_not_spam_log,
                :priority,
                rules_attributes: %i(id filter_kind value _destroy)

  filter :name
  filter :for_activity, as: :select, collection: Spam::Ruleset.for_activities

  controller do
    def scoped_collection
      Spam::Ruleset.includes :added_by
    end

    def new
      @spam_ruleset = Spam::Ruleset.new added_by: current_user
    end
  end

  index do
    selectable_column

    column :id
    column :name
    column :for_activity
    column :active
    column :action_on_activity
    column :action_on_actor
    column :false_positive_count
    column :checks_count
    column :priority
    column :note
    column :added_by_id

    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :for_activity
      row :active
      row :action_on_activity
      row :action_on_actor
      row :false_positive_count
      row :checks_count
      row :priority
      row :note
      row :added_by
      row :ignore_not_spam_log
      row :created_at
      row :updated_at
    end

    panel 'Rules' do
      table_for spam_ruleset.rules do
        column :filter_kind
        column :value
        column :checks_count
        column :false_positive_count
        column :checks_count
        column 'Filter Values' do |filter|
          link_to 'View Values', admin_spam_filter_values_url('q[filter_kind_eq]': Spam::FilterValue.filter_kinds[filter.filter_kind])
        end
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :name
      f.input :for_activity
      f.input :action_on_activity
      f.input :action_on_actor
      f.input :active
      f.input :priority
      f.input :ignore_not_spam_log, hint: "When this is checked, we won't store checks with result as not spam"
      f.input :note, hint: 'why adding this rule or any related notes?'
      f.input :added_by_id, as: :hidden
    end

    f.inputs 'Filters' do
      f.has_many :rules, heading: false, allow_destroy: true do |a|
        a.input :filter_kind
        a.input :value, hint: 'This is optional. When empty the values present in the filter will be taken & when value is present only that value will be used for checking'
      end
    end

    f.actions
  end
end
