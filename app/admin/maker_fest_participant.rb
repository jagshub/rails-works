# frozen_string_literal: true

ActiveAdmin.register MakerFest::Participant do
  menu label: 'Makers Fest', parent: 'Others'
  actions :all

  permit_params :category_slug, :user_id, :upcoming_page_id, :external_link

  config.per_page = 20
  config.paginate = true

  filter :upcoming_page_id
  filter :user_id

  controller do
    def scoped_collection
      MakerFest::Participant.includes(:upcoming_page, :user)
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :category_slug, as: :select
      f.input :user_id
      f.input :upcoming_page_id
      f.input :external_link
    end

    f.actions
  end
end
