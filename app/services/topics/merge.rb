# frozen_string_literal: true

module Topics::Merge
  extend self

  def call(from:, to:)
    move_association from, to, :aliases
    move_association from, to, :subscriptions, foreign_key: :subscriber_id, own_key: :subject_id
    move_association from, to, :post_topic_associations, foreign_key: :post_id
    move_association from, to, :collection_topic_associations, foreign_key: :collection_id
    move_association from, to, :product_request_topic_associations, foreign_key: :product_request_id

    move_attributes from, to

    update_counter_caches to

    remove_topic from

    to
  end

  private

  def move_association(from, to, assoc, foreign_key: nil, own_key: 'topic_id')
    if foreign_key.present?
      table_name = from.public_send(assoc).table.name
      from.public_send(assoc).joins("INNER JOIN #{ table_name } b ON #{ table_name }.#{ foreign_key } = b.#{ foreign_key } AND b.#{ own_key } = #{ to.id }").delete_all
    end
    from.public_send(assoc).update_all own_key => to.id
  end

  def move_attributes(from, to)
    to.image_uuid = from.image_uuid unless to.image_uuid?
    to.description = from.description unless to.description?

    to.save! if to.changed?
  end

  def update_counter_caches(to)
    to.refresh_posts_count
    to.refresh_followers_count
    to.refresh_subscribers_count
  end

  def remove_topic(from)
    # NOTE(rstankov): `destroy!` isn't use, to make sure no relationships are removed with old topic
    Topic.where(id: from.id).delete_all
  end
end
