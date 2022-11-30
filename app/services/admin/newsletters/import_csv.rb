# frozen_string_literal: true

class Admin::Newsletters::ImportCSV
  include MiniForm::Model

  EMAIL_HEADER = 'Email'

  attributes :csv, :kind

  attr_reader :import_count, :errors_count, :subscribed_count, :subscribers

  def initialize
    @subscribers = []
    @import_count = 0
    @errors_count = 0
    @subscribed_count = 0
  end

  def perform
    file = CSV.new(csv.read, headers: true, encoding: 'UTF-8')
    @subscribers = file.to_a.map do |row|
      result = Import.call email: row[EMAIL_HEADER].to_s, kind: kind

      count_hash[result.first].call

      result.last
    end
  end

  private

  def count_hash
    {
      subscriber: -> { @import_count += 1 },
      subscribed: -> { @subscribed_count += 1 },
      error: -> { @errors_count += 1 },
    }
  end

  module Import
    extend self

    def call(email:, kind:)
      subscriber = Subscriber.find_or_initialize_by email: email

      return [:subscribed] unless subscriber.options['newsletter_subscription'] == Newsletter::Subscriptions::UNSUBSCRIBED

      if EmailValidator.valid?(email)
        subscriber.email_confirmed = true
        subscriber.options['newsletter_subscription'] = kind
        subscriber.save!

        [:subscriber, subscriber]
      else
        [:error]
      end
    end
  end

  private_constant :Import
end
