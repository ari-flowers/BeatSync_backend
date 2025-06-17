class CreatePlaylists < ActiveRecord::Migration[7.1]
  def change
    create_table :playlists do |t|
      t.string :name
      t.text :description
      t.string :image_url
      t.boolean :is_public
      t.string :provider
      t.string :provider_id
      # t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
