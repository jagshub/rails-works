# frozen_string_literal: true

module Mobile::Graph::Types
  class FormattedTextType < BaseObject
    graphql_name 'ConvertableText'

    field :html, HTMLType, null: false
    field :text, String, null: false
    field :markdown, String, null: false do
      argument :images, Boolean, required: false
    end

    def text
      ActionController::Base.helpers.strip_tags(object)
    end

    def markdown(images: false)
      html_doc = Nokogiri::HTML(html)
      html_doc.search('img').remove unless images
      ::ReverseMarkdown.convert(html_doc)
    end

    def html
      BetterFormatter.call(object, mode: :full).gsub('?makers', '<a>?makers</a>').gsub("\n", '<br />')
    end
  end
end
