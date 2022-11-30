# frozen_string_literal: true

module Cards::Identifier
  extend self

  def encode_for(object)
    base =
      case object
      when Post
        "Post:#{ object.id }"
      when Comment
        "Comment:#{ object.id }"
      when Review
        "Review:#{ object.id }"
      when Product
        "Product:#{ object.id }"
      else
        raise ArgumentError, "Unknown object: #{ object }"
      end

    Base64.urlsafe_encode64(base)
  end

  def object_for(id)
    # NOTE(DZ): IDs are base64 encoded of the form: "Class:id"
    resource, id = Base64.urlsafe_decode64(id).split(':')

    case resource
    when 'Post'
      Post.find_by(id: id)
    when 'Comment'
      Comment.find_by(id: id)
    when 'Review'
      Review.find_by(id: id)
    when 'Product'
      Product.find_by(id: id)
    end
  rescue ArgumentError
    # NOTE(DZ): ArgumentError occurs when Base64.urlsafe_decode64
    nil
  end
end
