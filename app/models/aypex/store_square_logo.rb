module Aypex
  class StoreSquareLogo < Aypex::Base
    belongs_to :store, inverse_of: :square_logo

    after_initialize :ensure_image

    has_one :image, class_name: "Aypex::Image", dependent: :destroy, as: :viewable
    accepts_nested_attributes_for :image, reject_if: :all_blank

    private

    def ensure_image
      return unless id

      image || Image.create!(viewable_id: id, viewable_type: self.class.name)
    end
  end
end
