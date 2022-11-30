# frozen_string_literal: true

class API::Widgets::Internal::InternalController < ActionController::Base
  respond_to :json

  def sidekiq
    queues = Sidekiq::Queue.all

    running = Hash.new(0)

    workers = Sidekiq::Workers.new
    workers.each do |_process_id, _thread_id, work|
      running[work['queue']] += 1
    end

    render json: {
      queues: queues.map do |queue|
        {
          name: queue.name,
          size: queue.size + running[queue.name],
          latency: queue.latency,
        }
      end,
    }
  end
end
