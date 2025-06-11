class CreateUserConnections < ActiveRecord::Migration[7.1]
  def change
    create_table :user_connections do |t|
      t.string :provider
      t.string :provider_id
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
