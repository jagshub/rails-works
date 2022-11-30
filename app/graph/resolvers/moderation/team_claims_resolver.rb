# frozen_string_literal: true

class Graph::Resolvers::Moderation::TeamClaimsResolver < Graph::Resolvers::Base
  type Graph::Types::Team::RequestType.connection_type, null: false

  def resolve
    # Note(DT): An instance for Graph::Utils::PaginatedCollectionConnection
    TeamClaimsFetcher.new
  end

  class TeamClaimsFetcher
    def fetch(limit: nil, offset: 0)
      Team::Request
        .joins(:product)
        .merge(Team::Request.pending)
        .where(team_requests: { team_email_confirmed: true })
        .where.not(products: { id: claimed_products })
        .limit(limit)
        .offset(offset)
        .select(<<~SQL.squish)
          DISTINCT ON (products.id) team_requests.*
        SQL
    end

    def total_count
      Product
        .joins(:team_requests)
        .merge(Team::Request.pending)
        .where(team_requests: { team_email_confirmed: true })
        .joins(<<~SQL.squish)
          LEFT JOIN team_members
          ON team_members.product_id = products.id
          AND team_members.status = 'active'
          AND team_members.role = 'owner'
        SQL
        .where(team_members: { id: nil })
        .distinct
        .count
    end

    private

    def claimed_products
      Product
        .joins(:team_members)
        .merge(Team::Member.active)
        .merge(Team::Member.owner)
    end
  end
end
