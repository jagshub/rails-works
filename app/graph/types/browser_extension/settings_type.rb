# frozen_string_literal: true

module Graph::Types
  class BrowserExtension::SettingsType < BaseObject
    graphql_name 'BrowserExtensionSettings'

    field :background_image_mode, Boolean, null: true
    field :beta_mode, Boolean, null: true
    field :dark_mode, Boolean, null: true
    field :home_view_variant, String, null: true
    field :locality, String, null: true
    field :show_goals_and_co_working, Boolean, null: true
    field :show_random_product, Boolean, null: true
  end
end
