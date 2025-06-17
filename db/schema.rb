# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_06_13_225215) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "o_auth_connections", force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.string "access_token"
    t.string "refresh_token"
    t.datetime "expires_at"
    t.string "token_type"
    t.string "scope"
    t.jsonb "extra_data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "playlists", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "image_url"
    t.boolean "is_public"
    t.string "provider"
    t.string "provider_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tracks", force: :cascade do |t|
    t.string "title"
    t.string "artist"
    t.string "album"
    t.string "image_url"
    t.string "provider"
    t.string "provider_id"
    t.bigint "playlist_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["playlist_id"], name: "index_tracks_on_playlist_id"
  end

  create_table "user_connections", force: :cascade do |t|
    t.string "provider"
    t.string "provider_id"
    t.string "access_token"
    t.string "refresh_token"
    t.datetime "expires_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "tracks", "playlists"
end
