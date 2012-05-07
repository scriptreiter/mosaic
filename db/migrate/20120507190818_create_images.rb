class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :color, :limit => 6
      t.string :url

      t.timestamps
    end
  end
end
