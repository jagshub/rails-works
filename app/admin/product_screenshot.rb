# frozen_string_literal: true

ActiveAdmin.register Products::Screenshot, as: 'Product Screenshots' do
  menu label: 'Product Screenshots', parent: 'Products'

  permit_params(
    :product_id,
    :image,
    :alt_text,
    :position,
  )

  filter :alt_text

  index do
    selectable_column

    column :image do |screenshot|
      image_preview_hint(screenshot.image_url, '', image_url_suffix: '?auto=format&h=50')
    end
    column :id
    column :position
    column :alt_text
    column :image_uuid
    column :user

    actions
  end

  show do
    default_main_content do
      row 'Image preview' do |product_screenshot|
        image_preview_hint(product_screenshot.image_url, '', image_url_suffix: '?auto=format&h=160')
      end
    end
  end

  form do |f|
    f.semantic_errors

    f.inputs 'Details' do
      f.input :product_id, label: 'Product ID'
      f.input :image, as: :file, hint: image_preview_hint(f.object.image_url, '', image_url_suffix: '?auto=format&h=160')
      f.input :alt_text
      f.input :position
    end

    f.actions
  end
end
