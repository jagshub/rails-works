# frozen_string_literal: true

module Posts::SvgCharts
  extend self

  def post_comments(post:, frame: nil)
    sql = <<-SQL
      SELECT count(*) AS the_count, FLOOR((extract(hour from cast(created_at at time zone 'utc' at time zone 'america/los_angeles' as timestamp)) * 60 + extract(minute from comments.created_at)) / :frame) AS position
      FROM comments
      WHERE comments.subject_type = 'Post'
      AND comments.subject_id = :post_id
      AND hidden_at IS NULL
      AND trashed_at IS NULL
      AND created_at >= :start_date
      AND created_at <= :end_date
      GROUP BY 2
      ORDER BY 2 asc
    SQL

    render_chart post: post, frame: frame, sql: sql
  end

  def post_votes(post:, frame: nil)
    sql = <<-SQL
      SELECT count(*) AS the_count, FLOOR((extract(hour from cast(created_at at time zone 'utc' at time zone 'america/los_angeles' as timestamp)) * 60 + extract(minute from votes.created_at)) / :frame) AS position
      FROM votes
      WHERE votes.subject_type = 'Post'
      AND votes.subject_id = :post_id
      AND credible
      AND created_at >= :start_date
      AND created_at <= :end_date
      GROUP BY 2
      ORDER BY 2 asc
    SQL

    render_chart post: post, frame: frame, sql: sql
  end

  private

  WIDTH = 80
  HEIGHT = 24
  POINTS_COUNT = 24
  RATIO_X = (WIDTH + 4).to_f / POINTS_COUNT

  def render_chart(post:, sql:, frame: nil)
    return render_empty_chart unless post.featured?

    # NOTE(rstankov): During testing we want to configure the hour
    #   After this it is the post date hour
    frame = [[1, (frame || ((Time.current - post.date) / 1.hour).to_i).to_i].max, 24].min

    where = {
      post_id: post.id,
      start_date: post.date,
      end_date: post.date.end_of_day,
      frame: (frame * 60) / POINTS_COUNT,
    }

    result = ExecSql.call(sql, where).to_a

    return render_empty_chart if result.empty?

    # NOTE(rstankov): Have a Hash[position] = count
    #   then fill in the blanks
    #   and sum counts so far
    positions = result.inject({}) do |acc, row|
      acc[row['position'].to_i] = row['the_count']
      acc
    end

    data = 0.upto(POINTS_COUNT - 1).inject([]) do |acc, position|
      acc << (acc.last || 0) + positions[position].to_i
    end

    # NOTE(rstankov): Depending on highest point we know how to position the rest
    ratio_y = (HEIGHT - 3).to_f / data.last # NOTE(rstankov): max value is last

    points_path = data.each_with_index.map { |v, i| "#{ i * RATIO_X },#{ HEIGHT - v * ratio_y }" }.join(' ')

    # NOTE(rstankov): I'm using two paths
    #  1. Is Closed (notice the Z in `d` prop) and has the gradient as background
    #  2. Has a stroke and shows the chart
    <<-SVG
      <svg
        version="1.1"
        xmlns="http://www.w3.org/2000/svg"
        width="#{ WIDTH }"
        height="#{ HEIGHT }"
        viewBox="0 0 #{ WIDTH } #{ HEIGHT }">
        <defs>
          <linearGradient x1=".5" x2=".5" y2="1" id="gradient">
            <stop offset="0" stop-color="#F64900"/>
            <stop offset="1" stop-color="#f64900" stop-opacity="0"/>
          </linearGradient>
        </defs>
        <path
          fill="url(#gradient)"
          fill-opacity="0.56"
          stroke="none"
          d="M 0,#{ HEIGHT + 2 } #{ points_path } #{ WIDTH + 2 },#{ HEIGHT + 2 } Z"
        />
        <path
          fill="none"
          stroke="#F64900"
          stroke-width="1"
          stroke-linejoin="round"
          stroke-linecap="round"
          d="M #{ points_path }.join(' ') }"
        />
      </svg>
    SVG
  end

  def render_empty_chart
    <<-SVG
      <svg
        version="1.1"
        xmlns="http://www.w3.org/2000/svg"
        width="#{ WIDTH }"
        height="#{ HEIGHT }"
        viewBox="0 0 #{ WIDTH } #{ HEIGHT }">
      </svg>
    SVG
  end
end
