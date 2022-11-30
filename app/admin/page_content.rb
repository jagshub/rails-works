# frozen_string_literal: true

ActiveAdmin.register PageContent do
  menu label: 'Page Content', parent: 'Others'

  actions :all

  permit_params %i(
    page_key
    element_key
    content
    image
  )

  config.per_page = 20
  config.paginate = true

  filter :page_key
  filter :element_key

  index do
    column :id
    column :page_key
    column :element_key

    actions
  end

  show do
    attributes_table do
      row :id
      row :page_key
      row :element_key
      row :content
      row :image do |page_content|
        if page_content.image_uuid.present?
          link_to(
            image_tag(page_content.image_url, height: 100, width: 'auto'),
            page_content.image_url,
            target: '_blank',
            rel: 'noopener',
          )
        end
      end
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :page_key, hint: 'use lowercase & underscore instead of space. eg: pro_tips'
      f.input :element_key, hint: 'use lowercase & underscore instead of space. eg: main_header'
      f.input :content, hint: 'no html allowed'
      f.input :image, as: :file, hint: image_preview_hint(f.object.image_url, 'Preview')
    end

    f.actions
  end
end
