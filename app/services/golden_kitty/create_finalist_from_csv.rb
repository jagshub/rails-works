# frozen_string_literal: true

require 'csv'

module GoldenKitty::CreateFinalistFromCsv
  extend self

  def call(file)
    CSV.parse(file.read, headers: false).each do |row|
      post = Post.find_by! slug: row[1]

      ::GoldenKitty::Finalist.find_or_create_by! golden_kitty_category_id: row[0], post: post
    end
  end
end
