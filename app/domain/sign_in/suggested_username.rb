# frozen_string_literal: true

module SignIn::SuggestedUsername
  extend self

  def call(name)
    name = ActiveSupport::Inflector.transliterate(name || '')
    name.gsub(/[^A-z0-9_]+/, '_').downcase
  end
end
