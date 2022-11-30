# frozen_string_literal: true

# NOTE(rstankov): We use custom connection (instead build-in one) to present `Homefeed::Page`
#   `Homefeed::Page` is loaded one at a time, and the `Homefeed` domain handles all the logic that goes into a page.
#   It behaves similar to generic connections (instead of its support for before/first/last)
module Graph::Types
  # NOTE(rstankov): This can't be named `HomefeedEdgeType` or `HomefeedCustomEdgeType`
  #   Its base class implementation is to complex for this usecase
  class HomefeedEdgeCustomType < BaseObject
    field :cursor, String, null: false
    field :node, HomefeedPageType, null: false

    def node
      object
    end
  end

  # NOTE(rstankov): This can't be named `HomefeedConnectionType` or `HomefeedCustomConnectionType`
  #   Because GraphQL gem will complain that we don't use its base class
  #   Its base class implementation is to complex for this usecase
  class HomefeedConnectionCustomType < BaseObject
    field :kind, HomefeedKindEnum, null: false
    field :edges, [HomefeedEdgeCustomType], null: false
    field :page_info, GraphQL::Types::Relay::PageInfo, null: false

    def edges
      [object]
    end

    def page_info
      {
        has_next_page: object.next_page?,
        start_cursor: object.cursor,
        end_cursor: object.cursor,
        has_previous_page: object.previous_page?,
      }
    end
  end
end
