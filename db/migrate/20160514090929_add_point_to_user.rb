class AddPointToUser < ActiveRecord::Migration
  def change
    add_column :users, :point, :integer
  end
end
