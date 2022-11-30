# frozen_string_literal: true

# This runs Camo on any <img> tags. Converting http img's to https
module BetterFormatter::MediaCamoTransformer
  def self.call(env)
    # Ignore everything except <img> elements.
    return unless env[:node_name] == 'img'

    node = env[:node]
    node['src'] = External::CamoApi.url(node['src'])

    node
  end
end
