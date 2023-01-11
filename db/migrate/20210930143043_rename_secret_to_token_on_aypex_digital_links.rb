class RenameSecretToTokenOnAypexDigitalLinks < ActiveRecord::Migration[5.2]
  def change
    rename_column :aypex_digital_links, :secret, :token
  end
end
