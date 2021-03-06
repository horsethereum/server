class Init < ActiveRecord::Migration[5.1]
  def change

    # Races
    #
    create_table :races do |t|
      t.date     :date,        null: false
      t.integer  :race_number, null: false
      t.datetime :start_time,  null: false
      t.datetime :end_time,    null: false
      t.boolean  :settled,     null: false, index: true, default: false
    end

    add_index :races, [:date, :race_number], unique: true


    # Horses
    #
    create_table :horses do |t|
      t.string :name, null: false
    end

    add_index :horses, :name, unique: true


    # Race/Horse Join
    #
    create_table :races_horses do |t|
      t.integer :race_id,  null: false, index: true
      t.integer :horse_id, null: false, index: true
      t.decimal :odds,     null: false
      t.integer :finish,   null: true
    end

    add_index :races_horses, [:race_id, :horse_id], unique: true

    add_foreign_key :races_horses, :races
    add_foreign_key :races_horses, :horses


    # Bettors
    #
    create_table :bettors do |t|
      t.string  :user_id, null: false
    end

    add_index :bettors, :user_id, unique: true


    # Bets
    #
    create_table :bets do |t|
      t.integer  :bettor_id,  null: false, index: true
      t.integer  :race_id,    null: false, index: true
      t.integer  :horse_id,   null: false, index: true
      t.decimal  :amount,     null: false
      t.decimal  :profit,     null: false, default: 0
      t.datetime :created_at, null: false, index: true
    end

    add_index :bets, [:bettor_id, :race_id, :horse_id]

    add_foreign_key :bets, :bettors
    add_foreign_key :bets, :races
    add_foreign_key :bets, :horses


  end
end
