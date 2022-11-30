# frozen_string_literal: true

module Twitter::Image
  extend self

  # Note(Mike Coutermarsh): The Twitter gem is particular about the type of IO object it
  #   receives when tweeting an image. If an image is < 10kb, Ruby opens it as a
  #   StringIO object. Which is not supported by the Twitter gem/api.
  #
  #   This method ensures we always have a valid IO object for Twitter.
  def open_from_url(image_url)
    image_file = open_file(image_url)

    if image_file.is_a?(StringIO)
      file_name = File.basename(image_url)

      temp_file = Tempfile.new(file_name)
      temp_file.binmode
      temp_file.write(image_file.read)
      temp_file.close

      File.open(temp_file.path)
    elsif File.size(image_file) > 524_288_0
      image_url = ::Image.call(image_url.split('/').last.split('?').first, height: 200, width: 400)

      open_file(image_url)
    else
      image_file
    end
  rescue OpenURI::HTTPError
    nil
  end

  private

  def open_file(image_url)
    URI.parse(image_url).open
  end
end
