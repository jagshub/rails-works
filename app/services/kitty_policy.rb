# frozen_string_literal: true

module KittyPolicy
  def can?(user, ability, subject = :empty)
    if subject == :empty
      public_send Utils.rule_name(ability), user
    else
      public_send Utils.rule_name(ability, subject), user, subject
    end
  end

  def authorize!(*args)
    raise AccessDenied.new(*args) unless can?(*args)
  end

  private

  def can(abilities, subject = nil, allow_guest: false, &block)
    Array(abilities).each do |ability|
      define_method Utils.rule_name(ability, subject) do |*args|
        (args[0] || allow_guest) && !!block.call(*args)
      end
    end
  end

  class AccessDenied < StandardError
    attr_reader :user, :ability, :subject

    def self.with_message(message)
      new(nil, nil, nil, message)
    end

    def initialize(user = nil, ability = nil, subject = nil, message = nil)
      @user = user
      @ability = ability
      @subject = subject

      super(message || 'Not authorized')
    end
  end

  module Utils
    extend self

    def rule_name(ability, subject = nil)
      name = "can_#{ ability }"
      name += "_#{ subject_to_string(subject).underscore.tr('/', '_') }" if subject
      name + '?'
    end

    private

    def subject_to_string(subject)
      case subject
      when Class, Symbol then subject.to_s
      when String then subject.gsub(/[^\w]/, '')
      else subject.class.to_s
      end
    end
  end
end
