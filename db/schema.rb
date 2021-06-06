# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_05_23_143706) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "entries", force: :cascade do |t|
    t.text "text"
    t.integer "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "heslo"
    t.string "kvalifikator"
    t.string "vyznam"
    t.boolean "vetne"
    t.integer "druh"
    t.integer "rod"
    t.string "tvary"
    t.string "urceni"
    t.string "tvar_map"
  end

  create_table "exemps", force: :cascade do |t|
    t.string "exemplifikace"
    t.integer "author_id"
    t.integer "entry_id"
    t.boolean "vetne"
    t.integer "zdroj_id"
    t.string "lokalizace_obec"
    t.string "lokalizace_cast_obce"
    t.string "lokalizace_text"
    t.string "rok"
    t.string "kvalifikator"
    t.string "vyznam"
    t.boolean "aktivni"
    t.boolean "chybne"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "rod"
    t.jsonb "urceni"
    t.bigint "meaning_id"
    t.bigint "location_text_id"
    t.integer "urceni_sort"
    t.index ["location_text_id"], name: "index_exemps_on_location_text_id"
    t.index ["meaning_id"], name: "index_exemps_on_meaning_id"
  end

  create_table "location_texts", force: :cascade do |t|
    t.integer "cislo"
    t.string "identifikator"
    t.string "presentace"
    t.text "definice"
    t.string "zdroje"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "meanings", force: :cascade do |t|
    t.integer "cislo"
    t.string "vyznam"
    t.string "kvalifikator"
    t.bigint "entry_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["entry_id"], name: "index_meanings_on_entry_id"
  end

  create_table "sources", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "typ"
    t.integer "rok"
    t.string "lokalizace"
    t.string "autor"
    t.integer "cislo"
    t.integer "rok_sberu"
    t.string "nazev2"
    t.string "bibliografie"
    t.string "lokalizace_text"
    t.string "name_processed"
    t.string "lokalizace_obec"
    t.string "lokalizace_cast_obce"
    t.string "nazev2_processed"
    t.bigint "location_text_id"
    t.index ["location_text_id"], name: "index_sources_on_location_text_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "password"
    t.string "token"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "exemps", "meanings"
  add_foreign_key "meanings", "entries"
end
