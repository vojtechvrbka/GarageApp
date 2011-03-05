import dubious.*
import ext.*
import models.*
import utils.*

import java.util.ArrayList

class  StatsController < PublicController
  
  
  def index
    @vehicle = Vehicle.all.user_id(user.id).deleted(false).first
    html = ""
    
 
    @fuelings = Fueling.all.vehicle_id(@vehicle.id).sort(:date).run
    prev = Fueling.blank
    count = 0
    sum = 0.0
    @fuelings.each do |f|
      if prev.odometer > 0    
        distance = f.odometer - prev.odometer
        sum += (f.quantity / distance) * 100  
        count += 1
      end
      prev = f
    end
    puts Double.toString(sum/count)
    
    
    # prumer pro mesice
  
    @fuelings = Fueling.all.vehicle_id(@vehicle.id).sort(:date).run
    prev = Fueling.blank
    months = ArrayList.new
    @month_costs = ArrayList.new
    12.times { 
      months.add(ArrayList.new) 
      @month_costs.add(Double.new(0.0))
    }
    
    th = TimeHelper.new
    
    
    @fuelings.each do |f|
      if prev.odometer > 0    
        distance = f.odometer - prev.odometer
        avg =  (f.quantity / distance) * 100  
        th.ms(f.date)
        ArrayList(months.get(th.month-1)).add(Double.new(avg))
        @month_costs.set(th.month-1, Double.new(f.price*f.quantity +  Double(@month_costs.get(th.month-1)).doubleValue))  
      end
      prev = f
    end
    
    
    @months_avg = ArrayList.new
    i = 0
    while i < 12
      count = 0
      sum = 0.0
      ArrayList(months.get(i)).each do |it|
        count += 1
        sum += Double(it).doubleValue
      end
      @months_avg.add(Double.new(sum/count))
      i+=1
    end

    chart_erb
   end
  
  def chart_erb
    rows = ""
    i=0
    @months_avg.each do |it|
     rows += "['#{i}',"+ Double.toString(double(int(Double(it).doubleValue*100))/100) + "],"
     i+=1
    end  
    rows2 = ""
    i=0
    @month_costs.each do |it|
     rows2 += "['#{i}',"+ Double.toString(double(int(Double(it).doubleValue*100))/100) + "],"
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
            data.addColumn('number', '2010');
     
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
        </script>
      <h1>My stats</h1>
      <h2>Average fuel consumption<h2>
      <div id="chart_div"></div>
      
      <h2>Vehicle costs<h2>
      <div id="vehicle_costs"></div>
    HTML
  end

end