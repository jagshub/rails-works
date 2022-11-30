# frozen_string_literal: true

ActiveAdmin.register MakersFestival::Category do
  menu label: 'Categories', parent: 'Makers Festival'
  actions :all

  permit_params %i(name tagline emoji makers_festival_edition_id)

  config.per_page = 20
  config.paginate = true

  filter :makers_festival_edition_id
  filter :name

  controller do
    def scoped_collection
      MakersFestival::Category.includes(:makers_festival_edition)
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :makers_festival_edition_id
      f.input :emoji
      f.input :name
      f.input :tagline, as: :text, hint: 'Accepts HTML code'
    end

    f.actions
  end
end
