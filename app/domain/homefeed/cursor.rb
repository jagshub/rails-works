# frozen_string_literal: true

# NOTE(rstankov): The feed cursor includes two pieces of information
#  1) the page the cursor is for (for many feeds, this is days ago from the current day)
#  2) how many posts have been shown across all previous page and this page (days).
class Homefeed::Cursor
  def self.after(cursor_as_string)
    page, posts_til_now = cursor_as_string.blank? ? [-1, 0] : cursor_as_string.split('-').map(&:to_i)

    new(page + 1, posts_til_now.to_i)
  end

  attr_reader :page, :previous_posts_count

  def initialize(page, previous_posts_count)
    @page = page
    @previous_posts_count = previous_posts_count
  end

  def to_s(new_post_count)
    "#{ page }-#{ previous_posts_count + new_post_count }"
  end
end
