# frozen_string_literal: true

module LikeMatch
  extend self

  def by_words(query)
    "%#{ query.to_s.downcase.gsub(/\W+/, '%') }%"
  end

  def simple(input)
    "%#{ ActiveRecord::Base.sanitize_sql_like(input.to_s.downcase) }%"
  end

  def start_with(input)
    "#{ ActiveRecord::Base.sanitize_sql_like(input.to_s.downcase) }%"
  end

  def contains_word(input)
    "(?:^|\\s)#{ ActiveRecord::Base.sanitize_sql_like(input.to_s.downcase) }(?:\\s|$)"
  end
end
