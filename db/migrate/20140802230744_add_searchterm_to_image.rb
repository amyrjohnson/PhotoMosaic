class AddSearchtermToImage < ActiveRecord::Migration
  def change
    add_column :images, :search_term, :string
  end
end
