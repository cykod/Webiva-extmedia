class ExtmediaYoutubeAddedFields < ActiveRecord::Migration
  def self.up
    add_column :extmedia_youtube_gallery_videos, :category, :string
    add_column :extmedia_youtube_gallery_videos, :thumbnail_file_id, :integer
  end
  
  def self.down
    remove_column :extmedia_youtube_gallery_videos, :category
    remove_column :extmedia_youtube_gallery_videos, :thumbnail_file_id
  end
end
    
    
