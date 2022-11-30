# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::MessageRecipientsResolver < Graph::Resolvers::Base
  type Graph::Types::UserType.connection_type, null: false

  def resolve
    return [] unless object.publicly_accessible?

    User.where(id: object.to.joins(:contact).where.not('ship_contacts.user_id' => nil).pluck('ship_contacts.user_id'))
  end
end
