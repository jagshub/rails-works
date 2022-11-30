# frozen_string_literal: true

module PlatformStores
  class AmazonStore < Store.new(
    enum: 8,
    name: 'Amazon',
    key: :amazon,
    os: 'Web',
    matchers: [
      %r{^amazon\.com(/[\p{L}\p{S}\p{N}\-%]+)?/dp/[\w\d]+/?}i, # Note(andreasklinger): amazon allows unicode characters in urls
      %r{^amazon\.com/gp/product/[\w\d]+/?}i, # Note(andreasklinger): amazon allows unicode characters in urls
      %r{^amazon\.ca(/[\p{L}\p{S}\p{N}\-%]+)?/dp/[\w\d]+/?}i, # Note(andreasklinger): amazon allows unicode characters in urls
      %r{^amazon\.co\.uk(/[\p{L}\p{S}\p{N}\-%]+)?/dp/[\w\d]+/?}i, # Note(andreasklinger): amazon allows unicode characters in urls
      %r{^amazon\.in(/[\p{L}\p{S}\p{N}\-%]+)?/dp/[\w\d]+/?}i, # Note(andreasklinger): amazon allows unicode characters in urls
      %r{^amazon\.com(/[\p{L}\p{S}\p{N}\-%]+)?/dp/[\w\d]+/?}i, # Note(andreasklinger): amazon allows unicode characters in urls
      %r{^([\w\d-]+)\.amazon\.com(/[\p{L}\p{S}\p{N}\-%]+)?/dp/[\w\d]+/?}i, # Note(andreasklinger): amazon allows unicode characters in urls
      %r{^amzn.to(/[\w\d]+)}i,
      %r{^amzn\.com(/[\w\d]+)}i,
    ],
  )
  end
end
