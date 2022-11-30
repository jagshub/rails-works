# frozen_string_literal: true

module Image
  extend self

  BASE_URL = 'https://ph-files.imgix.net'

  def call(uuid, width: nil, height: nil, fit: nil, format: nil, palette: nil, blend: nil, blur: nil, balph: nil, crop: nil, dpr: nil, fill: nil, frame: nil)
    return if uuid.blank?

    uri = Addressable::URI.parse("#{ BASE_URL }/#{ uuid }")

    uri.query_values = query_values(
      width: width,
      height: height,
      fit: fit,
      format: format,
      palette: palette,
      blend: blend,
      blur: blur,
      balph: balph,
      crop: crop,
      dpr: dpr,
      fill: fill,
      frame: frame,
    )

    uri.to_s
  end

  private

  def query_values(width:, height:, fit:, format:, palette:, blend:, blur:, balph:, crop:, dpr:, fill:, frame:)
    values = {}
    values[:auto] = 'format' if format.blank?
    values[:fm] = format if format.present?
    values[:w] = width if width.present?
    values[:h] = height if height.present?
    values[:fit] = fit if fit.present?
    values[:palette] = palette if palette.present?
    values[:blend] = blend if blend.present?
    values[:blur] = blur if blur.present?
    values[:balph] = balph if balph.present?
    values[:crop] = crop if crop.present?
    values[:dpr] = dpr if dpr.present?
    values[:fill] = fill if fill.present?
    values[:frame] = frame if frame.present?
    values
  end
end
