# frozen_string_literal: true

class Mobile::Graph::Resolvers::Comments::BodyMD < Mobile::Graph::Resolvers::BaseResolver
  type String, null: false

  def resolve
    ::ReverseMarkdown.convert(body_html)
  end

  private

  def body_html
    BetterFormatter.call(object.body, mode: :full).gsub('?makers', '<a>?makers</a>').gsub("\n", '<br />')
  end
end
