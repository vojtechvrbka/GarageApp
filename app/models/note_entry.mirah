import com.google.appengine.ext.duby.db.Model;
import com.google.appengine.api.datastore.*;
import dubious.*
import ext.*


class NoteEntry < Model
  property :user_id,    Integer
  property :vehicle_id,    Integer
  
  /* basic */
  property :date, Integer
  property :type,    String
  property :odometer,  Integer
  
  property :quantity,   Double
  property :fuel_sort, String
  
  property :price,    Double
  property :price_currency,    String
  
  property :note,    String

  
  def id 
    key.getId
  end
  
end