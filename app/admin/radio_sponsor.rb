# frozen_string_literal: true

ActiveAdmin.register Radio::Sponsor do
  menu label: 'Radio Sponsors', parent: 'Others'
  actions :all

  permit_params %i(
    name
    link
    image_uuid
    start_datetime
    end_datetime
    image_width
    image_height
    image_thumbnail_width
    image_thumbnail_height
    image_class_name
  )

  config.per_page = 20
  config.paginate = true

  filter :name
  filter :start_datetime
  filter :end_datetime

  scope(:all, default: true)
  scope(:active, &:active)

  index do
    selectable_column

    column :id
    column :name
    column :start_datetime
    column :end_datetime
    column :link

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :name
      f.input :start_datetime, as: :datetime_picker
      f.input :end_datetime, as: :datetime_picker
      f.input :link, hint: 'Should include http:// or https:// (Example: http://example.com)'
      div render('image', sponsor: f.object)
      f.input :image_width
      f.input :image_height
      f.input :image_thumbnail_width
      f.input :image_thumbnail_height
      f.input :image_class_name
    end

    f.actions
  end
end
