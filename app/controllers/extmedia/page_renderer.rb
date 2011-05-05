class Extmedia::PageRenderer < ParagraphRenderer
  module_renderer
  
  
  paragraph :youtube_gallery
  paragraph :flickr_set
  paragraph :youtube_video
  paragraph :share_links, :cache => true
  
  feature :youtube_gallery, :default_feature => <<-EOF
    <div id='youtube_gallery'>
      <table>
        <td valign='top'>
            <cms:player/><br/>
            <cms:fullscreen/> <cms:links/><br/><br/>
            Description:<br/>
            <cms:description/>
        </td>
        <td valign='top'>
            <cms:video>
              <div>
                <cms:img width='90' align='left'/><cms:title/>
              </div>
              <div style='clear:both;'></div>
              <hr/>
            </cms:video>
        </td>
      </table>
    </div>
  EOF
  
  @@social_network_links = [ [  "Share this on facebook", "http://www.facebook.com/share.php?u=","facebook_icon.gif",'facebook'],
                             [  "Bookmark this on del.icio.us", "http://del.icio.us/post?v=2&url=","delicious.png", 'delicious'],
                             [  "digg It!", "http://digg.com/submit?phase=2&url=", "digg.png", 'digg'],
                             [  "Reddit","http://reddit.com/submit?url=","reddit.gif",'reddit'],
                             [  "Simpy","http://www.simpy.com/simpy/LinkAdd.do?title=","simpy_trans.gif",'simpy'],
                             [  "Yahoo","http://myweb2.search.yahoo.com/myresults/bookmarklet?t=","yahoo.png",'yahoo'],
                             [  "Furl","http://www.furl.net/storeIt.jsp?u=", "furl.gif",'furl'],
                             [  "Add to bookmarks in Google","http://www.google.com/bookmarks/mark?op=add&bkmk=","google.png",'google'] ]
                             
  cattr_reader :social_network_links 
  
  def self.social_network_link_options
    @@social_network_links.collect { |elm| [ elm[0],elm[3] ] }
  end
  
                          
  # Extraction of play tag for use in standalone youtube paragraph                 
  def define_youtube_player_tag(c,data)
    c.define_tag 'player' do |tag|
        width=(tag.attr['width']||(data[:video].width.to_i > 0 ? data[:video].width.to_i : nil)||400).to_i
        height=(tag.attr['height']||(data[:video].height.to_i > 0 ? data[:video].height.to_i : nil)||300).to_i
        color=tag.attr['bg'] || "#FFFFFF"
        if !editor?
          if data[:video].thumbnail_file_id && !tag.attr['no_thumb']
            thumbnail_file = DomainFile.find_by_id(data[:video].thumbnail_file_id)
            img_src = "<a href='javascript:void(0);' onclick='writeVideoPlayer#{paragraph.id}();'><img src='#{thumbnail_file.url}' width='#{width}' height='#{height}'/></a>"
            autoplay='1'
          else
            autoplay='0'
          end
          autoplay='1' if data[:video].autoplay
            
          <<-PLAYER_CODE
          <div id='video_player_#{paragraph.id}' style='width:#{width}px;height:#{height}px;'>#{img_src}</div>
          <script type="text/javascript">
            function writeVideoPlayer#{paragraph.id}() {
              swfobject.embedSWF("http#{"s" if request.ssl?}://www.youtube.com/v/#{data[:video].video_id}&rel=0&autoplay=#{autoplay}","video_player_#{paragraph.id}","#{width}","#{height}","8","",
                                  { playerMode: "embedded" },
                                  { wmode: "transparent", bgcolor: "#{color}" });
             }
             #{"writeVideoPlayer#{paragraph.id}();" if tag.attr['no_thumb'] || !thumbnail_file}
          </script>
          PLAYER_CODE
        else
          "<div id='video_player_#{paragraph.id}' style='width:#{width}px;height:#{height}px;'></div>"
        end
      end  
  end
  
  def youtube_gallery_feature(data)
    webiva_feature('youtube_gallery') do |c|    
      define_youtube_player_tag(c,data)
      
      c.define_tag 'fullscreen' do |tag|
        <<-EOT
          <img border="0" src="/components/extmedia/images/openinpopup.png" onClick="SCMS.openWindow('http://www.youtube.com/v/#{data[:video].video_id}&rel=0');" align='absmiddle' style="cursor: pointer;"/> 
        EOT
      end
      
      c.define_tag 'links' do |tag|
        services = tag.attr['services'] ? tag.attr['services'].explode(',').collect { |svc| svc.trim } : nil
        if tag.single?
          image_path = '/components/extmedia/images/icons/'
          escaped_page_path =  CGI.escape(Configuration.domain_link(request.request_uri))
          @@social_network_links.collect { |link|
            if !services || services.include?(link[3])
              "<a href='#{link[1]}#{escaped_page_path}' title='#{vh link[0]}'><img border='0' src='#{image_path}#{link[2]}' alt='#{vh link[0]}' align='absmiddle'/></a>"
            else
              ""
            end
          }.join(" ")
        else
          c.each_local_value(@@social_network_links,tag) do |lnk,tg|
            (!services || services.include?(link[3])) ? tg.expand : nil
          end
        end
      end
      
      c.define_position_tags 'links'
      
      c.define_tag 'links:link' do |tag|
          escaped_page_path =  CGI.escape(Configuration.domain_link(request.request_uri))
          image_path = '/components/extmedia/images/icons/'
          link = tag.locals.value
          "<a href='#{link[1]}#{escaped_page_path}' title='#{h link[0]}'><img border='0' src='#{image_path}#{link[2]}' alt='#{h link[0]}' align='absmiddle'/></a>"
      end
      
      c.define_tag 'video' do |tag|
        c.each_local_value(data[:videos],tag,'video')
      end
      
      c.define_position_tags('video')
      
      c.define_tag('video:img') do |tag|
        width = "width='#{tag.attr['width']}'" if tag.attr['width']
        height  = "height='#{tag.attr['height']}'" if tag.attr['height']
        "<a href='#{data[:page_path]}?video_id=#{tag.locals.video.id}'><img #{width} #{height} src='#{tag.locals.video.image_url}' border='0' /></a>"
      end
      
      c.define_tag('video:href') do |tag|
        " href='#{data[:page_path]}?video_id=#{tag.locals.video.id}' "
      end
      
      c.define_tag 'video:title' do |tag|
        tag.locals.video.title
      end

      c.value_tag 'video:video_url' do |t|
        t.locals.video.video_link
      end
      
      c.define_tag 'video:description' do |tag|
        tag.locals.video.description
      end

      c.define_value_tag 'description' do |tag|
        data[:video].description
      end
      
      c.define_value_tag 'title' do |tag|
        data[:video].title
      end
    end
  end
  

  def youtube_gallery 
    options = Extmedia::PageController::YoutubeGalleryOptions.new(paragraph.data)
    
    
    require_js('user_application.js');
    
    @gallery= ExtmediaYoutubeGallery.find_by_id(options.youtube_gallery_id) 
    if @gallery
      @video = params[:video_id] ? @gallery.videos.find_by_id_and_display(params[:video_id],1) : nil
      conditions = ['display=1']
      if !options.category.blank?
        conditions[0] += " AND category=?"
        conditions << options.category
      end
      @video ||= @gallery.videos.find(:first,:order => 'posted_on DESC, id DESC', :conditions => conditions)
      videos = @gallery.videos.find(:all,:order => 'posted_on DESC, id DESC', :conditions => conditions, :limit => options.max_videos.to_i > 0 ? options.max_videos.to_i : nil)
      if @video
      
        href_path = options.detail_page_id.to_i > 0 ? SiteNode.get_node_path(options.detail_page_id) : page_path
        
        data = { :video => @video,:videos => videos, :page_path => href_path}
        feature_output = youtube_gallery_feature(data)
        render_paragraph :text => feature_output
      else
        render_paragraph :nothing => true
      end
    else
      render_paragraph :text => 'Configure Paragraph'
    end
  end
  
  
  feature :flickr_set, :default_feature => <<-FEATURE
    <table>
    <tr>
      <td valign='top'>
        <cms:slideshow width='460' height='460'/>
      </td>
      <td valign='top'>
        <cms:gallery>
         <div class="flickr_gallery"> 
          <cms:img width='50' height='50'/>
          <a <cms:href/>><cms:title/></a>
        </div>
        </cms:gallery>
      </td>
    </tr>
    </table>
  FEATURE
  

  def flickr_set_feature(data)
    webiva_feature('flickr_set') do |c|    
      c.define_tag 'slideshow' do |tag|
        width = tag.attr['width']||460
        height = tag.attr['height']||460
        
        <<-EOT
        <iframe align=center src="http://www.flickr.com/slideShow/index.gne?user_id=#{data[:user_id]}&set_id=#{data[:gallery].gallery_id}" frameborder='0' width='#{width}' scrolling='no' height='#{height}'></iframe>
        EOT
      end
      
      c.define_tag 'gallery' do |tag|
        output = ''
        data[:galleries].each do |gallery|
          tag.locals.gallery = gallery
          output += tag.expand
        end
        output
      end
      
      c.define_tag 'gallery:href' do |tag|
        "href='#{data[:page_path]}?gallery_id=#{tag.locals.gallery.id}'"
      end
      
      c.define_tag('gallery:img') do |tag|
        width = "width='#{tag.attr['width']}'" if tag.attr['width']
        height  = "height='#{tag.attr['height']}'" if tag.attr['height']
        "<a href='#{data[:page_path]}?gallery_id=#{tag.locals.gallery.id}'><img #{width} #{height} src='#{tag.locals.gallery.image_url}' border='0' /></a>"
      end

      c.value_tag 'gallery:gallery_id' do |t|
        t.locals.gallery.gallery_id
      end

      c.define_tag 'gallery:title' do |tag|
        tag.locals.gallery.title
      end
    end
  end
    

  def flickr_set
    options = Extmedia::PageController::FlickrSetOptions.new(paragraph.data)
    
    
    require_js('user_application.js');
    
    @set= ExtmediaFlickrSet.find_by_id(options.flickr_set_id) 
    if @set
      @gallery = params[:gallery_id] ? @set.galleries.find_by_id_and_display(params[:gallery_id],1) : nil
      @gallery ||= @set.galleries.find(:first,:conditions => 'display=1',:order => 'posted_on DESC')
      @galleries = @set.galleries.find(:all,:conditions => 'display=1',:order => 'posted_on DESC')
      if @gallery 
        data = { :gallery => @gallery,:galleries => @galleries, :page_path => page_path}
        feature_output = flickr_set_feature(data)
        render_paragraph :text => feature_output
      else
        render_paragraph :nothing => true
      end
    else
      render_paragraph :text => 'Configure Paragraph'
    end
  end
  
  def youtube_video_feature(data)
    webiva_feature('youtube_video') do |c|

      define_youtube_player_tag(c,data)
          
      c.define_tag 'align' do |tag|
        data[:video].align || 'center'
      end 
    end
  end
  

  feature :youtube_video, :default_feature => <<-EOF
      <div class='youtube_video' align='<cms:align/>'>
        <cms:player/>
      </div>
    EOF
    
  def youtube_video
    options = Extmedia::PageController::YoutubeVideoOptions.new(paragraph.data)
    
    
    require_js('user_application.js');
    
    if !options.video_id.blank?
        data = { :video => options }
        feature_output = youtube_video_feature(data)
        render_paragraph :text => feature_output
    else
      render_paragraph :text => 'Configure Paragraph'
    end
  end
  
 
 feature :social_links, :default_feature => <<-EOF
  <cms:links><cms:link/>&nbsp;&nbsp;</cms:links>
 EOF
    
 def social_links_feature(data)
    webiva_feature('social_links') do |c|
      
      c.define_tag 'links' do |tag|
        services = tag.attr['services'] ? tag.attr['services'].explode(',').collect { |svc| svc.trim } : data[:services]
        if tag.single?
          image_path = '/components/extmedia/images/icons/'
          escaped_page_path =  data[:page]
          @@social_network_links.collect { |link|
            if !services || services.include?(link[3])
              "<a href='#{link[1]}#{escaped_page_path}' target='_blank' title='#{vh link[0]}'><img border='0' src='#{image_path}#{link[2]}' alt='#{vh link[0]}' align='absmiddle'/></a>"
            else
              ""
            end
          }.join(" ")
        else
          links = @@social_network_links.find_all { |elm| !services || services.include?(elm[3]) }
          c.each_local_value(links,tag)
        end
      end
      
      c.define_position_tags 'links'
      
      c.define_tag 'links:link' do |tag|
          escaped_page_path =  CGI.escape(Configuration.domain_link(request.request_uri))
          image_path = '/components/extmedia/images/icons/'
          link = tag.locals.value
          "<a href='#{link[1]}#{escaped_page_path}'  target='_blank'  title='#{h link[0]}'><img border='0' src='#{image_path}#{link[2]}' alt='#{h link[0]}' align='absmiddle'/></a>"
      end
    end
  end
  
  def share_links
    options = Extmedia::PageController::ShareLinksOptions.new(paragraph.data)
    data = { :services => options.networks, :page => CGI.escape(Configuration.domain_link(page_path))  } 
    render_paragraph :text => social_links_feature(data)
  end

end
