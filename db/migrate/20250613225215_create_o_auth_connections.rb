class CreateOAuthConnections < ActiveRecord::Migration[7.1]
  def change
    create_table :o_auth_connections do |t|
      t.string :provider
      t.string :uid
      t.string :access_token
      t.string :refresh_token
      t.datetime :expires_at
      t.string :token_type
      t.string :scope
      t.jsonb :extra_data

      t.timestamps
    end
  end
end
