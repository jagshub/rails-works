# frozen_string_literal: true

module Teams::Requests::Verification
  extend self

  TOKEN_EXPIRATION_TIME = 1.week

  class VerificationError < StandardError; end

  def send_email_verification(request:)
    set_verification_token(request)
    TeamMailer.request_sent(request).deliver_later

    request
  end

  def confirm_email(token:, user:)
    request = Team::Request.find_by(verification_token: token)

    raise VerificationError, :record_not_found if request.blank? || request.user != user
    raise VerificationError, :token_expired if verification_token_expired?(request)
    return request if request.team_email_confirmed?

    request.update!(team_email_confirmed: true)

    if auto_approve?(request: request)
      Teams.request_approve(request: request, approval_type: :auto)
    end

    request
  end

  def auto_approve?(request:)
    email_verified?(request: request) &&
      domain_matched?(request) &&
      first_claim?(request) &&
      !email_providers_domain?(request)
  end

  def email_verified?(request:)
    if request.team_email.strip == request.user.email
      request.team_email_confirmed? || !!request.user.email_confirmed?
    else
      request.team_email_confirmed?
    end
  end

  private

  def set_verification_token(request)
    return if request.team_email_confirmed?
    return if valid_token_present?(request)

    request.update!(
      verification_token: generate_verification_token(request),
      verification_token_generated_at: Time.current,
    )
  end

  def valid_token_present?(request)
    request.verification_token && request.verification_token_generated_at > TOKEN_EXPIRATION_TIME.ago
  end

  def generate_verification_token(request)
    HasUniqueCode.generate_code(
      request,
      field_name: :verification_token,
      length: 32,
    )
  end

  def verification_token_expired?(request)
    request.verification_token_generated_at < TOKEN_EXPIRATION_TIME.ago
  end

  def domain_matched?(request)
    email_domain(request) == request.product.website_domain
  end

  def email_domain(request)
    Mail::Address.new(request.team_email).domain
  end

  # Note(DT): We don't auto-approve requests from public email providers to prevent @gmail.com users from
  # claiming gmail.com product.
  def email_providers_domain?(request)
    EmailProviderDomain.exists?(value: email_domain(request))
  end

  def first_claim?(request)
    active_team_owners = request.product.team_members.owner.active
    active_team_owners.empty?
  end
end
