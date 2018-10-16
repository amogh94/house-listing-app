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

ActiveRecord::Schema.define(version: 2018_09_28_152543) do

  create_table "companies", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", limit: 100, null: false
    t.string "website", limit: 320
    t.string "address", limit: 1000
    t.string "size", limit: 25
    t.integer "founded"
    t.decimal "revenue", precision: 10
    t.text "synopsis", limit: 16777215
  end

  create_table "houses", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "company_id"
    t.string "location", limit: 1000
    t.string "sq_footage", limit: 100
    t.integer "year_build"
    t.string "style", limit: 20
    t.decimal "list_price", precision: 10
    t.integer "floors"
    t.boolean "basement"
    t.string "current_owner", limit: 100
    t.integer "realtor_id"
    t.binary "pic", limit: 4294967295
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["company_id"], name: "company_id"
    t.index ["realtor_id"], name: "realtor_id"
  end

  create_table "inquiries", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "interest_id"
    t.text "subject", limit: 16777215
    t.text "message", limit: 16777215
    t.text "reply", limit: 16777215
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["interest_id"], name: "interest_id"
  end

  create_table "interests", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "house_id", null: false
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["house_id"], name: "house_id"
    t.index ["user_id"], name: "user_id"
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name", limit: 100
    t.string "email", limit: 320, null: false
    t.string "password_digest", limit: 200
    t.integer "role", null: false
    t.string "phone", limit: 20
    t.string "preferred_contact_method", limit: 10
    t.integer "company_id"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }
    t.datetime "updated_at", default: -> { "CURRENT_TIMESTAMP" }
    t.index ["company_id"], name: "company_id"
  end

  add_foreign_key "houses", "companies", name: "houses_ibfk_1"
  add_foreign_key "houses", "users", column: "realtor_id", name: "houses_ibfk_2"
  add_foreign_key "inquiries", "interests", name: "inquiries_ibfk_1"
  add_foreign_key "interests", "houses", name: "interests_ibfk_2"
  add_foreign_key "interests", "users", name: "interests_ibfk_1"
  add_foreign_key "users", "companies", name: "users_ibfk_1"
end
