require 'hpricot'

class ExtmediaYoutubeGalleryVideo < DomainModel

  belongs_to :extmedia_youtube_gallery
  belongs_to :thumbnail_file, :foreign_key => 'thumbnail_file_id', :class_name => 'DomainFile'
  
  validates_format_of :video_link, :with => /^http\:\/\/(www|)\.youtube\.com\/watch\?v\=(.*)$/i,
                      :message => 'is not a valid youtube link'
  
  def youtube_rss(video_id)
    "http://www.youtube.com/api2_rest?method=youtube.videos.get_details&dev_id=#{youtube_dev_id}&video_id=#{video_id}"
  end
  
  def youtube_dev_id
    @mod = SiteModule.get_module('extmedia')
    @mod.options[:youtube_developer_id]
  end

  def validate
      video_id = video_link.gsub(/^http\:\/\/(www|)\.youtube\.com\/watch\?v\=(.*)$/i,'\2').to_s.strip
      vid_url = URI.parse(youtube_rss(video_id))
      res = Net::HTTP.get(vid_url)
      doc =  Hpricot::XML(res)
      vid = doc.at('video_details')
      
      if vid
        self.title = doc.at('title').inner_html if self.title.blank?
        self.image_url = doc.at('thumbnail_url').inner_html
        self.video_id = video_id
        self.description = doc.at('description').inner_html if self.description.blank?
      else 
        self.errors.add(:video_link,' is not returning a valid video, please verify URL and YouTube Configuration')
      end
  
  end
  
  # Leave width and height nil for now - used in single youtube player
  # ToDo - let the video have individual widths
  def width; nil; end
  def height; nil; end
end
