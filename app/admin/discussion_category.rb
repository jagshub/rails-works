# frozen_string_literal: true

ActiveAdmin.register Discussion::Category do
  menu label: 'Category', parent: 'Discussion'
  actions :all

  permit_params %i(name description thumbnail)

  config.per_page = 20
  config.paginate = true
  config.batch_actions = false

  filter :name
  filter :description

  controller do
    def find_resource
      Discussion::Category.find_by_slug!(params[:id])
    end
  end

  index do
    column :id
    column :thumbnail do |category|
      image_preview_hint(
        category.thumbnail_url,
        '',
        image_url_suffix: '?auto=format&w=80&h=80',
      )
    end
    column :name
    column :description
    column :discussion_thread_count do |category|
      link_to(
        category.discussion_thread_count,
        admin_discussion_threads_path(q: { category_id_eq: category.id }),
      )
    end

    actions
  end

  show do
    attributes_table do
      row :id
      row :name
      row :slug
      row :description
      row 'Thumbnail' do
        image_preview_hint(
          discussion_category.thumbnail_url,
          '',
          image_url_suffix: '?auto=format&w=80&h=80',
        )
      end
      row :discussion_thread_count
      row :created_at
      row :updated_at
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :name
      f.input :thumbnail,
              as: :file,
              hint: image_preview_hint(
                f.object.thumbnail_url,
                '',
                image_url_suffix: '?auto=format&w=80&h=80',
              )

      f.input :description
    end

    f.actions
  end
end
