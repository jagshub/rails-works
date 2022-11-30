# frozen_string_literal: true

module Graph::Types
  class MakerGroupType < BaseObject
    implements Graph::Types::SeoInterfaceType
    implements Graph::Types::DiscussableInterfaceType

    field :id, ID, null: false
    field :can_maintain, Boolean, null: false, resolver: Graph::Resolvers::Can.build(:maintain)
    field :description, String, null: false
    field :instructions, HTMLType, null: true
    field :is_accessible, Boolean, null: false, method: :accessible?
    field :is_main, Boolean, null: false, method: :main?
    field :is_private, Boolean, null: false, method: :private_access?
    field :is_public, Boolean, null: false, method: :public_access?
    field :members_count, Int, null: false
    field :name, String, null: false
    field :pending_members_count, Int, null: false
    field :tagline, String, null: false
    field :hp_sidebar_discussions, resolver: Graph::Resolvers::Discussion::HpSidebar

    field :discussions,
          Graph::Types::Discussion::ThreadType.connection_type,
          resolver: Graph::Resolvers::Discussion::SearchResolver, null: false
  end
end
