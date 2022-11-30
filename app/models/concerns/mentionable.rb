# frozen_string_literal: true

module Mentionable
  extend ActiveSupport::Concern

  included do
    has_many :mentions, as: :subject, dependent: :delete_all, inverse_of: :subject
    has_many :mentioned_users, class_name: 'User', through: :mentions, source: :user
    after_save :persist_mentioned_users
  end

  private

  def text_with_mentions
    :body
  end

  def persist_mentioned_users
    text = public_send(text_with_mentions)

    mentioned_user_ids = Notifications::Helpers::GetMentionedUserIds.for_text(text)

    Mention.transaction do
      before_ids = Mention.where(subject: self).pluck :id

      records = mentioned_user_ids.map do |user_id|
        Mention.find_or_create_by(user_id: user_id, subject: self)
      end

      to_remove = before_ids - records.map(&:id).compact

      Mention.where(subject: self, id: to_remove).delete_all if to_remove.any?
    end
  end

  module ClassMethods
    def mentionable(column:)
      define_method(:text_with_mentions) do
        column
      end
    end
  end
end
