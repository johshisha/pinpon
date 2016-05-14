class AddResultToAttacks < ActiveRecord::Migration
  def change
    add_column :attacks, :result, :integer
  end
end
