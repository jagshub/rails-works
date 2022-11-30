# frozen_string_literal: true

module Graph::Mutations
  class PostItemViewsTrack < BaseMutation
    argument :post_item_view_id, ID, required: false
    argument :post_ids, [ID], required: false
    argument :ab_test_variant, String, required: false
    argument :browser_width, Integer, required: false
    argument :browser_height, Integer, required: false

    class PostItemViewsType < Graph::Types::BaseNode
    end

    returns PostItemViewsType

    def perform(ab_test_variant: nil, post_ids: [], post_item_view_id: nil, browser_width: 0, browser_height: 0)
      log = PostItemViewsLog.find_by(id: post_item_view_id, visitor_id: context[:visitor_id]) if post_item_view_id
      log ||= PostItemViewsLog.new(visitor_id: context[:visitor_id])

      request_info = context[:request_info]

      log.update!(
        user_id: context[:current_user]&.id,

        seen_post_ids: post_ids,
        seen_posts_count: post_ids.size,

        ab_test_variant: ab_test_variant,

        browser_width: browser_width,
        browser_height: browser_height,

        browser: request_info.browser_name,
        device: request_info.device_type,
        platform: request_info.os,
        country: request_info.country,
        ip: request_info.request_ip,
        referer: request_info.referer,
      )
      log
    end
  end
end
