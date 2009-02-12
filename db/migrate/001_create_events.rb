class CreateEvents < ActiveRecord::Migration 
  def self.up
    create_table :call_events, :force => true do |t|
      t.string  "name"
      t.string  "appdata"
      t.string  "application"
      t.string  "callerid"
      t.string  "calleridnum"
      t.string  "calleridname"
      t.string  "cause"
      t.string  "cause-txt"
      t.string  "channel"
      t.string  "context"
      t.string  "extension"
      t.string  "priority"
      t.string  "privilege"
      t.string  "state"
      t.string  "uniqueid"
      t.string  "userevent"
      t.timestamps
    end
  
    create_table :asterisk_events, :force => true do |t|
      t.string  "name"
      t.string  "channel"
      t.string  "message"
      t.string  "peer_count"
      t.string  "privilege"
      t.string  "registry_count"
      t.string  "reloadreason"
      t.string  "shutdown"
      t.string  "user_count"
      t.timestamps
    end
  end
  
  def self.down
    drop_table :call_events
    drop_table :asterisk_events
  end
end