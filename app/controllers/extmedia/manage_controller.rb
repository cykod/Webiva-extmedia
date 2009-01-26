

class Extmedia::ManageController < ModuleController

  permit 'extmedia_edit or extmedia_create'

  component_info :extmedia
  
  cms_admin_paths "content",
                  "Content" =>   { :controller => '/content' }
                   

   include ActiveTable::Controller   
   active_table :flickr_table,
                ExtmediaFlickrSetGallery,
                [ ActiveTable::IconHeader.new('', :width=>10),
                  ActiveTable::StringHeader.new('title'),
                  ActiveTable::DateHeader.new('posted_on'),
                  ActiveTable::BooleanHeader.new('display')
                ]
                

  def display_flickr_table(display = true)
    @flickr_set_id = params[:path][0]
    
   active_table_action('gallery') do |act,gallery_ids|
    case act
      when 'delete':
        ExtmediaFlickrSetGallery.destroy(gallery_ids)
      end
   end
    
    @active_table_output = flickr_table_generate params, :order => 'posted_on DESC, id DESC', :conditions => ['extmedia_flickr_set_id = ?',@flickr_set_id ]
    
    render :partial => 'flickr_table' if display
  end
  

  def flickr
     @flickr = ExtmediaFlickrSet.find_by_id(params[:path][0])
     return redirect_to(:controller => '/content') unless @flickr
     cms_page_path [ "Content" ], [ "'%s' Flickr Gallery Set",nil,@flickr.name ]
     display_flickr_table(false)
  end
  
  def delete_flickr_set
     @flickr = ExtmediaFlickrSet.find_by_id(params[:path][0])
     return redirect_to(:controller => '/content') unless @flickr
     
     cms_page_path [ "Content", [ "'%s' Flickr Gallery Set",url_for(:action => 'flickr', :path => @flickr.id),@flickr.name ] ], 'Confirm Delete'
     
     if request.post? && params[:delete]
      @flickr.destroy 
      flash[:notice] = 'Deleted the "%s" Flickr Gallery Set' / @flickr.name
      redirect_to(:controller => '/content')
     end
  
  end
  
  def flickr_gallery
     @flickr = ExtmediaFlickrSet.find_by_id(params[:path][0])
     return redirect_to(:controller => '/content') unless @flickr
     
     @gallery = @flickr.galleries.find_by_id(params[:path][1]) || @flickr.galleries.build() if @flickr
     
     if request.post? && params[:gallery]
      if(@gallery.update_attributes(params[:gallery]))
        redirect_to :action => 'flickr', :path => @flickr.id
        return
      end
     end
     
     cms_page_path [ "Content",[ "'%s' Flickr Gallery Set",url_for(:action => 'flickr', :path => @flickr.id),@flickr.name ] ],
                   @gallery.id ? 'Edit Gallery' : 'Add Gallery'
  
  end
  
   active_table :youtube_table,
                ExtmediaYoutubeGalleryVideo,
                [ ActiveTable::IconHeader.new('', :width=>10),
                  ActiveTable::StaticHeader.new('Thumbnail'),
                  ActiveTable::StringHeader.new('title'),
                  ActiveTable::DateHeader.new('posted_on'),
                  ActiveTable::BooleanHeader.new('display')
                ]
                  
  
  
  def display_youtube_table(display = true)
    @youtube_gallery_id = params[:path][0]
    
   active_table_action('video') do |act,video_ids|
    case act
      when 'delete':
        ExtmediaYoutubeGalleryVideo.destroy(video_ids)
      end
   end
    
    @active_table_output = youtube_table_generate params, :order => 'posted_on DESC',:conditions => ['extmedia_youtube_gallery_id=?',@youtube_gallery_id]
    
    render :partial => 'youtube_table' if display
  end
  

  def youtube
     @youtube = ExtmediaYoutubeGallery.find_by_id(params[:path][0])
     return redirect_to(:controller => '/content') unless @youtube
     cms_page_path [ "Content" ], [ "'%s' Youtube Video Gallery",nil,@youtube.name ]
    
     display_youtube_table(false)
  end
  
  def youtube_video
     @youtube = ExtmediaYoutubeGallery.find_by_id(params[:path][0])
     return redirect_to(:controller => '/content') unless @youtube
     
     @video = @youtube.videos.find_by_id(params[:path][1]) || @youtube.videos.build()
     
     if request.post? && params[:video]
      if(@video.update_attributes(params[:video]))
        redirect_to :action => 'youtube', :path => @youtube.id
        return
      end
     end
     
     cms_page_path [ "Content", [ "'%s' Youtube Video Gallery",url_for(:action => 'youtube',:path => @youtube.id),@youtube.name ] ],
                   @video.id ? 'Edit Video' : 'Add Video' 
  
  end
  
  def delete_youtube_gallery
    @youtube = ExtmediaYoutubeGallery.find_by_id(params[:path][0])
     return redirect_to(:controller => '/content') unless @youtube
     
     cms_page_path [ "Content", [ "'%s' YouTube Gallery",url_for(:action => 'youtube', :path => @youtube.id),@youtube.name ] ], 'Confirm Delete'
     
     if request.post? && params[:delete]
      @youtube.destroy 
      flash[:notice] = 'Deleted the "%s" YouTube Gallery' / @youtube.name
      redirect_to(:controller => '/content')
     end
  
  
  end  
  
end
  
