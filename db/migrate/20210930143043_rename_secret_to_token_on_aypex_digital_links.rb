class RenameSecretToTokenOnAypexDigitalLinks < ActiveRecord::Migration[7.0]
  def change
    rename_column :aypex_digital_links, :secret, :token
  end
end
