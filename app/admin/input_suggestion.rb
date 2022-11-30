# frozen_string_literal: true

ActiveAdmin.register InputSuggestion do
  menu label: 'InputSuggestions', parent: 'Others'

  permitted_params = %i(name kind parent_id csv_file)
  permit_params(*permitted_params)

  config.batch_actions = false
  config.per_page = 40
  config.paginate = true

  filter :name, as: :string
  filter :kind, as: :select, collection: InputSuggestion.kinds
  filter :parent_id

  controller do
    def create
      inputs = params[:input_suggestion]

      if inputs[:csv_file].present?
        InputSuggestions::CreateFromCsv.call inputs[:csv_file]
        redirect_to admin_input_suggestions_path
      else
        input_suggestion = InputSuggestion.find_or_create_by! name: inputs[:name], kind: inputs[:kind], parent_id: inputs[:parent_id]
        redirect_to admin_input_suggestion_path(input_suggestion)
      end
    end
  end

  form do |f|
    f.semantic_errors
    panel 'Single record' do
      f.inputs do
        f.input :name, as: :string, required: true
        f.input :kind, required: true
        f.input :parent_id
      end
    end
    unless f.object.persisted?
      panel 'Upload csv file (for bulk creation)' do
        f.inputs do
          f.input :csv_file, as: :file
          f.br
          f.div 'Note: CSV file should have two/three columns- name, kind & parent_id (no need to add those as header). Example: "developer, role" or "react, skill, 3". Here 3 is the id of the parent you want to map.'
        end
      end
    end
    f.actions
  end
end
