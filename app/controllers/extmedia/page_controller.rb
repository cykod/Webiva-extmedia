require 'hpricot'

class Extmedia::PageController < ParagraphController 


  editor_header "External Media Paragraphs"

  editor_for :youtube_gallery, :name => 'YouTube Gallery',  :features => ['youtube_gallery']
  editor_for :flickr_set, :name => 'Flickr Galleries Set', :features => ['flickr_set']
  editor_for :youtube_video, :name => 'YouTube Video', :features => ['youtube_video']
  
  editor_for :share_links, :name => 'Social Media Links', :features => [ 'social_links' ]
  
  def youtube_gallery

    @options = YoutubeGalleryOptions.new(params[:youtube_gallery] || @paragraph.data)
  
    return if handle_module_paragraph_update(@options)
    @galleries = [['--Select Gallery--'.t,nil]] + ExtmediaYoutubeGallery.find_select_options(:all,:order =>'name')
    @max_options = [['--Show All Videos--',0]] + (1..20).to_a.collect { |num| [num,num] }
    @pages = [['--Stay on same page--',0]] + SiteNode.page_options()
  end
  
  class YoutubeGalleryOptions < HashModel
    default_options :youtube_gallery_id => nil, :category => nil, :max_videos => 0, :detail_page_id => nil
    
    integer_options :youtube_gallery_id, :max_videos, :detail_page_id
    validates_numericality_of :youtube_gallery_id
  end
  
  
  def flickr_set
  
    @options = FlickrSetOptions.new(params[:flickr_set] || @paragraph.data)
  
    return if handle_module_paragraph_update(@options)
    @sets = [['--Select Set--'.t,nil]] +  ExtmediaFlickrSet.find_select_options(:all,:order =>'name')

  
  end
                                  
  class FlickrSetOptions < HashModel
    default_options :flickr_set_id => nil
    
    integer_options :flickr_set_id
    validates_numericality_of :flickr_set_id
    
  end
  
  def youtube_video
    @options = YoutubeVideoOptions.new(params[:youtube_video] || @paragraph.data)
    return if handle_module_paragraph_update(@options)
  end
  
  class YoutubeVideoOptions < HashModel
    default_options :title => nil,:image_url => nil,:video_id => nil,:description => nil,:video_link => nil,:url => nil,:thumbnail_file_id => nil, :width => 400, :height => 300, :align => 'center', :autoplay => false
    
    integer_options :thumbnail_file_id, :width, :height
    
    boolean_options :autoplay
    
    validates_format_of :video_link, :with => /^http\:\/\/(www|)\.youtube\.com\/watch\?v\=(.*)$/i,
                          :message => 'is not a valid youtube link'
      
    def youtube_rss(vid)
      "http://www.youtube.com/api2_rest?method=youtube.videos.get_details&dev_id=#{youtube_dev_id}&video_id=#{vid}"
    end
    
    def youtube_dev_id
      @mod = SiteModule.get_module('extmedia')
      @mod.options[:youtube_developer_id]
    end

    def validate
        vid_id = self.video_link.to_s.gsub(/^http\:\/\/(www|)\.youtube\.com\/watch\?v\=(.*)$/i,'\2').to_s.strip
        vid_url = URI.parse(youtube_rss(vid_id))
        res = Net::HTTP.get(vid_url)
        doc =  Hpricot::XML(res)
        vid = doc.at('video_details')
        
        if vid
          self.title = doc.at('title').inner_html if self.title.blank?
          self.image_url = doc.at('thumbnail_url').inner_html
          self.description = doc.at('description').inner_html if self.description.blank?
          self.video_id = vid_id
        else 
          self.errors.add(:video_link,' is not returning a valid video, please verify URL and YouTube Configuration')
        end
    end    
  end
  
  def share_links
    @options = ShareLinksOptions.new(params[:share_links] || @paragraph.data)
    return if handle_module_paragraph_update(@options)
  end
  
  class ShareLinksOptions < HashModel
    default_options :networks => [ 'delicious','digg','reddit','simpy','yahoo','furl','google' ]
  end
  

end
