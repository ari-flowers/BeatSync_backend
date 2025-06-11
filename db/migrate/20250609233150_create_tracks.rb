class CreateTracks < ActiveRecord::Migration[7.1]
  def change
    create_table :tracks do |t|
      t.string :title
      t.string :artist
      t.string :album
      t.string :image_url
      t.string :provider
      t.string :provider_id
      t.references :playlist, null: false, foreign_key: true

      t.timestamps
    end
  end
end
