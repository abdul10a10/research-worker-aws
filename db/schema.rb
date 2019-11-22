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

ActiveRecord::Schema.define(version: 2019_11_22_060542) do

  create_table "answers", force: :cascade do |t|
    t.integer "question_id"
    t.string "description"
    t.integer "follow_up_question"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "audiences", force: :cascade do |t|
    t.string "study_id"
    t.string "question_id"
    t.string "answer_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "blacklist_users", force: :cascade do |t|
    t.string "user_id"
    t.string "study_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "eligible_candidates", force: :cascade do |t|
    t.string "user_id"
    t.string "study_id"
    t.string "is_attempted"
    t.datetime "start_time"
    t.datetime "submit_time"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "is_accepted"
    t.text "reject_reason"
    t.string "is_completed"
    t.integer "is_paid"
    t.integer "is_seen"
  end

  create_table "messages", force: :cascade do |t|
    t.string "reciever_id"
    t.string "sender_id"
    t.string "subject"
    t.text "description"
    t.string "status"
    t.integer "seen_status"
    t.datetime "seen_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
    t.integer "is_archive"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "notification_type"
    t.integer "user_id"
    t.string "message"
    t.string "redirect_url"
    t.string "seen_status"
    t.string "status"
    t.datetime "seen_time"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "privacy_policies", force: :cascade do |t|
    t.string "country"
    t.string "user_type"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "question_categories", force: :cascade do |t|
    t.string "name"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "question_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "questions", force: :cascade do |t|
    t.integer "question_type_id"
    t.integer "question_category_id"
    t.string "title"
    t.string "description"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description2"
  end

  create_table "responses", force: :cascade do |t|
    t.integer "user_id"
    t.integer "question_id"
    t.integer "answer_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "text_answer"
  end

  create_table "studies", force: :cascade do |t|
    t.string "user_id"
    t.string "name"
    t.string "completionurl"
    t.string "completioncode"
    t.string "studyurl"
    t.string "allowedtime"
    t.string "estimatetime"
    t.integer "submission"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reward"
    t.string "is_published"
    t.string "is_active"
    t.string "is_complete"
    t.datetime "deleted_at"
    t.text "deactivate_reason"
    t.integer "is_paid"
    t.float "study_wallet", default: 0.0
    t.datetime "max_participation_date"
    t.integer "is_republish"
    t.integer "only_whitelisted"
  end

  create_table "terms_and_conditions", force: :cascade do |t|
    t.string "country"
    t.string "user_type"
    t.string "title"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "terms_of_uses", force: :cascade do |t|
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

  create_table "transactions", force: :cascade do |t|
    t.string "transaction_id"
    t.string "study_id"
    t.string "payment_type"
    t.string "sender_id"
    t.string "receiver_id"
    t.float "amount"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "order_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "user_type"
    t.string "country"
    t.string "university"
    t.string "university_email"
    t.string "department"
    t.string "specialisation"
    t.string "job_type"
    t.string "referral_code"
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "authentication_token", limit: 30
    t.string "status"
    t.datetime "deleted_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "authentication_token_sent_at"
    t.string "user_referral_code"
    t.string "verification_status"
    t.string "address"
    t.string "contact_number"
    t.string "nationality"
    t.float "wallet", default: 0.0
    t.string "research_worker_id", limit: 30
    t.string "image_url"
    t.index ["authentication_token"], name: "index_users_on_authentication_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["research_worker_id"], name: "index_users_on_research_worker_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["user_referral_code"], name: "index_users_on_user_referral_code", unique: true
  end

  create_table "whitelist_users", force: :cascade do |t|
    t.string "user_id"
    t.string "study_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "deleted_at"
  end

end
