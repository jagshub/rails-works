# frozen_string_literal: true

module Graph::Resolvers
  class UpcomingPages::HasSubscribedResolver < Graph::Resolvers::Base
    type Boolean, null: false

    def resolve
      return false if current_user.blank?

      SubscriptionsLoader.for(current_user).load(object)
    end

    class SubscriptionsLoader < GraphQL::Batch::Loader
      def initialize(user)
        @user = user
      end

      def perform(pages)
        subscriptions = @user.upcoming_page_subscriptions.confirmed.where(upcoming_page_id: pages.map(&:id)).pluck(:upcoming_page_id)

        pages.each do |page|
          fulfill page, subscriptions.include?(page.id)
        end
      end
    end
  end
end
