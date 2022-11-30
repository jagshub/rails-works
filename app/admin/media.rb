# frozen_string_literal: true

ActiveAdmin.register Media do
  menu false

  filter :kind

  permit_params %i(uuid subject_id subject_type priority original_width original_height metadata original_url)

  index pagination_total: false do
    column do |media|
      image_tag media.image_url(width: 130, height: 95)
    end
    column :kind
    column :original_width
    column :original_height
    column :priority
    column :user
    column :created_at

    actions
  end

  form do |f|
    f.inputs 'Media' do
      f.input :uuid
      f.input :subject_id
      f.input :subject_type
      f.input :priority
      f.input :original_width
      f.input :original_height
      f.input :metadata
      f.input :original_url
      f.submit
    end
  end
end
