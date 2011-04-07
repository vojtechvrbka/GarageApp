import com.google.appengine.ext.mirah.db.*
import com.google.appengine.api.datastore.*;
import dubious.*
import ext.*
import java.util.*

class Fueling < Model
  property :user_id,    Integer
  property :vehicle_id,    Integer
  
  /* basic */
  property :date, Integer
  property :type,   Integer
  
  property :fueling_type, Integer
  property :cost_type, Integer
  
  
  property :odometer,  Integer
  property :trip, Integer
  
  property :fuelsort, Integer
  
  property :quantity,   Double
  property :quantity_unit, String
  
  property :quantity_main,   Double
  property :fuel_unit_main, String  
  
  property :price,    Double
  property :price_currency,    String
 
  property :note,    String
  
  property :tires,    Integer
  property :driving,    Integer
  property :route_motorway,    Integer
  property :route_city,    Integer
  property :route_country_roads,    Integer
  property :ac,    Integer
  property :trailer,    Integer
  

  
  def id 
    key.getId
  end

  def day
    TimeHelper.at(date).day_of_epoch
  end
  
  def month
    TimeHelper.at(date).month_of_epoch
  end
  
  def cost
    if type == Fueling.TYPE_FUELING
      long(Fueling.COST_FUELING)
    else
      cost_type
    end
  end
  
  
  
  def self.TYPE_FUELING ; 1 ;end
  def self.TYPE_COST    ; 2 ;end
  
  def self.FUELING_TYPE_FULL        ; 11 ;end
  def self.FUELING_TYPE_PARTLY_FULL ; 12 ;end    
  def self.FUELING_TYPE_FIRST       ; 13 ;end    
  def self.FUELING_TYPE_INVALID     ; 14 ;end    
      
  
  def self.TIRES_SUMMER   ; 21 ;end
  def self.TIRES_WINTER   ; 22 ;end
  def self.TIRES_ALL_YEAR ; 23 ;end

  def self.DRIVING_MODERATE ; 31 ;end
  def self.DRIVING_NORMAL   ; 32 ;end
  def self.DRIVING_FAST     ; 33 ;end
        



  # cost types
  def self.COST_FUELING        ; 100 ;end
  def self.COST_MAINTENANCE    ; 101 ;end
  def self.COST_REPAIR         ; 102 ;end
  def self.COST_CHANGE_TIRES   ; 103 ;end
  def self.COST_CHANGE_OIL     ; 104 ;end
  def self.COST_INSURANCE      ; 105 ;end
  def self.COST_TAX            ; 106 ;end
  def self.COST_SUPERVISORY_BOARD ; 107 ;end
  def self.COST_TUNING         ; 108 ;end
  def self.COST_ACCESSORIES    ; 109 ;end
  def self.COST_MISCELLANEOUS  ; 110 ;end
  def self.COST_CARE           ; 111 ;end
  def self.COST_PAYMENT        ; 112 ;end
  def self.COST_REGISTRATION   ; 113 ;end
  def self.COST_FINANCING      ; 114 ;end
  def self.COST_REFUND         ; 115 ;end
  def self.COST_FINE           ; 116 ;end
  def self.COST_PARKING_TAX    ; 117 ;end
  def self.COST_TOLL           ; 118 ;end
  def self.COST_SPARE_PARTS    ; 119 ;end
  def self.COST_PURCHASE_PRICE ; 120 ;end
  
  def cost_type_title
    String(Fueling.cost_array.get(Long.new(cost_type)))    
  end
  
  def self.cost_array
    h = LinkedHashMap.new
    h.put(Long.new(Fueling.COST_MAINTENANCE),'Maintenance')
    h.put(Long.new(Fueling.COST_REPAIR), 'Repair')
    h.put(Long.new(Fueling.COST_CHANGE_TIRES), 'Change tires')
    h.put(Long.new(Fueling.COST_CHANGE_OIL), 'Change oil')
    h.put(Long.new(Fueling.COST_INSURANCE), 'Insurance')
    h.put(Long.new(Fueling.COST_TAX), 'Tax')
    h.put(Long.new(Fueling.COST_SUPERVISORY_BOARD), 'Supervisory board')
    h.put(Long.new(Fueling.COST_TUNING), 'Tuning')
    h.put(Long.new(Fueling.COST_ACCESSORIES), 'Accessories')
    h.put(Long.new(Fueling.COST_MISCELLANEOUS), 'Miscellaneous')
    h.put(Long.new(Fueling.COST_CARE), 'Care')
    h.put(Long.new(Fueling.COST_PAYMENT), 'Payment')
    h.put(Long.new(Fueling.COST_REGISTRATION), 'Registration')
    h.put(Long.new(Fueling.COST_FINANCING), 'Financing')
    h.put(Long.new(Fueling.COST_REFUND), 'Refund')
    h.put(Long.new(Fueling.COST_FINE), 'Fine')
    h.put(Long.new(Fueling.COST_PARKING_TAX), 'Parking tax')
    h.put(Long.new(Fueling.COST_TOLL), 'Toll')
    h.put(Long.new(Fueling.COST_SPARE_PARTS), 'Spare parts')
    h.put(Long.new(Fueling.COST_PURCHASE_PRICE), 'Purchase price')
    h
  end


  def self.all_cost_array
    h = Fueling.cost_array
    h.put(Long.new(Fueling.COST_FUELING), 'Fueling')
    h.put(Long.new(0), 'unknown')
    h
  end

  def fuelsort_title
    #tank
  /*  
    1 - Diesel
    2 - Gasoline
    3 - LPG
    4 - CNG
    5 - Electricity
    
    
    # 1 diesel
    2 - Biodiesel
    1 - Diesel
    4 - Premium Diesel
    3 - Vegetable oil

    # 2 Gasoline
    15 Bio-alcohol
    20 E10
    6 Normal gasoline
    9 Premium Gasoline 100
    18 Premium Gasoline 95
    8 SuperPlus gasoline
    7 Super gasoline
    16 Two-stroke

    # 3 LPG
    12 LPG

    # 4 CNG
    13 CNG H
    14 CNG L

    # 5 Electricity
    19 Electricity
*/
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
    fe.date = Date.new.getTime()
    fe.type = Fueling.TYPE_FUELING
    fe.odometer = 0
    fe.quantity = 0
#    fe.fuel_unit = ''
    fe.price = 0
    fe.price_currency = ''
    fe.note = ''
    fe
  end
end