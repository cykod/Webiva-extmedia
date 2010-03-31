class Extmedia::AdminController < ModuleController


  component_info 'Extmedia', :description => 'External Media (Youtube,Flickr) Integration', 
                              :access => :public

  register_permission_category :extmedia, "External Media" ,"External Media Permissions"
  
  register_permissions :extmedia, [  [ :manage, 'Create','Create and Delete External Media Galleries and Sets'   ],
                                     [ :edit, 'Edit', 'Edit External Media Galleries and Sets' ],
                                     [ :config, 'Configure', 'Configure External Media Options' ] ]
  
  content_model :extmedia
  content_action  'Create a YouTube Gallery', { :controller => '/extmedia/admin', :action => 'youtube' }, :permit => 'extmedia_manage'
  content_action  'Create a Flickr Gallery Set', { :controller => '/extmedia/admin', :action => 'flickr' }, :permit => 'extmedia_manage'


 cms_admin_paths "content", 
                  "Content" =>   { :controller => '/content' },
                  "Options" => { :controller => "/options" },
                  "Modules" => { :controller => "/modules" } 
                              


   protected
 def self.get_extmedia_info
         ExtmediaFlickrSet.find(:all, :order => 'name').collect do |set| 
          {:name => set.name,:url => { :controller => '/extmedia/manage',:action =>  'flickr', :path => set.id } ,:permission => 'extmedia_edit', :icon => 'icons/content/photogallery.gif' }
      end +
        ExtmediaYoutubeGallery.find(:all, :order => 'name').collect do |gal|
          {:name => gal.name,:url => { :controller => '/extmedia/manage',:action =>  'youtube',:path => gal.id } ,:permission => 'extmedia_edit', :icon => 'icons/content/videos.gif' }
      end
  end

  public
  
#  def options
#    cms_page_path [ 'Options', 'Modules' ], 'External Media Options'
#  
#    @options = ExtmediaOptions.new(params[:options] || @mod.options)
#    
#    if request.post? && params[:options] && @options.valid?
#      @mod.update_attributes(:options => @options.to_h)
#      flash[:notice] = 'Updated External Media Options'.t
#      redirect_to :controller => '/modules'
#    end
#  
#  end
#  
#  class ExtmediaOptions < HashModel
#    default_options :youtube_developer_id => nil
#    
#  end
    
  
  def youtube
    @gallery = ExtmediaYoutubeGallery.find_by_id(params[:path][0]) || ExtmediaYoutubeGallery.new()
    
    cms_page_path [ 'Content' ], @gallery.id ? 'Edit YouTube Gallery' : 'Create YouTube Gallery'
    
    
    if request.post? && params[:gallery] && @gallery.update_attributes(params[:gallery])
        redirect_to :controller => '/extmedia/manage', :action => 'youtube', :path => @gallery
    end
  end
  
  
  def flickr 
    @flickr_set = ExtmediaFlickrSet.find_by_id(params[:path][0]) || ExtmediaFlickrSet.new()
    cms_page_path [ 'Content' ], @flickr_set.id ? 'Edit Flickr Set' : 'Create Flickr Set'
  
    
    if request.post? && params[:flickr_set] && @flickr_set.update_attributes(params[:flickr_set])
        redirect_to :controller => '/extmedia/manage', :action => 'flickr', :path => @flickr_set
    end
  end
  

end
