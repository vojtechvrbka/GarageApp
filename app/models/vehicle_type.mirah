import com.google.appengine.ext.mirah.db.*
import com.google.appengine.api.datastore.*;
import dubious.*
import ext.*


class VehicleType < Model
  property :name,    String
  
  def id 
    key.getId
  end
  
  def url_id    
    if key != null
      String.valueOf(key.getId)
    else
      'new'
    end
  end
  
  def self.blank
    v = new
    v.name = ''
    v
  end
end