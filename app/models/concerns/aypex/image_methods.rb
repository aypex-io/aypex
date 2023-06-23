module Aypex
  module ImageMethods
    extend ActiveSupport::Concern

    included do
      include Rails.application.routes.url_helpers

      if Aypex::Config.public_storage_service_name
        has_one_attached :attachment, service: Aypex::Config.public_storage_service_name
      else
        has_one_attached :attachment
      end

      default_scope { includes(attachment_attachment: :blob) }

      def generate_url(width: 250, height: nil, quality: 80, format: :webp)
        if attachment&.attached? && attachment&.variable?
          cdn_image_url(attachment.variant(resize_to_limit: [width, height], saver: {quality: quality}, convert: format, format: format), only_path: Rails.application.routes.default_url_options[:host].blank?)
        else
          cdn_image_url(attachment, only_path: Rails.application.routes.default_url_options[:host].blank?)
        end
      end
    end
  end
end
