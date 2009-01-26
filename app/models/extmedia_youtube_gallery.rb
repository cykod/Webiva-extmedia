
class ExtmediaYoutubeGallery < DomainModel
  
  validates_presence_of :name
  
  has_many :videos, :class_name => 'ExtmediaYoutubeGalleryVideo'



end
