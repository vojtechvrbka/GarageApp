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
        
        
        
    # --------------------------------------------------------------------------------------
    
  
        
    # prumer pro mesice
  
    @fuelings = Fueling.all.vehicle_id(@vehicle.id).type(Fueling.TYPE_FUELING).sort(:date).run
    fueling_list = ArrayList.new
    @fuelings.each{ |f| fueling_list.add(f)   }
    months = ArrayHelper.group(fueling_list, :month)
    @months_avg = LinkedHashMap.new
 #   @months_costs = LinkedHashMap.new
    
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
  #    @months_costs.put(k ,Double.new(price))
      
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
   
   
    
      # ------------------ naklady mesicni --------------------------
   
      # radsi nactu znova
      
      
      fuelings = Fueling.all.vehicle_id(@vehicle.id).sort(:date).run
      fueling_list = ArrayList.new
      fuelings.each{ |f| fueling_list.add(f)   }
      months = ArrayHelper.group(fueling_list, :month)
    
      from_epoch = TimeHelper.at_date(1,filter_from_month,filter_from_year).month_of_epoch
      to_epoch = TimeHelper.at_date(1,filter_to_month,filter_to_year).month_of_epoch
       
       
      @months_costs = LinkedHashMap.new
      @stat_costs = ArrayList.new
      @costs_all = LinkedHashMap.new
      #mesice 
      months.keys.each do |k|
        if Integer(k).intValue >= from_epoch and Integer(k).intValue <= to_epoch
          month_costs = ArrayHelper.group(ArrayList(months.get(k)) , :cost)
          costs = LinkedHashMap.new
          
          month_costs.keys.each do |l| # fueling grops
            ArrayList(month_costs.get(l)).each do |fo| # fuelings
                          
              f = Fueling(fo)
              begin
                costs.put(Long.new(f.cost), Double.new(f.price + Double(costs.get(Long.new(f.cost))).doubleValue  ) )
              rescue 
                costs.put(Long.new(f.cost), Double.new(f.price) )
              end           
              
              # all costs
              begin
                @costs_all.put(Long.new(f.cost), Double.new(f.price + Double(@costs_all.get(Long.new(f.cost))).doubleValue  ) )
              rescue 
                @costs_all.put(Long.new(f.cost), Double.new(f.price) )
              end           
              
              
              if !@stat_costs.contains(Long.new(f.cost))
                 @stat_costs.add(Long.new(f.cost))
              end   
                 
            end            
            @months_costs.put(k,costs)
          end          
        end

        @rows2 = ''
        @months_costs.keys.each do |k|
          fs = LinkedHashMap(@months_costs.get(k))
          month_print = TimeHelper.at_month_of_epoch(Integer(k)).month_print
          @rows2 += "\n['#{month_print}'"
          
          @stat_costs.each do |ft|
            begin
              price = Double(fs.get(Long(ft))).doubleValue
              @rows2 += ","+Double.toString(double(int(price*100))/100)              
            rescue
              @rows2 += ",0"
            end 
          end   
          
          @rows2 += "],"             
        end
        
        @cols = ''
        @pie_row = ''
        @stat_costs.each do |ft|
          col = Fueling.all_cost_array.get(Long(ft))
          @cols += "\n data.addColumn('number', '#{col}');"
          price = Double(@costs_all.get(Long(ft))).doubleValue
          @pie_row += "['#{col}', #{price} ],"
        end
                    
 #         rows2 += "['#{month}',"+ Double.toString(double(int(Double(it).doubleValue*100))/100) + "],"
