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

ActiveRecord::Schema.define(version: 2020_08_11_154031) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
  end

  create_table "exemps", force: :cascade do |t|
    t.string "exemplifikace"
    t.integer "author_id"
    t.integer "entry_id"
    t.boolean "vetne"
    t.integer "zdroj_id"
    t.integer "lokalizace_obec"
    t.integer "lokalizace_cast_obce"
    t.string "lokalizace_text"
    t.string "rok"
    t.string "kvalifikator"
    t.string "vyznam"
    t.boolean "aktivni"
    t.boolean "chybne"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "n3_casti_obce_body", id: false, force: :cascade do |t|
    t.integer "cat"
    t.bigint "objectid"
    t.string "kod_cob", limit: 6
    t.string "naz_zkr_co", limit: 60
    t.string "naz_cob", limit: 254
    t.string "kod_obec", limit: 6
    t.string "naz_obec", limit: 40
    t.string "kod_zuj", limit: 6
    t.string "naz_zuj", limit: 40
    t.string "kod_pou", limit: 5
    t.string "naz_pou", limit: 254
    t.string "kod_orp", limit: 4
    t.string "naz_orp", limit: 254
    t.string "kod_okres", limit: 5
    t.string "kod_lau1", limit: 6
    t.string "naz_lau1", limit: 40
    t.string "kod_kraj", limit: 4
    t.string "kod_cznuts", limit: 6
    t.string "naz_cznuts", limit: 40
    t.float "sx"
    t.float "sy"
    t.index ["cat"], name: "n3_casti_obce_body_cat", unique: true
  end

  create_table "n3_casti_obce_polygony", id: false, force: :cascade do |t|
    t.integer "cat"
    t.bigint "objectid"
    t.string "kod_cob", limit: 6
    t.string "naz_zkr_co", limit: 60
    t.string "naz_cob", limit: 254
    t.string "kod_obec", limit: 6
    t.string "naz_obec", limit: 40
    t.string "kod_zuj", limit: 6
    t.string "naz_zuj", limit: 40
    t.string "kod_pou", limit: 5
    t.string "naz_pou", limit: 254
    t.string "kod_orp", limit: 4
    t.string "naz_orp", limit: 254
    t.string "kod_okres", limit: 5
    t.string "kod_lau1", limit: 6
    t.string "naz_lau1", limit: 40
    t.string "kod_kraj", limit: 4
    t.string "kod_cznuts", limit: 6
    t.string "naz_cznuts", limit: 40
    t.float "sx"
    t.float "sy"
    t.float "shape_leng"
    t.float "shape_area"
    t.index ["cat"], name: "n3_casti_obce_polygony_cat", unique: true
  end

  create_table "n3_kraje_polygony", id: false, force: :cascade do |t|
    t.integer "cat"
    t.bigint "objectid"
    t.string "kod_kraj", limit: 4
    t.string "kod_cznuts", limit: 6
    t.string "naz_cznuts", limit: 40
    t.float "snatky"
    t.float "rozvody"
    t.float "narozeni"
    t.float "zemreli"
    t.float "pristehova"
    t.float "vystehoval"
    t.float "pocet_obyv"
    t.float "muzi"
    t.float "zeny"
    t.float "obyv_0_14"
    t.float "muzi_0_14"
    t.float "zeny_0_14"
    t.float "obyv_15_64"
    t.float "muzi_15_64"
    t.float "zeny_15_64"
    t.float "obyv_65"
    t.float "muzi_65"
    t.float "zeny_65"
    t.float "mira_nezam"
    t.float "mira_nez_1"
    t.float "mira_nez_2"
    t.float "mzda"
    t.float "rozdil_mzd"
    t.float "nadeje_doz"
    t.float "nadeje_d_1"
    t.float "sx"
    t.float "sy"
    t.float "shape_leng"
    t.float "shape_area"
    t.index ["cat"], name: "n3_kraje_polygony_cat", unique: true
  end

  create_table "n3_obce_body", id: false, force: :cascade do |t|
    t.integer "cat"
    t.bigint "objectid"
    t.string "kod_obec", limit: 6
    t.string "naz_obec", limit: 40
    t.string "kod_zuj", limit: 6
    t.string "naz_zuj", limit: 40
    t.string "kod_pou", limit: 5
    t.string "naz_pou", limit: 254
    t.string "kod_orp", limit: 4
    t.string "naz_orp", limit: 254
    t.string "kod_okres", limit: 5
    t.string "kod_lau1", limit: 6
    t.string "naz_lau1", limit: 40
    t.string "kod_kraj", limit: 4
    t.string "kod_cznuts", limit: 6
    t.string "naz_cznuts", limit: 40
    t.float "snatky"
    t.float "rozvody"
    t.float "narozeni"
    t.float "zemreli"
    t.float "pristehova"
    t.float "vystehoval"
    t.float "pocet_obyv"
    t.float "muzi"
    t.float "zeny"
    t.float "obyv_0_14"
    t.float "muzi_0_14"
    t.float "zeny_0_14"
    t.float "obyv_15_64"
    t.float "muzi_15_64"
    t.float "zeny_15_64"
    t.float "obyv_65"
    t.float "muzi_65"
    t.float "zeny_65"
    t.float "mira_nezam"
    t.float "sx"
    t.float "sy"
    t.index ["cat"], name: "n3_obce_body_cat", unique: true
  end

  create_table "n3_obce_polygony", id: false, force: :cascade do |t|
    t.integer "cat"
    t.bigint "objectid"
    t.string "kod_obec", limit: 6
    t.string "naz_obec", limit: 40
    t.string "kod_zuj", limit: 6
    t.string "naz_zuj", limit: 40
    t.string "kod_pou", limit: 5
    t.string "naz_pou", limit: 254
    t.string "kod_orp", limit: 4
    t.string "naz_orp", limit: 254
    t.string "kod_okres", limit: 5
    t.string "kod_lau1", limit: 6
    t.string "naz_lau1", limit: 40
    t.string "kod_kraj", limit: 4
    t.string "kod_cznuts", limit: 6
    t.string "naz_cznuts", limit: 40
    t.float "snatky"
    t.float "rozvody"
    t.float "narozeni"
    t.float "zemreli"
    t.float "pristehova"
    t.float "vystehoval"
    t.float "pocet_obyv"
    t.float "muzi"
    t.float "zeny"
    t.float "obyv_0_14"
    t.float "muzi_0_14"
    t.float "zeny_0_14"
    t.float "obyv_15_64"
    t.float "muzi_15_64"
    t.float "zeny_15_64"
    t.float "obyv_65"
    t.float "muzi_65"
    t.float "zeny_65"
    t.float "mira_nezam"
    t.float "sx"
    t.float "sy"
    t.float "shape_leng"
    t.float "shape_area"
    t.index ["cat"], name: "n3_obce_polygony_cat", unique: true
  end

  create_table "n3_okresy_polygony", id: false, force: :cascade do |t|
    t.integer "cat"
    t.bigint "objectid"
    t.string "kod_okres", limit: 5
    t.string "kod_lau1", limit: 6
    t.string "naz_lau1", limit: 40
    t.string "kod_kraj", limit: 4
    t.string "kod_cznuts", limit: 6
    t.string "naz_cznuts", limit: 40
    t.float "snatky"
    t.float "rozvody"
    t.float "narozeni"
    t.float "zemreli"
    t.float "pristehova"
    t.float "vystehoval"
    t.float "pocet_obyv"
    t.float "muzi"
    t.float "zeny"
    t.float "obyv_0_14"
    t.float "muzi_0_14"
    t.float "zeny_0_14"
    t.float "obyv_15_64"
    t.float "muzi_15_64"
    t.float "zeny_15_64"
    t.float "obyv_65"
    t.float "muzi_65"
    t.float "zeny_65"
    t.float "mira_nezam"
    t.float "mira_nez_1"
    t.float "mira_nez_2"
    t.float "nadeje_doz"
    t.float "nadeje_d_1"
    t.float "sx"
    t.float "sy"
    t.float "shape_leng"
    t.float "shape_area"
    t.index ["cat"], name: "n3_okresy_polygony_cat", unique: true
  end

  create_table "sources", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
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

end
