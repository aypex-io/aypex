module Aypex
  class PrototypeTaxon < Aypex::Base
    belongs_to :taxon, class_name: "Aypex::Taxon"
    belongs_to :prototype, class_name: "Aypex::Prototype"

    validates :prototype, :taxon, presence: true
    validates :prototype_id, uniqueness: {scope: :taxon_id}
  end
end
