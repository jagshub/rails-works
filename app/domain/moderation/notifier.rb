# frozen_string_literal: true

module Moderation
  module Notifier
    extend self
    extend Notifier::UrlHelper

    def for_maker(author:, maker:, message:, color: nil)
      fields = [
        {
          title: 'Post',
          value: link_to(maker.post),
        },
        {
          title: 'Maker',
          value: link_to(maker),
        },
      ]

      Attachment.new(author: author, reference: maker, message: message, fields: fields, color: color)
    end

    def for_user(author:, user:, message:, color: nil)
      fields = [
        {
          title: 'User',
          value: link_to(user),
        },
      ]

      Attachment.new(author: author, reference: user, message: message, fields: fields, color: color)
    end

    def for_post(author:, post:, message:, reason: nil, color: nil)
      fields = [
        {
          title: 'Post',
          value: link_to(post),
        },
        {
          title: 'Reason',
          value: reason.presence || 'N/A',
        },
      ]

      Attachment.new(author: author, reference: post, message: message, reason: reason, fields: fields, color: color)
    end

    def for_associated_product(author:, product:, associated_product:, message:, color: nil)
      fields = [
        {
          title: 'Product',
          value: link_to(product),
        },
        {
          title: 'Associated product',
          value: link_to(associated_product),
        },
      ]

      Attachment.new(author: author, reference: product, message: message, fields: fields, color: color)
    end
  end
end
