# frozen_string_literal: true

module Stream
  class Activities::ProductPostLaunch < Activities::Base
    verb 'product-post-launch'
    batch_if_occurred_within 8.hours
    create_when :new_target

    target &:subject
    actors { |_event, target| target.makers.visible.non_spammer }
    connecting_text { |_receiver_id, _post, _target| 'launched' }
    last_occurrence_at { |_object, target| target.featured_at }

    notify_user_ids do |_event, target, actor|
      return [] unless target.featured?

      product = target.new_product
      return [] if product.blank?
      return [] unless product.visible?

      exclude_ids = actor.followers.visible.non_spammer.select(:id)

      product
        .followers
        .where.not(id: exclude_ids)
        .visible
        .non_spammer
        .pluck(:id)
    end
  end
end
