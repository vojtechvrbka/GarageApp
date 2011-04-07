import java.util.*
import java.lang.reflect.*
import java.lang.reflect.Method

class ArrayHelper

  def self.inspect(l:List)
    unless l
      "List(nil)"
    else
      '['+join(l, ',')+']'
    end
  end
  
  def self.inspect(h:Map)
    unless h
      "Map(nil)"
    else
      inspected = ''
      h.keys.each { |k|
        v = List(h.get(k))
        inspected += "\n  #{k} => ["+join(v, ',')+"]"
      }
      "{#{inspected}\n}"
    end
  end
  
  def self.join(strings:List, delimiter:String):String
    buffer = StringBuffer.new
    iter = strings.iterator
    while iter.hasNext
      buffer.append(String.valueOf(iter.next))
      if iter.hasNext
        buffer.append(delimiter)
      end
    end
    return buffer.toString
  end
/*
  def self.sort(items:List)
     if items == null || (items.size == 0)
        return
      end
      Collections.sort(items)
  end
*/
  def self.sort(items:List, attribute:String)
    sort(items, attribute, false)
  end
  
  def self.sort(items:List, attribute:String, desc:boolean):void
    # puts "size: #{items.size}"
    if items == null || (items.size == 0)
      return
    end
    Collections.sort(items, Comparator(SortByAttribute.create(items.get(0), attribute, desc)))
  end
  
  
  def self.group(items:List, attribute:String)
    map = LinkedHashMap.new
    if items.size == 0
      return map
    end
    method = items.get(0).getClass.getMethod(attribute, null)      
    items.each { |item|
      key = method.invoke(item, null)
      unless list = List(map.get(key))
        map.put(key, list = ArrayList.new)
      #  puts key
      end
      list.add(item)
    }
    map
  end
  
  class SortByAttribute
    implements Comparator
  
    def initialize(m:Method)
      @method = m
    end
    
    def method
      @method
    end
  
    def self.create(object:Object, attribute:string, desc:boolean):Comparator
      oclass = object.getClass
      method = oclass.getMethod(attribute, null)
      
      type = method.getReturnType
      
      stringtype = type.getName.equals('string') || type.getName.equals('java.lang.String')
      
      if stringtype && !desc
        return SortByStringAttributeAsc.new(method)
      end
      if stringtype && desc
        return SortByStringAttributeDesc.new(method)
      end
      
      inttype = type.getName.equals('int') || type.getName.equals('java.lang.Integer')
      
      if inttype && !desc
        return SortByIntegerAttributeAsc.new(method)
      end
      if inttype && desc
        return SortByIntegerAttributeDesc.new(method)
      end
      
      longtype = type.getName.equals('long') || type.getName.equals('java.lang.Long')
      if longtype && !desc
        return SortByLongAttributeAsc.new(method)
      end
      if longtype && desc
        return SortByLongAttributeDesc.new(method)
      end
      
      
      
      raise "I don\' know how to compare type #{type}."
      Comparator(nil)
    end
    
    class SortByStringAttributeAsc < SortByAttribute
      def initialize(m:Method); super(m); end
      def compare(a:Object, b:Object):int
        attr_a = String(method.invoke(a, null))
        attr_b = String(method.invoke(b, null))
        attr_a.compareTo(attr_b)
      end
    end
    
    class SortByStringAttributeDesc < SortByAttribute
      def initialize(m:Method); super(m); end
      def compare(a:Object, b:Object):int
        attr_a = String(method.invoke(a, null))
        attr_b = String(method.invoke(b, null))
        attr_b.compareTo(attr_a)
      end
    end
    
    class SortByIntegerAttributeAsc < SortByAttribute
      def initialize(m:Method); super(m); end
      def compare(a:Object, b:Object):int
        attr_a = Integer(method.invoke(a, null))
        attr_b = Integer(method.invoke(b, null))
        attr_a.compareTo(attr_b)
      end
    end
        
    class SortByIntegerAttributeDesc < SortByAttribute
      def initialize(m:Method); super(m); end
      def compare(a:Object, b:Object):int
        attr_a = Integer(method.invoke(a, null))
        attr_b = Integer(method.invoke(b, null))
        attr_b.compareTo(attr_a)
      end
    end
    
    class SortByLongAttributeAsc < SortByAttribute
      def initialize(m:Method); super(m); end
      def compare(a:Object, b:Object):int
        attr_a = Long(method.invoke(a, null))
        attr_b = Long(method.invoke(b, null))
        attr_b.compareTo(attr_a)
      end
    end
    
    class SortByLongAttributeDesc < SortByAttribute
      def initialize(m:Method); super(m); end
      def compare(a:Object, b:Object):int
        attr_a = Long(method.invoke(a, null))
        attr_b = Long(method.invoke(b, null))
        attr_b.compareTo(attr_a)
      end
    end
    
  end
end