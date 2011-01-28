import dubious.*
import ext.*
import models.*
import utils.*
import java.util.ArrayList


class Distance
  def values
    vals = ArrayList.new
    vals.add("km")
    vals.add("mile")
    vals
  end
  
  def get_select
    sel = Element.select
    i = 0
    values.each { |val|
      sel.option(Integer.toString(i), val.toString)
      i+=1
    }
    sel.value(value.toString)
    sel.to_s
  end
  
  def value; returns Integer
    @value
  end
  
  def value=(val:Integer)
    @value = val
  end
  
  def initialize(val:Integer)  
    value = val
  end
end



/*
class Price
  def values
    vals = ArrayList.new
    vals.add("USD")
    vals.add("EUR")
    vals.add("Kč")
    vals
  end
  
  def get_select
    sel = Element.select
    i = 0
    values.each { |val|
      sel.option(Integer.toString(i), val.toString)
      i+=1
    }
    sel.value(value.toString)
    sel.to_s
  end
  
  def value; returns Integer
    @value
  end
  
  def value=(val:Integer)
    @value = val
  end
  
end
*/

/*
class  Unit
  
  def initialize(na:String,ratio:Double) 
    value = val
    unit = un
  end
  
  def value; returns Integer
    @value
  end
  
  def value=(val:Integer)
    @value = val
  end
  
  def unit; returns Integer
    @unit
  end
  
  def unit=(un:Integer)
    @unit = un
  end
end

*/

/*

class FuelCapacity < Unit


end

class Distance < Unit


end

class EnginePower < Unit


end

*/