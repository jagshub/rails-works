# frozen_string_literal: true

class Graph::Resolvers::Team::InviteUsersSearchResolver < Graph::Resolvers::Base
  type [Graph::Types::UserType], null: false

  argument :query, String, required: false
  argument :product_id, ID, required: true
  argument :limit, Int, required: false
  argument :only_makers, Boolean, required: false

  EXCLUDE_DISMISSED_MAKERS_SQL = <<-SQL.squish
    NOT EXISTS(
      SELECT 1
      FROM dismissables
      WHERE dismissable_group = 'teamInviteMaker'
        AND dismissable_key::int = users.id
    )
  SQL

  def resolve(query: nil, product_id:, limit: 3, only_makers: false)
    return [] if current_user.blank?

    product = Product.find product_id

    return [] unless ApplicationPolicy.can?(current_user, :edit, product)

    scope =
      if only_makers
        User.where(id: product.maker_ids).where(EXCLUDE_DISMISSED_MAKERS_SQL)
      else
        User.visible.non_spammer
      end

    if query.present?
      scope = scope.find_query(query)
      scope = scope.order_by_friends(current_user)
    end

    scope
      .where(exclude_team_members(product))
      .where(exclude_invited_users(product))
      .limit(limit)
  end

  private

  def exclude_team_members(product)
    <<-SQL.squish
    NOT EXISTS(
      SELECT 1
      FROM team_members
      WHERE product_id = #{ product.id }
        AND users.id = team_members.user_id
    )
    SQL
  end

  def exclude_invited_users(product)
    <<-SQL.squish
    NOT EXISTS(
      SELECT 1
      FROM team_invites
      WHERE product_id = #{ product.id }
        AND users.id = team_invites.user_id
        AND code_expires_at > NOW()
    )
    SQL
  end
end
