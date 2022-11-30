# frozen_string_literal: true

ActiveAdmin.register Spam::FilterValue do
  menu label: 'Filter Values', parent: 'Spam'

  config.batch_actions = true
  config.per_page = 20
  config.paginate = true

  permit_params %i(
    filter_kind
    value
    note
    added_by_id
    csv_file
  )

  filter :value
  filter :filter_kind, as: :select, collection: Spam::FilterValue.filter_kinds

  controller do
    def scoped_collection
      Spam::FilterValue.includes :added_by
    end

    def new
      @spam_filter_value = Spam::FilterValue.new added_by: current_user
    end

    def create
      inputs = permitted_params[:spam_filter_value]

      # Todo(Rahul): Handle error states
      resource = SpamChecks.admin_create_filter_value inputs

      redirect_path = if inputs[:csv_file].present?
                        admin_spam_filter_values_path
                      else
                        admin_spam_filter_value_path(resource)
                      end
      redirect_to redirect_path, notice: 'Filter value added'
    end
  end

  index do
    selectable_column

    column :id
    column :filter_kind
    column :value
    column :false_positive_count
    column :note
    column :added_by

    actions
  end

  show do
    attributes_table do
      row :id
      row :filter_kind
      row :value
      row :false_positive_count
      row :note
      row :added_by
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.attribute_names)

    f.inputs 'Details' do
      f.input :filter_kind
      f.input :value
      f.input :note, hint: 'why adding this filter value or any related notes?'
      f.input :added_by_id, as: :hidden
    end

    unless  f.object.persisted?
      panel 'Bulk Upload (Use csv file)' do
        f.inputs do
          f.input :csv_file, as: :file
          f.br
          f.div 'CSV file content format: filter_name, value'
          f.div 'eg: ip_filter, 1.1.1.1'
        end
      end
    end
    f.actions
  end
end
