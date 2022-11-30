# frozen_string_literal: true

class Maker::Story
  attr_reader :external_url, :title

  def self.all
    STORIES
  end

  def initialize(external_url, title, username)
    @external_url = external_url
    @title = title
    @username = username
  end

  def user
    @user ||= User.find_by_username(@username)
  end

  STORIES = [
    new(
      'https://medium.com/ad-astra/3-unexpected-benefits-from-sharing-my-goals-with-other-makers-643105df809d',
      '3 Unexpected Benefits From Sharing My Goals With Other Makers',
      'gil_akos',
    ),
    new(
      'https://blog.usejournal.com/how-product-hunt-is-making-tech-feel-more-inclusive-1b4a56d3d446',
      'How Product Hunt is making tech feel more inclusive',
      'temilasade',
    ),
    new(
      'https://medium.com/@londonc/how-product-hunt-makers-has-increased-my-productivity-60b46e769db5',
      'How Product Hunt Makers has increased my productivity',
      'londonc',
    ),
    new(
      'https://medium.com/@anna.pozniak/why-i-decided-to-share-my-goals-with-makers-community-4d3978b0c7e8',
      'Why I decided to share my goals with Makers community',
      'anya_pozniak',
    ),
  ].freeze
end
