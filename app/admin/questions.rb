# frozen_string_literal: true

ActiveAdmin.register Question do
  menu label: 'Question', parent: 'Others'

  actions :all, :import

  permit_params %i(title answer post_id)

  filter :id
  filter :slug
  filter :post_id

  controller do
    defaults finder: :find_by_slug!
  end

  index do
    column :id
    column :post
    column :title
    column :slug do |q|
      link_to(q.slug, "/questions/#{ q.slug }")
    end

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.semantic_errors(*f.object.errors.attribute_names)

      f.input :title
      f.input :answer
      f.input :post_id, as: :string
    end

    f.actions
  end

  action_item :bulk_import, only: :index do
    link_to 'Import', action: 'bulk_import'
  end

  collection_action :bulk_import do
    @import = Questions.import_csv_form
  end

  collection_action :import, method: :post do
    @import = Questions.import_csv_form

    if params['import'].present? && @import.update(params.require(:import).permit(:csv))
      redirect_to admin_questions_path, notice: "Imported #{ @import.questions_count } question(s)"
    else
      render :bulk_import, import: @import
    end

  rescue ActiveRecord::RecordNotFound => e
    redirect_to admin_questions_path, flash: { error: e.message }
  end
end
