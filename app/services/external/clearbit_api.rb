# frozen_string_literal: true

module External::ClearbitAPI
  extend self

  def person_company(email, stream: false)
    response = Clearbit::Enrichment.find(email: email, stream: stream)

    return if response.nil?
    return if response.pending?

    response
  rescue Nestful::ResourceInvalid, Nestful::TimeoutError, Nestful::ErrnoError
    nil
  end

  def company(domain, stream: false)
    response = Clearbit::Enrichment::Company.find(
      domain: domain,
      stream: stream,
    )

    return if response.nil?
    return if response.pending?

    response
  rescue Nestful::ResourceInvalid, Nestful::TimeoutError, Nestful::ErrnoError
    nil
  end
end
