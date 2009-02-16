ActiveRecord::Schema.define(:version => 0) do
  create_table :mommy_chickens, :force => true do |t|
    t.string :name
    t.timestamps
  end
  create_table :little_chickens, :force => true do |t|
    t.integer :mommy_chicken_id
    t.string :name
  end
end
