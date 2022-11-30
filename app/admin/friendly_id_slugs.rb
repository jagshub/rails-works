# frozen_string_literal: true

ActiveAdmin.register FriendlyId::Slug do
  menu label: 'FriendlyID Slugs', parent: 'Others'

  filter :slug
  filter :sluggable_type

  permit_params(
    :slug,
    :sluggable_id,
    :sluggable_type,
  )

  config.per_page = 20
  config.paginate = true

  form do |f|
    f.inputs 'Details' do
      f.input :slug, hint: "Only change this if you know it's an old slug"
      f.input :sluggable_id
      f.input :sluggable_type
    end

    f.actions
  end
end
