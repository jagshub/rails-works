# frozen_string_literal: true

module Questions
  extend self

  class ImportCSV
    include MiniForm::Model

    SLUG_HEADER = 'Slug'
    POST_HEADER = 'PostSlug'
    TITLE_HEADER = 'Title'
    ANSWER_HEADER = 'Answer'
    HINT = 'Expected csv columns: Slug, PostSlug, Title, Answer separated by ;. Slug column is used to update the present questions, otherwise optional.'

    attributes :csv

    attr_reader :questions

    delegate :count, to: :questions, prefix: true

    def initialize
      @questions = []
    end

    def perform
      records = parse(csv)
      @questions = records.map { |record| import(record) }.compact
    end

    private

    def parse(file)
      CSV.new(file.read, headers: true, encoding: 'UTF-8', liberal_parsing: true, col_sep: ';').to_a.map do |row|
        {
          slug: row[SLUG_HEADER].to_s,
          title: row[TITLE_HEADER].to_s,
          answer: row[ANSWER_HEADER].to_s,
          post_slug: row[POST_HEADER].to_s,
        }
      end
    end

    def import(record)
      question = record[:slug].present? ? Question.find_by_slug!(record[:slug]) : Question.new
      return if question.blank?

      question.title = record[:title]
      question.answer = record[:answer]
      question.post = Post.find_by_slug!(record[:post_slug])

      question.save!

      question
    end
  end
end
