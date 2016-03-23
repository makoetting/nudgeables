class AddOutreachToTexts < ActiveRecord::Migration
  def change
    add_column :texts, :outreach, :string
  end
end
