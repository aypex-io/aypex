module Aypex
  class StoreLogo < Aypex::Base
    belongs_to :store, inverse_of: :logo

    after_initialize :find_or_build_image

    has_one :image, class_name: "Aypex::Asset::Validate::Image", dependent: :destroy, as: :viewable
    accepts_nested_attributes_for :image, reject_if: :all_blank

    private

    def find_or_build_image
      image || build_image
    end
  end
end
