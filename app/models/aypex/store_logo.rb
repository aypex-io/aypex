module Aypex
  class StoreLogo < Asset
    if Aypex::Config.public_storage_service_name
      has_one_attached :attachment, service: Aypex::Config.public_storage_service_name
    else
      has_one_attached :attachment
    end
  end
end
