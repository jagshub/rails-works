# frozen_string_literal: true

module Graph::Types
  class Web3::ChainType < BaseObject
    field :name, String, null: false
    field :image, String, null: false
  end
end
