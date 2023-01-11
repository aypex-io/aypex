class UpdateLinkableResourceTypes < ActiveRecord::Migration[5.2]
  def change
    change_column_default :aypex_menu_items, :linked_resource_type, "Aypex::Linkable::Uri"

    Aypex::MenuItem.where(linked_resource_type: "URL").update_all(linked_resource_type: "Aypex::Linkable::Uri")
    Aypex::CmsSection.where(linked_resource_type: "URL").update_all(linked_resource_type: "Aypex::Linkable::Uri")
    Aypex::MenuItem.where(linked_resource_type: "Home Page").update_all(linked_resource_type: "Aypex::Linkable::Homepage")
    Aypex::CmsSection.where(linked_resource_type: "Home Page").update_all(linked_resource_type: "Aypex::Linkable::Homepage")
  end
end
