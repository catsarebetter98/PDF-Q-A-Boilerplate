class CreateQuestions < ActiveRecord::Migration[6.1]
  def change
    create_table :questions do |t|
      t.string :question
      t.text :context
      t.text :answer
      t.integer :ask_count

      t.timestamps
    end
  end
end
