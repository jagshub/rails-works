# frozen_string_literal: true

ActiveAdmin.register GoldenKitty::Nominee do
  menu label: 'Nominee', parent: 'Golden Kitty'
  actions :index, :show

  config.per_page = 20
  config.paginate = true

  filter :golden_kitty_category
  filter :post_name, as: :string
  filter :post_slug, as: :string
  filter :user_id

  controller do
    def scoped_collection
      GoldenKitty::Nominee.includes(:golden_kitty_category, :post, :user)
    end
  end
end
