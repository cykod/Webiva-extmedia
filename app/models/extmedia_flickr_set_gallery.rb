
class ExtmediaFlickrSetGallery < DomainModel

  belongs_to :extmeida_flickr_set
  
  validates_presence_of :title
  
end
