class CreateImage < ActiveRecord::Migration
  def change
    create_table :images do |t|
        t.string :name
        t.string :avatar
    end
  end
end
