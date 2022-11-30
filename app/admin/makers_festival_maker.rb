# frozen_string_literal: true

ActiveAdmin.register MakersFestival::Maker do
  menu label: 'Makers', parent: 'Makers Festival'
  actions :all

  permit_params %i(user_id makers_festival_participant_id)

  config.per_page = 20
  config.paginate = true

  filter :makers_festival_participant_id
  filter :user_id

  controller do
    def scoped_collection
      MakersFestival::Maker.includes(:makers_festival_participant, :user)
    end
  end

  form do |f|
    f.inputs 'Details' do
      f.input :makers_festival_participant_id
      f.input :user_id
    end

    f.actions
  end
end