#          i+=1
        end
        
    #    puts 'rows'
    #    puts @rows2
    #    @months_avg.put(k ,Double.new(sum/count))
    #    @months_costs.put(k ,Double.new(price))


    
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




    
    <<-HTML
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
        <script type="text/javascript">
          google.load("visualization", "1", {packages:["corechart"]});
          google.setOnLoadCallback(drawChart);
          google.setOnLoadCallback(drawVehicleCostsChart);
          google.setOnLoadCallback(drawCostsPieChart);


          function drawCostsPieChart() {

                // Create our data table.
                  var data = new google.visualization.DataTable();
                  data.addColumn('string', 'Cost');
                  data.addColumn('number', 'Price');
                  data.addRows([
                    #{@pie_row}
                  ]);

                  // Instantiate and draw our chart, passing in some options.
                  var chart = new google.visualization.PieChart(document.getElementById('pie_chart_div'));
                  chart.draw(data, {width: 800, height: 340, is3D: true, 
                  chartArea:{left:20,top:10,width:"100%",height:"100%"} });
          }
          
          function drawChart() {
            var data = new google.visualization.DataTable();
          
            data.addColumn('string', 'Months');
            data.addColumn('number', 'Mine');
     
            data.addRows([
              #{rows}
            ]);

            var chart = new google.visualization.AreaChart(document.getElementById('chart_div'));
            chart.draw(data, {width: 800, height: 360, 
                              hAxis: {title: 'Months', titleTextStyle: {color: '#FF0000'}},
                              vAxis: {title: 'l / 100 Km', titleTextStyle: {color: '#FF0000'}},
                              chartArea:{left:50,top:5,width:"100%",height:"70%"}
                              
                             });
          }
          function drawVehicleCostsChart() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Months');
            #{@cols}
            
            data.addRows([
              #{@rows2}
            ]);

            var chart = new google.visualization.AreaChart(document.getElementById('vehicle_costs'));
            chart.draw(data, {width: 800, height: 340, isStacked:true,
                              hAxis: {title: 'Months', titleTextStyle: {color: '#FF0000'}},
                              vAxis: {title: 'EUR', titleTextStyle: {color: '#FF0000'}},
                              legend:'bottom',lineWidth:0, chartArea:{left:50,top:5,width:"100%",height:"70%"}
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


        <h2 class="ribbon full">Stats of  <a href="/vehicle/show/#{@vehicle.id}" >#{@vehicle.maker.name} #{@vehicle.model_exact}</a> <span>Owner is <a href="" style="color:white">username</a></span></h2>
            <div class="triangle-ribbon"></div>
            <br class="cl" />
 

        <form action="" method="post" class="stats_filter"> 
        		<fieldset style="height:120px;"> 
        			<label for="valueA">Between</label> 
              #{@date_select_from}
        			<label for="valueB">and</label> 
              #{@date_select_to}
        		</fieldset>         		
        		<button class="" type="submit">  Filter  </button>
        	</form>
      
      <br class="cl" />  	
      <h2 class="ribbon ">Basic</h2>
        <div class="triangle-ribbon"></div>
        <br class="cl" />
        
        <!-- 
        <ul class="sidebar-nav" style="float:right;width:260px;">
               <li class="first"><a href="#">About Us</a></li>
               <li class="current"><a href="#">Our History</a></li>
               <li><a href="#">The Team</a></li>
        </ul>
        -->
        <strong>Price per month</strong> #{@month_price} EUR<br />
        <strong>Price per km</strong> #{@km_price} EUR <br />
        <br />
        
        
    <br class="cl" />    
    <h2 class="ribbon ">Consumption</h2>
      <div class="triangle-ribbon"></div>
      <br class="cl" />
      <!-- 
      <strong> Show: </strong> &nbsp;&nbsp;&nbsp;
      <button id="button_basic" class="" onclick="show_cons('basic')">Basic</button>  
      <button id="button_tires" class="black " onclick="show_cons('tires')">Tires</button>  
      <button id="button_driving" class="black " onclick="show_cons('driving')">Driving style</button>  

      <script>
        function show_cons(type) {
          $('#cons_basic').hide()
          $('#cons_tires').hide()
          $('#cons_driving').hide()
          
          $('#button_basic').addClass('black')
          $('#button_tires').addClass('black')
          $('#button_driving').addClass('black')
          
          $('#cons_'+type).show()
          $('#button_'+type).removeClass('black')
        }
      </script>
      <br />
      <div id="cons_basic">
       
      </div>      
      <div id="cons_tires">
        tires
      </div>      
      <div id="cons_driving">
        driving
      </div>
      -->
                    
       <div id="chart_div"></div>
            
    <br class="cl" />  
    
    <h2 class="ribbon ">Costs</h2>
      <div class="triangle-ribbon"></div>
      <br class="cl" />
      
      <div id="pie_chart_div"></div>  
      <br /><br />
      <div id="vehicle_costs"></div>
      
      <!-- 
      <a class='button'  href='/fueling?vehicle=#{params[:vehicle]}'>Show fuelings</a>
      -->
    HTML
  end

end