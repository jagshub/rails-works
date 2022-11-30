# frozen_string_literal: true

module Stream
  class Activities::Base < ApplicationJob
    include ActiveJobHandleDeserializationError

    def perform(event)
      create_behaviour = self.class.create_behaviour
      self.class.validate_create_behaviour(create_behaviour)

      create_or_update_feed_items(event, create_behaviour)
    end

    def fetch_object(event)
      # NOTE(Dhruv) Default to event's subject as the action object.
      # e.g If event is VoteCreated then action object is the Vote record
      event.subject
    end

    def fetch_actors(event, _target)
      # NOTE(Dhruv): Default to event.user as the actor. In some cases actor
      # might differ from event's user.
      # e.g User X launches a post which is unfeatured, and later featured by
      # a moderator Y. The activity should still read "User X launched Post"
      [event.user] if event.user.present?
    end

    def fetch_last_occurrence_at(object, _target)
      # NOTE(Dhruv): Default to object creation data.
      # e.g If event is VoteCreated last occurrence is when vote record was
      # created
      object.created_at
    end

    def fetch_target(_event)
      raise NotImplementedError
    end

    def fetch_notify_user_ids(_event, _target, _actor)
      raise NotImplementedError
    end

    def fetch_connecting_text(_receiver_id, _object, _target)
      raise NotImplementedError
    end

    # NOTE(DZ): Solo events do not use a receiver. Instead uses actor as the only
    # receiver. This is useful for events triggered by system actions like badge
    # awarded, etc.
    def solo_event?
      false
    end

    private

    def create_or_update_feed_items(event, create_behaviour)
      object = fetch_object(event)
      return if object.blank?

      target = fetch_target(event)
      return if target.blank?

      last_occurrence_at = fetch_last_occurrence_at(object, target)
      return if last_occurrence_at.blank?

      actors = fetch_actors(event, target)
      return if actors.blank?

      actor_ids = actors.map(&:id)
      actors.each { |actor| create_items_for_actor(actor, event, create_behaviour, object, target, last_occurrence_at, actor_ids) }
    end

    def create_items_for_actor(actor, event, create_behaviour, object, target, last_occurrence_at, all_actor_ids)
      common_attrs = {
        actor: actor,
        verb: self.class.verb_name,
        object: object,
        target: target,
        last_occurrence_at: last_occurrence_at,
      }

      receiver_ids_for_actor = (fetch_notify_user_ids(event, target, actor) || []).compact
      receiver_ids_without_actors = receiver_ids_for_actor - all_actor_ids

      # NOTE(DZ): I'm not certain why there is a limitation on requiring a receiver
      # per notification. In this case bypass with `solo_event?` method.
      return if receiver_ids_without_actors.empty? && !solo_event?

      receiver_ids_without_actors = [actor.id] if solo_event?

      item_ids = receiver_ids_without_actors.uniq.map { |receiver_id| create_item_for_receiver(create_behaviour, receiver_id, common_attrs) }.map(&:id)
      Stream::Workers::FeedItemsSyncData.perform_later(item_ids: item_ids, feed_items_are_similar: true)
    end

    def create_item_for_receiver(create_behaviour, receiver_id, attrs)
      object = attrs[:object]
      object_identifier = "#{ object.class.name }_#{ object.id }"
      target = attrs[:target]

      scope = Stream::FeedItem.where(
        receiver_id: receiver_id,
        target: target,
        verb: attrs[:verb],
      )

      batch_duration = self.class.batch_duration
      if batch_duration.present?
        occured_after_time = object.created_at - batch_duration
        scope = scope.where(Stream::FeedItem.arel_table[:last_occurrence_at].gteq(occured_after_time))
      end

      if create_behaviour == :new_object
        # NOTE(Dhruv) e.g when user comments on a Post, always create a new feed item
        # instead of batching, though always check if feed item with same comment
        # exists or not, the comment record being object in this case.
        scope = scope.where("action_objects @> '{#{ object_identifier }}'")
      end

      item = scope.order(last_occurrence_at: :desc).first_or_initialize
      item.actor_ids.unshift(attrs[:actor].id).uniq!
      item.action_objects.unshift(object_identifier).uniq!
      item.last_occurrence_at = attrs[:last_occurrence_at]
      item.connecting_text = fetch_connecting_text(receiver_id, object, target)
      item.seen_at = nil

      item.save!
      item
    end

    class << self
      attr_reader :verb_name, :create_behaviour, :batch_duration

      def verb(name)
        @verb_name = name
      end

      def create_when(create_behaviour)
        validate_create_behaviour(create_behaviour)
        @create_behaviour = create_behaviour
      end

      def batch_if_occurred_within(batch_duration)
        @batch_duration = batch_duration
      end

      def object(&block)
        define_method(:fetch_object, &block)
      end

      def target(&block)
        define_method(:fetch_target, &block)
      end

      def actors(&block)
        define_method(:fetch_actors, &block)
      end

      def last_occurrence_at(&block)
        define_method(:fetch_last_occurrence_at, &block)
      end

      def notify_user_ids(&block)
        define_method(:fetch_notify_user_ids, &block)
      end

      def connecting_text(&block)
        define_method(:fetch_connecting_text, &block)
      end

      def solo_event?(&block)
        define_method(:solo_event?, &block)
      end

      def validate_create_behaviour(behaviour)
        raise ::Stream::Errors::Activities::InvalidCreateBehaviour unless %i(new_object new_target).include? behaviour
      end
    end
  end
end
