# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160207002609) do

  create_table "entities", force: :cascade do |t|
    t.string   "subdomain"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imports", force: :cascade do |t|
    t.string   "import_type"
    t.string   "import_file"
    t.string   "error_file"
    t.integer  "number_of_records"
    t.integer  "number_of_records_with_errors"
    t.integer  "entity_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.integer  "records_processed"
  end

  create_table "nfg_csv_importer_imported_records", force: :cascade do |t|
    t.integer  "entity_id"
    t.integer  "user_id"
    t.string   "action"
    t.integer  "importable_id"
    t.string   "importable_type"
    t.string   "transaction_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nfg_csv_importer_imports", force: :cascade do |t|
    t.string   "import_type"
    t.string   "import_file"
    t.string   "error_file"
    t.integer  "number_of_records"
    t.integer  "number_of_records_with_errors"
    t.integer  "entity_id"
    t.integer  "user_id"
    t.integer  "status"
    t.integer  "records_processed"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
