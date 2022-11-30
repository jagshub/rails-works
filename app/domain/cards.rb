# frozen_string_literal: true

module Cards
  extend self

  def object_for(id)
    Cards::Identifier.object_for(id)
  end

  def id_for(object)
    Cards::Identifier.encode_for(object)
  end
end
