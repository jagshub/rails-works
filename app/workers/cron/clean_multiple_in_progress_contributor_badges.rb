# frozen_string_literal: true

module Cron
  class CleanMultipleInProgressContributorBadges < ApplicationJob
    def perform
      # Get user badges who have multiple in progress badges of same type
      identifier = 'contributor'
      query = "SELECT * FROM
        (SELECT COUNT(*) as badges_count, subject_id, ARRAY_AGG(data->>'tracked_comment_ids') as aggr_tracked_comment_ids,
            ARRAY_AGG(ID) as badge_ids FROM badges
        WHERE subject_type='User' and data->>'identifier' = '#{ identifier }' and data->>'status' = 'in_progress'
        group by subject_id) as user_multiple_badges WHERE badges_count>1"
      records_array = ActiveRecord::Base.connection.execute(query)

      return if records_array.blank?

      records_array.map do |row|
        user = User.find_by id: row['subject_id']

        all_comment_ids = []
        aggr_tracked_comment_ids = row['aggr_tracked_comment_ids']

        if aggr_tracked_comment_ids.instance_of? String
          aggr_tracked_comment_ids = aggr_tracked_comment_ids.delete('{').delete('}').delete('[').delete(']').delete('"')
                                                             .split(',').map(&:to_i)
        end

        aggr_tracked_comment_ids.map do |tracked_comment_ids|
          all_comment_ids.push(tracked_comment_ids)
        end

        all_comment_ids = all_comment_ids.uniq

        ## Create new records
        (all_comment_ids.length / 5).times do |i|
          Badges::UserAwardBadge.create!(
            subject: user,
            data: {
              identifier: identifier,
              status: :awarded_to_user_and_visible,
              tracked_comment_ids: all_comment_ids[i * 5, 5],
            },
          )
        end

        left_out_comment_ids_start_index = all_comment_ids.length - (all_comment_ids.length % 5)
        left_out_comment_ids_count = all_comment_ids.length % 5

        if left_out_comment_ids_count > 0
          Badges::UserAwardBadge.create!(
            subject: user,
            data: {
              identifier: identifier,
              status: :in_progress,
              tracked_comment_ids: all_comment_ids[left_out_comment_ids_start_index, left_out_comment_ids_count],
            },
          )
        end

        ## Delete all previous records
        Badges::UserAwardBadge.where(id: row['badge_ids'].delete('{').delete('}').split(',').map(&:to_i)).destroy_all
        ## Refresh badge count
        user&.refresh_badges_count
      end
    end
  end
end
