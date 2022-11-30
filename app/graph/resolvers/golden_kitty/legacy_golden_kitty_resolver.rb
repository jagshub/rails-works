# frozen_string_literal: true

class Graph::Resolvers::GoldenKitty::LegacyGoldenKittyResolver < Graph::Resolvers::Base
  type Graph::Types::LegacyGoldenKittyType, null: true

  PRODUCT = (118_306..118_315).to_a.freeze
  MOBILE = (118_270..118_287).to_a.freeze
  HARDWARE = (118_237..118_252).to_a.freeze
  BOT = (118_142..118_157).to_a.freeze
  CRYPTO = (118_188..118_199).to_a.freeze
  AR = (118_114..118_126).to_a.freeze
  SIDEPROJECT = (118_288..118_305).to_a.freeze
  LIFEHACK = (118_253..118_269).to_a.freeze
  DESIGNTOOL = (118_200..118_219).to_a.freeze
  CONSUMER = (118_174..118_187).to_a.freeze
  BREAKOUT = (118_158..118_173).to_a.freeze
  DEVTOOL = (118_220..118_236).to_a.freeze
  B2B = (118_127..118_141).to_a.freeze
  WTF = (118_316..118_340).to_a.freeze

  COMMUNITY = %w(962 443764 335623 2081 18280 9832 16055 232526 171282 196937 199024 23 8843 81224 79 1015594 58 103184 10748 1565).freeze
  MAKER = %w(649146 4484 364 325479 395249 177 881746 62358 13376 315109 497 353837 17811 198991 911260 147980 143067 56547 407769 5818).freeze

  def resolve
    product = Post.where(id: PRODUCT)
    mobile = Post.where(id: MOBILE)
    hardware = Post.where(id: HARDWARE)
    bot = Post.where(id: BOT)
    crypto = Post.where(id: CRYPTO)
    ar = Post.where(id: AR)
    sideproject = Post.where(id: SIDEPROJECT)
    lifehack = Post.where(id: LIFEHACK)
    designtool = Post.where(id: DESIGNTOOL)
    consumer = Post.where(id: CONSUMER)
    breakout = Post.where(id: BREAKOUT)
    devtool = Post.where(id: DEVTOOL)
    b2b = Post.where(id: B2B)
    wtf = Post.where(id: WTF)

    community = User.where(id: COMMUNITY)
    maker = User.where(id: MAKER)

    OpenStruct.new(
      product: product,
      mobile: mobile,
      hardware: hardware,
      bot: bot,
      crypto: crypto,
      ar: ar,
      sideproject: sideproject,
      lifehack: lifehack,
      designtool: designtool,
      devtool: devtool,
      consumer: consumer,
      breakout: breakout,
      b2b: b2b,
      wtf: wtf,
      community: community,
      maker: maker,
    )
  end
end
