import com.google.appengine.ext.mirah.db.*
import com.google.appengine.api.datastore.*;
import dubious.*
import ext.*


class Vehicle < Model
  property :user_id,    Integer
  
  /* basic */
  property :type,     Integer
  property :maker_id,    Integer
  property :model_id,    Integer
  property :model_exact, String
  
  property :fuel_type,    Integer
  property :gearing, Integer
  property :fuel_unit,    String
  property :year,    Integer
  
  property :engine_power,  Double
  
 
  /* optional  */
  # property :odometer, Integer
  property :odometer_unit, String
  property :tank_capacity, Double
  property :license_number, String
  
  property :note, String
  property :deleted, Boolean
  
  def id
    key.getId
  end
  
  def self.TYPE_AUTOMOBILE ; 1 ;end
  def self.TYPE_TWO_WHEELER ; 2 ;end
  def self.TYPE_COMMERCIAL ; 3 ;end
  def self.TYPE_QUAD ; 4 ;end

  
  def self.FUEL_DIESEL    ; 1 ;end
  def self.FUEL_GASOLINE  ; 2 ;end
  def self.FUEL_LPG       ; 3 ;end
  def self.FUEL_CNG       ; 4 ;end
  def self.FUEL_ELECTRICITY ; 5 ;end
  
  def self.GEARING_MANUAL ; 11 ;end
  def self.GEARING_AUTOMATIC ; 12 ;end
  
  def maker 
    if maker_id > 0
      VehicleMaker.get(maker_id)
    else
      VehicleMaker.new
    end
  end
  
  def model 
    if model_id > 0
      VehicleModel.get(model_id)
    else
      VehicleModel.new
    end
  end    
  
  def url_id    
    if key != null
      String.valueOf(key.getId)
    else
      'new'
    end
  end
  
  def title:String
    maker.name +" "+ model.name + " "+ model_exact
  end
  
  
  def to_string
    <<-HTML
     #{maker_id}
    HTML
  end
  
  def self.blank
    v = new
    v.maker_id = 0
    v.model_id = 0
    v.model_exact = ''
    v.fuel_type = 0
    v.fuel_unit = ''
    v.year = ''
    v.engine_power = 0.0
 #   v.odometer = 0
    v.tank_capacity = 0
    v.license_number = ''
    v.note = ''
    v
  end
  
end