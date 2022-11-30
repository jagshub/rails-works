# frozen_string_literal: true

module Graph::Types
  class HtmlContentType < BaseObject
    description 'HTML content properly escaped to be rendered in React'

    field :html, String, null: false

    def html
      BetterFormatter.call(object, mode: :full)
    end
  end
end
