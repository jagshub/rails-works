# frozen_string_literal: true

module SpamChecks::Admin::Dashboard
  extend self

  def vote_spike_chart
    data = ExecSql.call(today_post_votes_query)

    grouped_data = data.group_by { |record| record['post_slug'] }

    grouped_data.map do |slug, votes|
      {
        name: slug,
        data: votes.map { |vote| [vote['vote_time'], vote['total_votes_count']&.to_i] }.to_h,
      }
    end.unshift(empty_series(data, 'vote_time'))
  end

  def spam_caught_chart
    data =
      Spam::ActionLog
      .select("cast(created_at at time zone 'utc' at time zone 'america/los_angeles' as date) as day, subject_type, count(id) as count")
      .where(spam: true, false_positive: false)
      .group('day, subject_type')
      .order('day asc')

    grouped_data = data.group_by(&:subject_type)

    grouped_data.map do |subject, logs|
      {
        name: subject,
        data: logs.map { |log| [log.day, log.count] }.to_h,
      }
    end.unshift(empty_series(data, 'day'))
  end

  def manual_actions_chart
    data =
      Spam::ManualLog
      .select("action, cast(created_at at time zone 'utc' at time zone 'america/los_angeles' as date) as day, count(id) as count")
      .where(reverted_by: nil)
      .group('action, day')
      .order('day asc')

    grouped_data = data.group_by(&:action)

    grouped_data.map do |action, logs|
      {
        name: action,
        data: logs.map { |log| [log.day, log.count] }.to_h,
      }
    end.unshift(empty_series(data, 'day'))
  end

  def auto_vs_manual_actions_chart
    manual_data =
      Spam::ManualLog
      .where(reverted_by: nil)
      .group("to_char((created_at at time zone 'utc' at time zone 'america/los_angeles') , 'YYYY-MM')")
      .order('2 asc')
      .count
    auto_data =
      Spam::ActionLog
      .where(spam: true, false_positive: false)
      .group("to_char((created_at at time zone 'utc' at time zone 'america/los_angeles') , 'YYYY-MM')")
      .order('2 asc')
      .count

    months = (manual_data.keys + auto_data.keys).uniq.sort

    [
      {
        name: 'none',
        data: months.map { |month| [month, 0] }.to_h,
      },
      {
        name: 'manual',
        data: manual_data,
      },
      {
        name: 'auto',
        data: auto_data,
      },
    ]
  end

  private

  def today_post_votes_query
    sub_query =
      Vote
      .select(
        'count(votes.id) as votes_count, '\
        "to_char((votes.created_at at time zone 'utc' at time zone 'america/los_angeles'), 'HH24:MI') as vote_time, "\
        'today_posts.slug as post_slug',
      )
      .joins(
        'INNER JOIN (' +
        Post.featured.today.to_sql +
        ') today_posts on today_posts.id = votes.subject_id',
      )
      .where(subject_type: 'Post')
      .where_date_eq(:created_at, Time.zone.today)
      .group('vote_time, post_slug')
      .order('vote_time asc')
      .to_sql

    <<-SQL
      WITH data as (
        #{ sub_query }
      )

      SELECT post_slug,
             vote_time,
             sum(votes_count) OVER (PARTITION BY post_slug
                                    ORDER BY vote_time) AS total_votes_count
      FROM data
      order by vote_time asc
    SQL
  end

  def empty_series(records, column)
    data = records.map do |record|
      [record[column], 0]
    end.to_h

    {
      name: 'none',
      data: data,
      visible: false,
    }
  end
end
