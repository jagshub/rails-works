# frozen_string_literal: true

module Sharing::Text
  module Review
    def self.call(review, user:)
      possessor = if review.user == user
                    'my'
                  else
                    "#{ review.user.name }'s"
                  end

      url = Routes.review_url(review)

      product_name = review.product.present? ? review.product.name : review.subject.name

      Twitter::Message
        .new
        .add_mandatory("Check out #{ possessor } review of #{ product_name }:")
        .add_mandatory(url)
        .to_s
    end
  end
end
