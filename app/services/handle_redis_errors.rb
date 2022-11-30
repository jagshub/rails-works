# frozen_string_literal: true

module HandleRedisErrors
  extend self

  def call(fallback: nil)
    yield
  rescue Redis::CannotConnectError, Errno::ECONNREFUSED, IO::EINPROGRESSWaitWritable, SocketError, Redis::TimeoutError, IO::EAGAINWaitReadable, Redis::BaseConnectionError, Redis::CannotConnectError => e
    if fallback.respond_to?(:call)
      fallback.call(e)
    else
      fallback
    end
  end
end
