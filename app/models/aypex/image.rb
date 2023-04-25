module Aypex
  class Image < Asset
    include Rails.application.routes.url_helpers

    if Aypex::Config.public_storage_service_name
      has_one_attached :attachment, service: Aypex::Config.public_storage_service_name
    else
      has_one_attached :attachment
    end

    validates :attachment, attached: true, content_type: /\Aimage\/.*\z/

    default_scope { includes(attachment_attachment: :blob) }

    def generate_url(size:, gravity: "centre", quality: 80, background: [0, 0, 0])
      return if size.blank?

      size = size.gsub(/\s+/, "")

      return unless /(\d+)x(\d+)/.match?(size)

      width, height = size.split("x").map(&:to_i)
      gravity = translate_gravity(gravity)

      cdn_image_url(attachment.variant(resize_and_pad: [width, height, {gravity: gravity}], saver: {quality: quality}), only_path: true)
    end

    def original_url
      cdn_image_url(attachment)
    end

    private

    def translate_gravity(gravity)
      variant_processor = Rails.application.config.active_storage.variant_processor

      if gravity.downcase == "centre" && [:mini_magick, nil].include?(variant_processor)
        "center"
      else
        gravity
      end
    end
  end
end
