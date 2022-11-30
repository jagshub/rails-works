# frozen_string_literal: true

# == Schema Information
#
# Table name: posts_launch_day_reports
#
#  id         :bigint(8)        not null, primary key
#  post_id    :bigint(8)        not null
#  s3_key     :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_posts_launch_day_reports_on_post_id  (post_id)
#
# Foreign Keys
#
#  fk_rails_...  (post_id => posts.id)
#
class Posts::LaunchDayReport < ApplicationRecord
  include Namespaceable

  belongs_to :post, inverse_of: :launch_day_reports
end
