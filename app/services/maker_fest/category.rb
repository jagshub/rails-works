# frozen_string_literal: true

class MakerFest::Category
  attr_reader :name, :emoji, :description, :participants, :category_slug

  def initialize(category_slug, participants, voted_ids)
    category = CATEGORIES[category_slug.to_sym]

    @category_slug = category_slug
    @name = category[:name]
    @emoji = category[:emoji]
    @description = category[:description]
    @participants = participants.map { |record| ParticipantPresenter.new(record, voted_ids) }
  end

  class ParticipantPresenter
    attr_reader :has_voted, :record
    delegate :upcoming_page, :external_link, :id, to: :record

    def initialize(record, voted_ids)
      @record = record
      @has_voted = voted_ids.include? @record.id
    end
  end

  CATEGORIES = {
    social: {
      name: 'Social Impact',
      emoji: '😇',
      description: 'Products that prioritize the improvement of the world',
    },
    voice: {
      name: 'Voice & Audio',
      emoji: '🗣',
      description: 'Products driven by vocals & sound',
    },
    health: {
      name: 'Health & Beauty',
      emoji: '💅',
      description: 'Products improving our minds & bodies',
    },
    inclusion: {
      name: 'Inclusion',
      emoji: '🌈',
      description: 'Products working to make everyone belong',
    },
    brain: {
      name: 'Brain Stuff',
      emoji: '🧠',
      description: 'Products to boost our productivity and minds',
    },
    remote: {
      name: 'Remote Workers',
      emoji: '🌍',
      description: 'Products for all digital nomads out there',
    },
    other: {
      name: 'Other',
      emoji: '👻',
      description: 'Products that fall outside our main categories',
    },
  }.freeze
end
