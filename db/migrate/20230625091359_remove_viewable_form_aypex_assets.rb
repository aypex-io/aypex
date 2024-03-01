class RemoveViewableFormAypexAssets < ActiveRecord::Migration[7.0]
  def change
    remove_belongs_to :aypex_assets, :viewable, polymorphic: true
  end
end
