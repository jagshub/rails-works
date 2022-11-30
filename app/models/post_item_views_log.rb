# frozen_string_literal: true

# == Schema Information
#
# Table name: post_item_views_logs
#
#  id               :bigint(8)        not null, primary key
#  user_id          :integer
#  visitor_id       :string           not null
#  seen_post_ids    :integer          default([]), not null, is an Array
#  seen_posts_count :integer          default(0), not null
#  browser_width    :integer          default(0), not null
#  browser_height   :integer          default(0), not null
#  browser          :string
#  device           :string
#  platform         :string
#  country          :string
#  ip               :string
#  referer          :string
#  ab_test_variant  :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
class PostItemViewsLog < ApplicationRecord
end
