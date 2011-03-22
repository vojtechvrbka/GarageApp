import com.google.appengine.ext.mirah.db.*
import com.google.appengine.api.datastore.*;
import dubious.*
import ext.*
import java.util.*


class Note < Model
  property :user_id,    Integer
  property :vehicle_id,    Integer
  
  /* basic */
  property :date, Integer
  property :type,    String
  property :odometer,  Integer
  
  property :price,    Double
  property :price_currency,    String
  
  property :note,    String

  
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
    n = new
    n.user_id = 0
    n.vehicle_id = 0
    n.date = Date.new.getTime()
    n.type = ""
    n.odometer = 0
    n.price = 0
    n.note = ""
    n
  end
end