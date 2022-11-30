# frozen_string_literal: true

module Oembed::Endpoint
  extend ActiveSupport::Concern

  class_methods do
    def fetch(url:, maxwidth: nil, maxheight: nil)
      self::MATCHERS.each do |matcher, meth|
        match = matcher.match(url)
        next unless match

        return send(meth, match, maxwidth: maxwidth.to_i.nonzero?, maxheight: maxheight.to_i.nonzero?) if match
      end

      nil
    end

    def compute_max_size(minwidth, minheight, maxwidth, maxheight, ideal_ratio = 1)
      if maxwidth < maxheight || (maxwidth == maxheight && ideal_ratio > 1)
        height = [[(maxwidth / ideal_ratio).floor, minheight].max, maxheight].min
        width = [minwidth, maxwidth].max
      else
        height = [minheight, maxheight].max
        width = [[(maxheight * ideal_ratio).floor, minwidth].max, maxwidth].min
      end

      [width, height]
    end
  end
end
