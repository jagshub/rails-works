# frozen_string_literal: true

module Stream::Errors
  module Events
    class InvalidSubject < StandardError; end
    class InvalidFanOutWorker < StandardError; end
  end

  module Activities
    class InvalidCreateBehaviour < StandardError; end
    class TargetNotSupported < StandardError; end
  end
end
