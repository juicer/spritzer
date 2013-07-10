class CreateCarts < ActiveRecord::Migration
  def change
    create_table :carts do |t|
      t.string :name
      t.text :manifest

      t.timestamps
    end
  end
end
