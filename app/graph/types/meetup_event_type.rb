# frozen_string_literal: true

module Graph::Types
  class MeetupEventType < BaseNode
    field :name, String, null: false
    field :description, String, null: false
    field :host, Graph::Types::UserType, null: false
    field :thumbnail_uuid, String, null: false
    field :date, Graph::Types::DateTimeType, null: false
    field :online, Boolean, null: false
    field :city, String, null: true
    field :country, String, null: true
    field :link, String, null: false
    field :approved, Boolean, null: false
    field :upcoming, Boolean, null: false
    field :previous, Boolean, null: false
    field :can_edit, resolver: Graph::Resolvers::Can.build(:edit)
    field :official, Boolean, null: false
    field :summary, String, null: true
    field :media, [Graph::Types::MediaType], null: false

    def approved
      object.approved?
    end

    def upcoming
      object.upcoming?
    end

    def previous
      object.previous?
    end
  end
end
