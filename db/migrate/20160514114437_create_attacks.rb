class CreateAttacks < ActiveRecord::Migration
  def change
    create_table :attacks do |t|
      t.integer :attacker_id
      t.integer :defender_id

      t.timestamps null: false
    end
  end
end
