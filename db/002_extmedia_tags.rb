class ExtmediaTags < ActiveRecord::Migration
  def self.up
    add_column :extmedia_flickr_set_galleries, :tags, :string
  end
  
  def self.down
    remove_column :extmedia_flickr_set_galleries, :tags
  end
end
    
    
