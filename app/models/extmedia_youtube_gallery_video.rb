require 'hpricot'

class ExtmediaYoutubeGalleryVideo < DomainModel

  def self.video_regexp
    /^https?\:\/\/(((www|)\.youtube\.com\/watch\?v\=)|(youtu\.be\/))(.*)$/i
  end


  belongs_to :extmedia_youtube_gallery
  belongs_to :thumbnail_file, :foreign_key => 'thumbnail_file_id', :class_name => 'DomainFile'
  
  validates_format_of :video_link, :with => ExtmediaYoutubeGalleryVideo.video_regexp,
                      :message => 'is not a valid youtube link'
  
  attr_accessor :autoplay

  
  def youtube_rss(video_id)
    "http://gdata.youtube.com/feeds/api/videos/#{video_id}"
  end
  
  def validate
    video_id = video_link.gsub(ExtmediaYoutubeGalleryVideo.video_regexp,'\5').to_s.strip
    begin
      vid_url = URI.parse(youtube_rss(video_id))
      res = Net::HTTP.get(vid_url)
      doc =  Hpricot::XML(res)
      vid = doc.at('entry')

      if vid
        self.title = doc.at('media:title').inner_html if self.title.blank?
        self.image_url = doc.at('media:thumbnail').attributes['url'] if self.image_url.blank?
        self.video_id = video_id
        self.description = doc.at('media:description').inner_html if self.description.blank?
      else 
        self.errors.add(:video_link,' is not returning a valid video, please verify URL and YouTube Configuration')
      end
    rescue Exception => e
        self.errors.add(:video_link,' is not returning a valid video, please verify URL includes http:// and YouTube Configuration')
    end
    
  end
  
  # Leave width and height nil for now - used in single youtube player
  # ToDo - let the video have individual widths
  def width; nil; end
  def height; nil; end
end
