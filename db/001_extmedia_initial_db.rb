class ExtmediaInitialDb < ActiveRecord::Migration
  def self.up
    create_table :extmedia_youtube_galleries do |t|
      t.string :name
    end
    
    create_table :extmedia_youtube_gallery_videos do |t|
      t.integer :extmedia_youtube_gallery_id
      t.date :posted_on
      t.string :title
      t.string :image_url 
      t.string :video_id
      t.boolean :display, :default => true
      t.text :description
      t.string :video_link
      t.string :uri
    end
    
    create_table :extmedia_flickr_sets do |t|
      t.string :name
      t.string :user_id
    end
    
    create_table :extmedia_flickr_set_galleries do |t|
      t.integer :extmedia_flickr_set_id
      t.date :posted_on
      t.string :title
      t.string :image_url
      t.string :gallery_id
      t.boolean :display, :default => true
    end
  end
  
  def self.down
    drop_table :extmedia_youtube_galleries
    drop_table :extmedia_youtube_gallery_videos
    drop_table :extmedia_flickr_sets
    drop_table :extmedia_flickr_set_galleries
  end
end
    
    
