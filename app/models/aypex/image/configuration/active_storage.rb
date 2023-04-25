module Aypex
  class Image < Asset
    module Configuration
      module ActiveStorage
        extend ActiveSupport::Concern

        included do
          if Aypex::Config.public_storage_service_name
            has_one_attached :attachment, service: Aypex::Config.public_storage_service_name
          else
            has_one_attached :attachment
          end

          validates :attachment, attached: true, content_type: /\Aimage\/.*\z/

          default_scope { includes(attachment_attachment: :blob) }
        end
      end
    end
  end
end
