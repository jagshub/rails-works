# frozen_string_literal: true

module Ads::TopicBundle
  extend self

  # NOTE(rstankov): When you remove a bundle from here and it is used before, make sure to add it to `DELETED_BUNDLES`
  BUNDLE = {
    apple: [362, 12, 26, 19, 8, 9, 303],
    art: [76, 738, 740, 737, 739, 736, 734, 732, 741, 733, 735],
    audio: [471, 748, 750, 744, 57, 746, 65, 66, 747, 742, 226, 745, 743, 749],
    beauty_and_fashion: [553, 228, 751, 753, 70, 59, 74, 752],
    books: [354, 81, 179, 178, 763, 182, 221, 194, 177, 181, 193, 173, 202, 175, 174, 762, 180, 761],
    business: [570, 468, 71, 766, 55, 72, 767, 469, 259, 237, 472, 123, 41, 770, 765, 764, 769, 768],
    data_and_analytics: [582, 774, 130, 772, 776, 108, 773, 775, 771],
    design_tools: [624, 807, 803, 132, 134, 805, 802, 808, 271, 93, 214, 44, 810, 811, 809, 804, 806, 801],
    developer_tools: [589, 88, 243, 213, 779, 89, 780, 470, 272, 268, 267, 247, 372, 778, 777],
    education: [204, 209, 375, 782, 781],
    entertainment: [600, 105, 100, 307, 52, 266, 260, 359, 265, 253, 53, 783, 273, 784],
    events: [84, 787, 786, 788, 789, 785],
    extended_reality: [609, 790, 30, 269, 363],
    fintech: [611, 203, 792, 94, 230, 374, 208, 791, 795, 793, 794],
    food_and_drink: [617, 799, 159, 80, 798, 176, 254, 797, 800, 796],
    games: [353, 3, 160, 152, 154, 11, 139, 168, 162, 146, 147, 145, 166, 246, 167, 153, 150, 156, 161, 163, 36, 144, 143, 165, 37, 149, 142, 4, 155, 148, 141, 348, 140, 151, 6],
    hardware: [125, 814, 812, 31, 97, 816, 813, 12, 27, 7, 210, 232, 25, 24, 211, 5, 17, 23, 815, 110, 26],
    health_and_fitness: [43, 817, 264, 138, 820, 364, 172, 261, 366, 819, 818, 435, 365],
    home: [73, 822, 67, 827, 828, 137, 825, 357, 824, 823, 358, 826, 821],
    kids_and_parenting: [659, 832, 82, 157, 830, 831, 833, 829],
    lifestyle: [665, 1029, 834, 837, 103, 223, 170, 835, 217, 51, 836, 42, 838],
    marketing: [164, 207, 843, 845, 95, 231, 128, 206, 135, 402, 839, 842, 85, 844, 840, 841],
    nature_and_outdoors: [680, 349, 345, 227, 851, 846, 849, 848, 847, 850],
    news: [50, 853, 855, 854, 852],
    pets: [199, 856, 78, 198],
    photo_and_video: [692, 860, 251, 858, 859, 68, 861, 857],
    privacy: [248, 124, 61, 863, 862, 864],
    product_hunt: [276],
    productivity: [46, 252, 87, 361, 131, 274, 205, 39, 107, 371, 356, 96, 90, 256, 48, 22, 49, 303, 865, 45, 282, 54],
    science: [711, 866],
    shopping: [713, 119, 278, 868, 64, 275, 867, 277],
    social_networking: [717, 60, 104, 341, 279, 63, 343, 283, 242, 101, 346, 280, 29, 342, 102, 870, 351, 869],
    sports: [111, 116, 873, 113, 115, 114, 220, 218, 219, 1062, 224, 79, 872, 112, 871],
    travel: [250, 308, 876, 117, 249, 258, 355, 875, 92, 28, 874, 877],
    web3: [501, 756, 996, 759, 758, 757, 755, 212, 760, 754],
    web: [21],
  }.freeze

  SPECIAL_BUNDLES = %w(homepage_primary searchpage everything).freeze

  DELETED_BUNDLES = %w(homepage_secondary homepage_other mac_apps).freeze

  def enum
    value = (SPECIAL_BUNDLES + DELETED_BUNDLES).inject({}) do |acc, key|
      acc[key] = key.to_s
      acc
    end

    BUNDLE.inject(value) do |acc, (key, _)|
      acc[key] = key.to_s
      acc
    end
  end

  def find_bundles(topic_ids, bundle: nil)
    bundles = Array(bundle&.to_s)
    bundles = append_topic_bundles(bundles, topic_ids)

    append_special(bundles)
  end

  private

  def append_topic_bundles(bundles, topic_ids)
    bundles + BUNDLE.keys.map do |key|
      count = topic_ids.count
      topic_ids -= BUNDLE[key]

      topic_ids.count < count ? key.to_s : nil
    end.compact
  end

  def append_special(bundles)
    # NOTE(DZ): If homepage_primary is the only bundle requested, return as is
    return bundles if bundles == ['homepage_primary']

    # NOTE(DZ): Append `everything`. This is used as a backfill
    bundles + [Ads::Channel.bundles['everything']]
  end
end
