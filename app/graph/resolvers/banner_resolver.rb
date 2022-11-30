# frozen_string_literal: true

module Graph::Resolvers
  class BannerResolver < Graph::Resolvers::Base
    type Graph::Types::BannerType, null: true

    class BannerPosition < Graph::Types::BaseEnum
      graphql_name 'BannerPosition'

      value 'MAINFEED'
      value 'SIDEBAR'
    end

    argument :position, BannerPosition, required: true

    def resolve(position:)
      if current_user&.admin?
        banner = ::Banner.where('status = ? AND position = ?', 'testing', position.downcase).first

        return banner if banner
      end

      ::Banner.where('status = ? AND position = ? AND ? BETWEEN DATE(start_date) AND DATE(end_date)', 'active', position.downcase, Time.zone.today).first
    end
  end
end
