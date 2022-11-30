# frozen_string_literal: true

module Users::LinkGroupUpdate
  extend self

  def call(user:, links:)
    difference = user.link_ids - links.pluck(:id).map(&:to_i)
    user.links.where(id: difference).destroy_all if difference.any?
    links.each do |link|
      # Note(RO): we dont' want to use find_or_create_by here because id can be nil and we don't want to save twice with difference IDs
      existing_link = user.links.find_by_id(link[:id].to_i)
      if existing_link.present?
        existing_link.update! name: link[:name], url: link[:url]
      else
        user.links.create! name: link[:name], url: link[:url]
      end
    end
  end
end
