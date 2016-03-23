class AddSentimentToTexts < ActiveRecord::Migration
  def change
    add_column :texts, :sentiment, :text
  end
end
