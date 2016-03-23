class AddRosterIdToTexts < ActiveRecord::Migration
  def change
    add_column :texts, :roster_id, :integer
  end
end
