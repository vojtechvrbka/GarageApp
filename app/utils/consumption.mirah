import models.*


/*
class Consumption
  def self.by_vehicle(vehicle:long)
    fuelings = Fueling.all.vehicle_id(vehicle).sort(:date).run
    prev = Fueling.blank
    count = 0
    sum = 0.0
    fuelings.each do |f|
      if prev.odometer > 0    
        distance = f.odometer - prev.odometer
        sum += (f.quantity / distance) * 100  
        count += 1
      end
      prev = f
    end
    return (sum/count)
  end

end
*/