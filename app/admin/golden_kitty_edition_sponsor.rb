# frozen_string_literal: true

ActiveAdmin.register GoldenKitty::EditionSponsor do
  menu label: 'EditionSponsor', parent: 'Golden Kitty'
  actions :all

  permit_params(
    :edition_id,
    :sponsor_id,
  )

  config.per_page = 20
  config.paginate = true

  filter :edition_id
  filter :sponsor_id

  controller do
    def scoped_collection
      GoldenKitty::EditionSponsor.includes(:edition, :sponsor)
    end
  end

  index do
    selectable_column

    column :id
    column :edition
    column :sponsor

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :edition_id
      f.input :sponsor_id
    end

    f.actions
  end
end
