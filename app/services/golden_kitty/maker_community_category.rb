# frozen_string_literal: true

module GoldenKitty::MakerCommunityCategory
  extend self

  MAKER_IDS = [
    '497', '3400', '977167', '56547', '633005', '13376', '345896', '2287', '44264', '44183', '145112',
    '195055', '72708', '3248', '862360', '787049', '1038278', '395249', '137324', '1051563', '307782',
    '17624', '309719', '1009776', '37865', '1161287', '788844', '17811'
  ].freeze

  COMMUNITY_IDS = [
    '23', '58', '851', '962', '1257', '1880', '8660', '10748', '18280', '90578', '103184', '165894',
    '195179', '232526', '335623', '419752', '443764', '447391', '598904', '688925', '871225', '878559',
    '1015594', '1032077', '739814', '1242204', '309801'
  ].freeze

  MAKER = {
    name: 'Maker of the Year',
    tagline: 'Product Hunt is nothing without the community. Here are few of the folks that made 2018 awesome.',
    emoji: '💻',
    finalists: MAKER_IDS,
  }.freeze

  COMMUNITY = {
    name: 'Community Member of the Year',
    tagline: 'Product Hunt is nothing without the community. Here are few of the folks that made 2018 awesome.',
    emoji: '🤗',
    finalists: COMMUNITY_IDS,
  }.freeze

  def call(category)
    Category.new category == 'maker' ? MAKER : COMMUNITY
  end

  class Category
    attr_reader :name, :emoji, :tagline, :finalists

    def initialize(data)
      @name = data[:name]
      @tagline = data[:tagline]
      @emoji = data[:emoji]
      @finalists = User.where(id: data[:finalists])
    end
  end
end
