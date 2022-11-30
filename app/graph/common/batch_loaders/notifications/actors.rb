# frozen_string_literal: true

module Graph::Common::BatchLoaders
  class Notifications::Actors < GraphQL::Batch::Loader
    def perform(notification_items)
      actor_ids = notification_items.pluck(:actor_ids).flatten.uniq
      actors_grouped = User.where(id: actor_ids).group_by(&:id)

      notification_items.each do |notification|
        actors = notification.actor_ids.map do |actor_id|
          actors_grouped[actor_id]&.first
        end.compact

        fulfill notification, actors
      end
    end
  end
end
