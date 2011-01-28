import com.google.appengine.ext.mirah.db.*
import com.google.appengine.api.datastore.*;
import dubious.*
import ext.*


class Fueling < Model
  property :vehicle_id,    Integer
  
  /* basic */
  property :date, Integer
  property :type,    String
  property :odometer,  Integer
  
  property :quantity,   Double
  property :fuel_unit, String
  
  property :quantity_main,   Double
  property :fuel_unit_main, String  
  
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
    fe = new
    fe.date = 0
    fe.type = ''
    fe.odometer = 0
    fe.quantity = 0
    fe.fuel_unit = ''
    fe.price = 0
    fe.price_currency = ''
    fe.note = ''
    fe
  end
end