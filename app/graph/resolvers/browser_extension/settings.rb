# frozen_string_literal: true

class Graph::Resolvers::BrowserExtension::Settings < Graph::Resolvers::Base
  type Graph::Types::BrowserExtension::SettingsType, null: true

  def resolve
    ::BrowserExtension::Setting.find_or_initialize_with(context)
  end
end
