
class ExtmediaFlickrSet < DomainModel

  validates_presence_of :name

  has_many :galleries, :class_name => 'ExtmediaFlickrSetGallery'
  
end
