# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_29_133332) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
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

  create_table "entities", force: :cascade do |t|
    t.string "subdomain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nfg_csv_importer_imported_records", force: :cascade do |t|
    t.integer "imported_for_id"
    t.integer "imported_by_id"
    t.string "action"
    t.integer "importable_id"
    t.string "importable_type"
    t.string "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "import_id"
    t.boolean "deleted", default: false
    t.text "row_data"
    t.index ["import_id"], name: "index_nfg_csv_importer_imported_records_on_import_id"
  end

  create_table "nfg_csv_importer_imports", force: :cascade do |t|
    t.string "import_type"
    t.string "import_file"
    t.string "error_file"
    t.integer "number_of_records"
    t.integer "number_of_records_with_errors"
    t.integer "imported_for_id"
    t.integer "imported_by_id"
    t.integer "status"
    t.integer "records_processed"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "fields_mapping"
    t.string "import_file_name"
    t.datetime "processing_started_at"
    t.datetime "processing_finished_at"
    t.string "pre_processing_type"
  end

  create_table "projects", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.integer "cause_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.integer "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "note"
  end

end
