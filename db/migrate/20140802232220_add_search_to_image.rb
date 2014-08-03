class AddSearchToImage < ActiveRecord::Migration
  def change
    add_column :images, :search, :string
  end
end
