# frozen_string_literal: true

class Admin::Topics::ImportCSV
  include MiniForm::Model

  TOPIC_HEADER = 'Topic'
  ALIASES_HEADER = 'Alias(es)'
  DESCRIPTION_HEADER = 'Description'

  attributes :csv

  attr_reader :topics

  delegate :count, to: :topics, prefix: true

  def initialize
    @topics = []
  end

  def perform
    @topics = Import.call csv: csv
  end

  module Import
    extend self

    def call(csv:)
      records = parse file: csv
      records.map do |record|
        import record: record
      end
    end

    private

    def parse(file:)
      csv = CSV.new(file.read, headers: true, encoding: 'UTF-8')
      csv.to_a.map do |row|
        {
          name: row[TOPIC_HEADER].to_s,
          aliases: (row[ALIASES_HEADER].to_s.split(', ') + [row[TOPIC_HEADER].to_s]).compact,
          description: row[DESCRIPTION_HEADER],
        }
      end
    end

    def import(record:)
      topic = Topic.find_or_initialize_by name: record[:name]
      topic.description = record[:description] if record[:description].present?
      topic.save!

      record[:aliases].each do |name|
        apply_alias topic, name
      end

      topic
    end

    def apply_alias(topic, name)
      topic_alias = TopicAlias.find_or_initialize_by name: name.downcase
      topic_alias.topic = topic
      topic_alias.save!
    end
  end

  private_constant :Import
end
