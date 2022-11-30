# frozen_string_literal: true

module Graph::Resolvers
  class Team::MembersResolver < Base
    type [Graph::Types::Team::MemberType], null: false

    argument :first, Integer, required: false

    def resolve(first: nil)
      return [] unless can_edit?

      object.team_members.limit(first).order(Arel.sql(<<~SQL.squish))
        CASE WHEN team_members.status = 'active' THEN 1 ELSE 0 END DESC,
        CASE WHEN team_members.role = 'owner' THEN 1 ELSE 0 END DESC,
        CASE WHEN team_members.user_id = #{ current_user.id } THEN 1 ELSE 0 END DESC
      SQL
    end

    private

    def can_edit?
      ApplicationPolicy.can?(current_user, :edit, object)
    end
  end
end
