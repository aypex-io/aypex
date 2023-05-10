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

    def generate_url(width: 250, height: nil, quality: 80, format: :webp)
      cdn_image_url(attachment.variant(resize_to_limit: [width, height], saver: {quality: quality}, convert: format, format: format), only_path: Rails.application.routes.default_url_options[:host].empty?)
    end

    def original_url
      cdn_image_url(attachment, only_path: Rails.application.routes.default_url_options[:host].empty?)
    end
  end
end
