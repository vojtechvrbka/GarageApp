import dubious.*
import ext.*
import models.*
import utils.*

import java.util.*

class  StatsController < PublicController
  
  
  def index
 
    if params.has? :vehicle
      @vehicle = Vehicle.get(Integer.parseInt(params[:vehicle]))
      null
    else
      @vehicle = Vehicle.all.user_id(user.id).deleted(false).first
      null
    end
 
#    @vehicle = Vehicle.all.user_id(user.id).deleted(false).first
    html = ""
    
 
    if @fuelings = Fueling.all.vehicle_id(@vehicle.id).sort(:date).run

    prev = Fueling.blank
    count = 0
    sum = 0.0
    min_time = long(0); max_time = long(0)
    first = true
    @fuelings.each do |f|

      if first # prvni zaznam
        min_time = f.date
        first = false
      end
      
      sum += (f.quantity / f.trip) * 100  
      count += 1
      null
            
      if min_time > f.date
        min_time = f.date
      end
      
      if max_time < f.date
        max_time = f.date
      end
      
      prev = f
    end
   
    th = TimeHelper.new
    
    # date select
    
    
    th.ms(min_time)
    
    from_year = th.year
    from_month = th.month
    
    th.ms(max_time)
    
    to_year = th.year
    to_month = th.month
    
    if params[:filter_from]
      filter_from = params[:filter_from]
      filter_from_month = Integer.parseInt(filter_from.split('/')[0])
      filter_from_year = Integer.parseInt(filter_from.split('/')[1])
    else
      filter_from =  Integer.toString(from_month)+"/"+Integer.toString(from_year)
      filter_from_month = from_month
      filter_from_year = from_year
    end
    
    year = from_year
    @date_select = ""
    while year <= to_year
      @date_select += "<optgroup label='#{year}'>"
      month = (year == from_year ? from_month : 1)
      while ( month <= 12 && year != to_year ) || ( month <= to_month && year == to_year )
        selected = ( filter_from.equals(Integer.toString(month)+"/"+Integer.toString(year) )) ? 'selected="selected"' : ''        
        month_title = TimeHelper.month_title(month)
        @date_select += "<option value='#{month}/#{year}' #{selected}>#{month_title} #{year-2000}</option>"
        month+=1
      end
      @date_select += "</optgroup>"
      year+=1
    end
   
   @date_select_from = '<select name="filter_from" id="valueA">'+ @date_select+'</select>'
   
   
   
   if params[:filter_to]
     filter_to = params[:filter_to]
     filter_to_month = Integer.parseInt(filter_to.split('/')[0])
     filter_to_year = Integer.parseInt(filter_to.split('/')[1])
   else
     filter_to =  Integer.toString(to_month)+"/"+Integer.toString(to_year)    
     filter_to_month = to_month
     filter_to_year = to_year
   end
   
   
   year = from_year
   @date_select = ""
   while year <= to_year
     @date_select += "<optgroup label='#{year}'>"
     month = (year == from_year ? from_month : 1)
     while  ( month <= 12 && year != to_year ) || ( month <= to_month && year == to_year )
       selected = ( filter_to.equals(Integer.toString(month)+"/"+Integer.toString(year)) ) ? 'selected="selected"' : ''
        month_title = TimeHelper.month_title(month)
       @date_select += "<option value='#{month}/#{year}' #{selected}>#{month_title} #{year-2000}</option>"
       month+=1
     end
     @date_select += "</optgroup>"
     year+=1
   end

   @date_select_to = '<select name="filter_to" id="valueB">'+ @date_select+'</select>'
        
    # prumer pro mesice
  
    @fuelings = Fueling.all.vehicle_id(@vehicle.id).type(Fueling.TYPE_FUELING).sort(:date).run
    fueling_list = ArrayList.new
    @fuelings.each{ |f| fueling_list.add(f)   }
    months = ArrayHelper.group(fueling_list, :month)
    @months_avg = LinkedHashMap.new
    @months_costs = LinkedHashMap.new
    
    month_price_sum = 0.0
    month_price_count = 0
    # keys = months.keys
   # ArrayHelper.sort(keys)
    from_epoch = TimeHelper.at_date(1,filter_from_month,filter_from_year).month_of_epoch
    to_epoch = TimeHelper.at_date(1,filter_to_month,filter_to_year).month_of_epoch
    months.keys.each do |k|
      if Integer(k).intValue >= from_epoch and Integer(k).intValue <= to_epoch
      sum=0.0; count=0;price = 0.0;
      ArrayList(months.get(k)).each do |it|
        if Fueling(it).type == Fueling.TYPE_FUELING and Fueling(it).fueling_type == Fueling.FUELING_TYPE_FULL
          count += 1
          sum += ( Fueling(it).quantity / Fueling(it).trip) * 100
        end
        price += Fueling(it).price
      end
   #   puts "x-#{k}"
      @months_avg.put(k ,Double.new(sum/count))
      @months_costs.put(k ,Double.new(price))
      
      month_price_sum+= price
      month_price_count+=1
    end
    end
    
    @month_price = month_price_sum / month_price_count
    @km_price = 0
    
    # th = TimeHelper.new
       #  
       # @fuelings.each do |f|
       #   if prev.odometer > 0    
       #     distance = f.odometer - prev.odometer
       #     avg =  (f.quantity / distance) * 100  
       #     th.ms(f.date)
       #     ArrayList(months.get(th.month-1)).add(Double.new(avg))
       #     @month_costs.set(th.month-1, Double.new(f.price*f.quantity +  Double(@month_costs.get(th.month-1)).doubleValue))  
       #   end
       #   prev = f
       # end
       #    
   
    
       chart_erb
    else
      "no fuelings"      
    end
   end
  
  def chart_erb
   
    rows = ""
    i=0
    @months_avg.keys.each do |k|
      it = @months_avg.get(k)

      month = TimeHelper.at_month_of_epoch(Integer(k)).month_print
      rows += "['#{month}',"+ Double.toString(double(int(Double(it).doubleValue*100))/100) + "],"
      i+=1
    end 
     
    rows2 = ""
    
    i=0
    @months_costs.keys.each do |k|
      it = @months_costs.get(k)
      month = TimeHelper.at_month_of_epoch(Integer(k)).month_print
      rows2 += "['#{month}',"+ Double.toString(double(int(Double(it).doubleValue*100))/100) + "],"
      i+=1
    end  
  
    
    
    <<-HTML
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
        <script type="text/javascript">
          google.load("visualization", "1", {packages:["corechart"]});
          google.setOnLoadCallback(drawChart);
          google.setOnLoadCallback(drawVehicleCostsChart);
          function drawChart() {
            var data = new google.visualization.DataTable();
          
            data.addColumn('string', 'Months');
            data.addColumn('number', 'Mine');
     
            data.addRows([
              #{rows}
            ]);

            var chart = new google.visualization.AreaChart(document.getElementById('chart_div'));
            chart.draw(data, {width: 800, height: 240, title: '',
                              hAxis: {title: 'Months', titleTextStyle: {color: '#FF0000'}},
                              vAxis: {title: 'l / 100 Km', titleTextStyle: {color: '#FF0000'}},
                              
                             });
          }
          function drawVehicleCostsChart() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Months');
            data.addColumn('number', '2010');
     
            data.addRows([
              #{rows2}
            ]);

            var chart = new google.visualization.AreaChart(document.getElementById('vehicle_costs'));
            chart.draw(data, {width: 800, height: 240, title: '',
                              hAxis: {title: 'Months', titleTextStyle: {color: '#FF0000'}},
                              vAxis: {title: 'Kč', titleTextStyle: {color: '#FF0000'}},
                              
                             });
          }
         
        	$(function(){
        			$('select').selectToUISlider({
        			  labels: 6
        			})
        	});  
        </script>
        

        <style type="text/css"> 
      		p { clear:both; }
      		fieldset { border:0; margin:0;}	
      		label {font-weight: normal; float: left; margin-right: .5em; font-size: 1.1em;}
      		select {margin-right: 1em; float: left;}
      		.ui-slider {clear: both; top: 20px; padding:0 10px 0 10px;}
      	</style> 

        <h1>#{@vehicle.title} stats</h1>
        
        <form action="" method="post" > 
        		<fieldset style="height:120px;"> 
        			<label for="valueA">Between</label> 
              #{@date_select_from}
        			<label for="valueB">and</label> 
              #{@date_select_to}
        		</fieldset>         		
        	  <input type="submit" name="submit" value="Filter">        		
        	</form>
      <h2>Basic</h2>    
        <strong>Price per month</strong> #{@month_price} EUR<br />
        <strong>Price per km</strong> #{@km_price} EUR <br />
        <br />
                
      <h2>Consumption</h2>    

      <div id="chart_div"></div>
      
      <h2>Vehicle costs</h2>
      <div id="vehicle_costs"></div>
      
      <a class='button'  href='/fueling?vehicle=#{params[:vehicle]}'>Show fuelings</a>
      
    HTML
  end

end