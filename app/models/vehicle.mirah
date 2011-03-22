import com.google.appengine.ext.mirah.db.*
import com.google.appengine.api.datastore.*;
import dubious.*
import ext.*


class Vehicle < Model
  property :user_id,    Integer
  
  /* basic */
  property :type_id,    Integer
  property :maker_id,    Integer
  property :model_id,    Integer
  property :model_exact, String
  
  property :fuel_type_id,    Integer
  property :fuel_unit,    String
  property :year,    String
  
  property :engine_power,  Double
  property :engine_power_unit,    String
  
 
  /* optional  */
  property :odometer, Integer
  property :odometer_unit, String
  property :tank_capacity, Double
  property :license_number, String
  
  property :note, String
  property :deleted, Boolean
  
  def id
    key.getId
  end
  
  def type 
    if type_id > 0
      VehicleType.get(type_id)
    else
      VehicleType.new
    end
  end

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

  def fuel_type 
    if fuel_type_id > 0
      FuelType.get(fuel_type_id)
    else
      FuelType.new
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
      #{type_id} #{maker_id}
    HTML
  end
  
  def self.blank
    v = new
    v.type_id = 0    
    v.maker_id = 0
    v.model_id = 0
    v.model_exact = ''
    v.fuel_type_id = 0
    v.fuel_unit = ''
    v.year = ''
    v.engine_power = 0
    v.engine_power_unit = ''
    v.odometer = 0
    v.tank_capacity = 0
    v.license_number = ''
    v.note = ''
    v
  end
  
end