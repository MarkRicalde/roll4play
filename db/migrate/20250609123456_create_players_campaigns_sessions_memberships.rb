class CreatePlayersCampaignsSessionsMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.timestamps
    end

    create_table :campaigns do |t|
      t.string :title, null: false
      t.text :description
      t.timestamps
    end

    create_table :sessions do |t|
      t.references :campaign, null: false, foreign_key: true
      t.datetime :played_at
      t.text :notes
      t.timestamps
    end

    create_table :memberships do |t|
      t.references :player, null: false, foreign_key: true
      t.references :campaign, null: false, foreign_key: true
      t.string :role # e.g. 'player', 'dm', etc.
      t.timestamps
    end

    # Optional: Add unique index on memberships so a player can't join the same campaign twice
    add_index :memberships, [:player_id, :campaign_id], unique: true
  end
end
