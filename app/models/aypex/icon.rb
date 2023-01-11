module Aypex
  class Icon < Aypex::Asset
    if Aypex::Config.public_storage_service_name
      has_one_attached :attachment, service: Aypex::Config.public_storage_service_name
    else
      has_one_attached :attachment
    end

    ICON_TYPES = %i[png jpg jpeg gif svg]

    validates :attachment, attached: true, content_type: ICON_TYPES
  end
end
