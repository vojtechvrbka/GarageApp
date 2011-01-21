import dubious.*
import ext.*
import models.*
import utils.*

class  StatsController < PublicController
  
  
  def index
    self.page_title = 'Obchodní podmínky'
    self.page_description = ''
/*
    vehicle_id = Integer.parseInt(params[:vehicle])
    if @vehicle = Vehicle.get(vehicle_id)  
      if Vehicle.get(vehicle_id).user_id == user.id
        if @fuelings = Fueling.all.vehicle_id(vehicle_id).run
          @emtry = false
        else
          @empty = true
        end        
        null
      else
        # not my vehicle
        redirect_to :index        
        null
      end
    else 
      # vehicle not exists
      redirect_to :index
      null
    end
*/
    list_erb
  end
  
  def list_erb
    <<-HTML
    <script type="text/javascript" src="https://www.google.com/jsapi"></script>
        <script type="text/javascript">
          google.load("visualization", "1", {packages:["corechart"]});
          google.setOnLoadCallback(drawChart);
          function drawChart() {
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Year');
            data.addColumn('number', 'Sales');
            data.addColumn('number', 'Expenses');
            data.addRows([
              ['2004', 1000, 400],
              ['2005', 1170, 460],
              ['2006', 660, 1120],
              ['2007', 1030, 540]
            ]);

            var chart = new google.visualization.AreaChart(document.getElementById('chart_div'));
            chart.draw(data, {width: 400, height: 240, title: 'Company Performance',
                              hAxis: {title: 'Year', titleTextStyle: {color: '#FF0000'}}
                             });
          }
        </script>
      <div id="chart_div"></div>
    HTML
  end

end