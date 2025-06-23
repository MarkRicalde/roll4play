class AddDeviseToPlayers < ActiveRecord::Migration[8.0]
  def change
    change_table :players do |t|
      ## Devise modules
      t.string :encrypted_password, null: false, default: ""

      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      t.datetime :remember_created_at

        t.text :bio
        t.string :avatar

      t.index :reset_password_token, unique: true
    end

    add_column :campaigns, :system, :string
  end
end