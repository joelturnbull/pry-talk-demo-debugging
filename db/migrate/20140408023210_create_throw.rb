class CreateThrow < ActiveRecord::Migration
  def change
    create_table :throws do |t|
      t.integer :bowling_game_id
      t.integer :pins
    end
  end
end
