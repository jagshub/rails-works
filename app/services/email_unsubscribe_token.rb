# frozen_string_literal: true

class EmailUnsubscribeToken
  # Narrow interface to exposed class methods
  private_class_method :new

  attr_reader :identifier, :valid_until

  class << self
    def encode_for(user: nil, email: nil)
      if user
        new(user.id).to_params
      else
        new(email).to_params(:email)
      end
    end

    def valid?(identifier:, valid_until:, token:)
      new(identifier, valid_until).valid?(token)
    end

    def get_permanent_token(user: nil, email: nil)
      if user
        new(user.id).permanent_token_params
      elsif email
        new(email).permanent_token_params(:email)
      else
        raise 'Invalid input, both user and email are nil'
      end
    end

    def permanent_token_valid?(identifier:, token:)
      new(identifier).valid_permanent_token?(token)
    end
  end

  def initialize(identifier, valid_until = nil)
    @identifier = identifier
    # Note (Mike Coutermarsh): CAN SPAM minimum is 30 days.
    #   http://security.stackexchange.com/questions/115964/email-unsubscribe-handling-security
    @valid_until = valid_until.presence || 30.days.from_now.to_i
  end

  def to_params(identifier_name = :user_id)
    { identifier_name.to_sym => identifier, valid_until: valid_until, token: token }
  end

  def permanent_token_params(identifier_name = :user_id)
    { identifier_name.to_sym => identifier, token: permanent_token }
  end

  def valid?(reference_token)
    return false unless @identifier.present? &&
                        reference_token.present?

    valid_hash?(reference_token) && not_too_old?
  end

  def valid_permanent_token?(reference_token)
    return false unless @identifier.present? &&
                        reference_token.present?

    permanent_token == reference_token
  end

  private

  def token
    @token ||= Digest::SHA1.hexdigest "#{ identifier }:#{ valid_until }:#{ salt }"
  end

  def permanent_token
    @token ||= Digest::SHA1.hexdigest "#{ identifier }:#{ salt }"
  end

  def valid_hash?(reference_token)
    token == reference_token
  end

  def not_too_old?
    valid_until.to_i > Time.current.to_i
  end

  def salt
    'this is a very secret text… you shouldn\'t even be reading it… but whatever… ❤ you… ✌'
  end
end
