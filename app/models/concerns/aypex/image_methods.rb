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

      def generate_url(width: nil, height: nil, quality: nil, format: nil)
        set_format = assess_format(attachment, format)
        set_width = width || attachment.metadata[:width]
        set_height = height || attachment.metadata[:height]

        if attachment&.attached? && attachment&.variable?
          cdn_image_url(attachment.variant(resize_to_limit: [set_width, set_height], saver: {quality: quality}, convert: set_format), format: set_format, only_path: Rails.application.routes.default_url_options[:host].blank?)
        else
          cdn_image_url(attachment, only_path: Rails.application.routes.default_url_options[:host].blank?)
        end
      end

      private

      def assess_format(attachment, requested_format)
        return if requested_format.nil?

        current_format = case attachment.content_type
        when "image/png"
          :png
        when "image/jpg"
          :jpg
        when "image/jpeg"
          :jpg
        when "image/gif"
          :gif
        when "image/tiff"
          :tiff
        when "image/webp"
          :webp
        when "image/avif"
          :avif
        when "image/heic"
          :heic
        when "image/heif"
          :heif
        end

        if current_format == requested_format
          nil
        else
          requested_format.to_s
        end
      end
    end
  end
end
