# frozen_string_literal: true

module Graph::Mutations
  class BrowserExtensionSettingsUpdate < BaseMutation
    argument :background_image_mode, Boolean, required: false
    argument :beta_mode, Boolean, required: false
    argument :dark_mode, Boolean, required: false
    argument :home_view_variant, String, required: false
    argument :locality, String, required: false
    argument :show_goals_and_co_working, Boolean, required: false
    argument :show_random_product, Boolean, required: false

    returns Graph::Types::BrowserExtension::SettingsType

    def perform(inputs)
      setting = BrowserExtension::Setting.find_or_initialize_with(context)
      setting.update!(inputs)

      setting
    end
  end
end
