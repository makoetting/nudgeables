class AddFromToTexts < ActiveRecord::Migration
  def change
    add_column :texts, :number, :string
  end
end
