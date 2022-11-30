# frozen_string_literal: true

class HouseKeeperMailer < ApplicationMailer
  def dead_link(post, maker)
    @post = post
    maker_email = Subscriber.where(user: maker).first.email

    mail(
      to: maker_email,
      subject: "About #{ post.name } on Product Hunt",
    )
  end
end
