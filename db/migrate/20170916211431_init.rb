class Init < ActiveRecord::Migration[5.1]
  def change

    # Races
    #
    create_table :races do |t|
      t.string   :race_number, null: false
      t.datetime :start_time,  null: false
      t.datetime :end_time,    null: false
    end

    create_table :horses do |t|
      t.string :name, null: false
    end

    # Race/Horse Join
    #
    create_table :races_horses do |t|
      t.integer :race_id,  null: false, index: true
      t.integer :horse_id, null: false, index: true
      t.decimal :odds,     null: false
      t.integer :finish,   null: true
    end

    add_index :races_horses, [:race_id, :horse_id]

    add_foreign_key :races_horses, :races
    add_foreign_key :races_horses, :horses


    # Bettors
    #
    create_table :bettors do |t|
      t.string :name,  null: false
      t.string :email, null: false, index: :unique
    end


    # Bets
    #
    create_table :bets do |t|
      t.integer :bettor_id, null: false, index: true
      t.integer :race_id,   null: false, index: true
      t.integer :horse_id,  null: false, index: true
      t.decimal :amount,    null: false
    end

    add_index :bets, [:bettor_id, :race_id]

    add_foreign_key :bets, :bettors
    add_foreign_key :bets, :races
    add_foreign_key :bets, :horses


  end
end
