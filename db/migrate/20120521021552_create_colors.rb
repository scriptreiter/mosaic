class CreateColors < ActiveRecord::Migration
  def change
    create_table :colors do |t|
      t.string :url

      t.timestamps
    end
  end
end
