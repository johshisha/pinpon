class CreatePoints < ActiveRecord::Migration
  def change
    create_table :points do |t|
      t.integer :point
      t.string :user_name

      t.timestamps null: false
    end

  end
end
