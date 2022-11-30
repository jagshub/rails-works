# frozen_string_literal: true

ActiveAdmin.register GoldenKitty::Person do
  menu label: 'Person', parent: 'Golden Kitty'
  actions :all

  permit_params(
    :user_id,
    :golden_kitty_category_id,
    :winner,
    :position,
  )

  filter :golden_kitty_category, collection: -> { GoldenKitty::Category.by_year.by_priority.map { |category| ["#{ category.name } #{ category.year }", category.id] } }
  filter :user_id
  filter :user_username, as: :string

  config.per_page = 40
  config.paginate = true

  controller do
    def scoped_collection
      GoldenKitty::Person.includes(:user)
    end
  end

  index do
    selectable_column

    column :id
    column :user
    column :golden_kitty_category_id
    column :winner
    column :position

    actions
  end

  form do |f|
    f.inputs 'Details' do
      f.input :user_id
      f.input :golden_kitty_category_id
      f.input :winner
      f.input :position
    end

    f.actions
  end
end
