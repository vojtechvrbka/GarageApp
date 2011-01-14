import java.util.Calendar

class TimeHelper
  
  def self.now; new; end  
  def self.today; new; end
  

  def initialize
    @c = Calendar.getInstance()
  end
  
  def self.beginning_of_month
    now.month_day(1)
  end
  
  #def self.midnight; now.midnight; end
  def midnight
    @c.set(Calendar.HOUR_OF_DAY, 23)
    @c.set(Calendar.MINUTE, 59)
    @c.set(Calendar.SECOND, 59)
    @c.set(Calendar.MILLISECOND, 999)
    self
  end
  
  #def self.morning; now.morning; end
  def morning
    @c.set(Calendar.HOUR_OF_DAY, 0)
    @c.set(Calendar.MINUTE, 0)
    @c.set(Calendar.SECOND, 0)
    @c.set(Calendar.MILLISECOND, 0)
    self
  end
  
  def hours(h:int)
    @c.set(Calendar.HOUR_OF_DAY, h)
    self
  end
  
  def hours()
    @c.get(Calendar.HOUR_OF_DAY)
  end
  
  def hour(); hours; end  
  def hour(h:int); hours(h); end

  def minute; minutes; end  
  def minutes
    @c.get(Calendar.MINUTE)
  end

  def minute(i:int); minutes(i); end  
  def minutes(i:int)
    @c.set(Calendar.MINUTE, i)
    self
  end

  def second; seconds; end  
  def seconds
    @c.get(Calendar.SECOND)
  end

  def second(i:int); seconds(i); end  
  def seconds(i:int)
    @c.set(Calendar.SECOND, i)
    self
  end

  # month is 1-12
  def month
    @c.get(Calendar.MONTH)+1
  end
  
  # month is 1-12
  def month(month:int)
    @c.set(Calendar.MONTH, month-1)
    self
  end
  
  def next_month; next_month(1) end
  def next_month(months:int)
    shift_month(positive(months))
  end
  
  
  def last_month; last_month(1); end
  def last_month(months:int)
    shift_month(-positive(months))
  end
  
  def shift_month(months:int)
    @c.add(Calendar.MONTH, months)
    self
  end
  
  
  def month_day(day:int)
    @c.set(Calendar.DAY_OF_MONTH, positive_only(day))
    self
  end    
  
  def month_day
    @c.get(Calendar.DAY_OF_MONTH)
  end
  
  def year
    @c.get(Calendar.YEAR)
  end
  
  def week_day
    @c.get(Calendar.DAY_OF_WEEK)    
  end

  def self.tomorrow; now.next_day; end    
  def next_day; shift_day(1); end
  def next_day(days:int)
    shift_day(positive(days))
  end
  
  def self.yesterday; now.day_before; end  
  def day_before; shift_day(-1); end
  def day_before(days:int)
    shift_day(-positive(days))
  end  
  def prev_day; day_before; end
  def prev_day(days:int); day_before(days); end  
  
  def shift_day(days:int)
    @c.add(Calendar.DAY_OF_YEAR, days)
    self
  end
  
  def positive(number:int)
    if number < 0
      raise "This method accepts only zero or positive numbers (#{number} given)."
    end
    number
  end
  
  def positive_only(number:int)
    if number > 0
      number
    else
      raise "This method accepts only positive numbers (#{number} given)."
    end
  end

  def ms(ms:long)
    @c.setTimeInMillis(ms)
    self
  end
  
  def ms(ms:Long)
    @c.setTimeInMillis(ms.longValue())
    self
  end
  
  def ms
    @c.getTimeInMillis()
  end
  
  def self.at(ms:long)
    now.ms(ms)
  end
  
  def self.at(ms:Long)
    now.ms(ms)
  end
  
  def equals(other:TimeHelper)
    to_long.equals(other.to_long)
  end
  
  def clone; returns TimeHelper
    TimeHelper.at(ms)
  end
  
  def to_long
    Long.new(to_l)
  end
  
  def to_l
    @c.getTimeInMillis()
  end
  
  def to_int
    Integer.new(Long.new(to_l / 1000).intValue)
  end
  
  def to_i
    Long.new(to_l / 1000).intValue
  end
  
  def to_s
    @c.getTime().toString()
  end
  
  def toString
    to_s
  end
  
end
  