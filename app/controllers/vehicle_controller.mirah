import dubious.*
import ext.*
import models.*
import utils.*


import java.util.*

class  VehicleController < PublicController
  
  def index
    # clear search
    if params.has? :search
      filters = ArrayList.new
      if params.has? :vehicle_type
        filters.add('vehicle_type=' + params[:vehicle_type])
      end
      if params.has? :maker
        filters.add('maker=' + params[:maker])
      end
      if params.has? :model
        filters.add('model=' + params[:model])
      end
      redir = '/vehicle?' 
      filters.each do |i|
        redir += String(i) + '&'
      end
      puts params[:vehicle_type]
      puts redir
      redirect redir
    end
    @makers = VehicleMaker.all.run
    if params.has? :maker
      @models = VehicleModel.all.maker_id(Long.parseLong(params[:maker])).run
    else
      @models = VehicleModel.all.run
    end
    
    vehicles_tmp = Vehicle.all.deleted(false)

    if params.has? :vehicle_type and Long.parseLong(params[:vehicle_type]) > 0
      vehicles_tmp = vehicles_tmp.type(Long.parseLong(params[:vehicle_type]))
    end
    
    if params.has? :maker and Long.parseLong(params[:maker]) > 0
      vehicles_tmp = vehicles_tmp.maker_id(Long.parseLong(params[:maker]))
    end
    
    if params.has? :model and Long.parseLong(params[:model]) > 0
      vehicles_tmp = vehicles_tmp.model_id(Long.parseLong(params[:model]))
    end
    
    
    # Pagination
    # --------------------------------------------------------------------
    
    items_per_page = 10
    if params.has? :page
      page = Integer.parseInt(params[:page])
    else
      page = 1
    end
    
    count = 0
    vehicles = vehicles_tmp.run
    vehicles.each do |v|
      count += 1
    end
    pages = int(count/items_per_page)
    
    @pagination = '<div class="pagination fr">'
    if page > 1
      @pagination += "<a href='?page=#{(page-1)}'>&lt; Prev</a>"
    end 
    p = 1

    while p < pages 
    # <a href="#" class="number">1</a> <a href="#" class="number current">2</a> <span class="dots">...</span> <a href="#" class="number">8</a> <a href="#" class="number">9</a> 
      current = ( p == page ? 'current' : '' )
      @pagination += "<a href='?page=#{p}' class='number #{current}'>#{p}</a>"
      p+=1
    end

    if page < pages
       @pagination += "<a href='?page=#{(page+1)}'>Next &gt;</a>"
    end 
  
    @pagination += '</div>'
    
    # ----------------------------------------------------------------------------
   # @vehicles = ArrayList.new
    @vehicles = vehicles_tmp.limit(items_per_page).offset( (page-1)*items_per_page ).run
   /*
    it = 1
    vehicles.each do |v| 
      if (page-1)*items_per_page < it and it <= page*items_per_page
        @vehicles.add(v)
        puts it
      end
      it+=1
    end
    */
    
    list_erb    
  end
  
  def list_erb 
    
    
    type_select =  Element.select('vehicle_type').
                   option(0, ' All ').
                   option(Vehicle.TYPE_AUTOMOBILE, 'Automobile').
                   option(Vehicle.TYPE_TWO_WHEELER, 'Two-wheeler').
                   option(Vehicle.TYPE_COMMERCIAL, 'Commercial vehicle').
                   option(Vehicle.TYPE_QUAD, 'Quad').
                   value(params[:vehicle_type]).to_s

     maker_select = "<select name='maker' onchange=\"get_models('model',this.value);\">"
      maker_select += "<option value='0'> All </option>";
      @makers.each do |maker|
        if params.has? :maker
          selected = ( maker.id == Long.parseLong(params[:maker]) ? 'selected="selected"' : '')
        end
        maker_select += "<option value='#{maker.id}' #{selected}>#{maker.name}</option>"
      end
      maker_select += "</select>";


      
        model_select = "<select name='model'>"
        model_select += "<option value='0'> All </option>";
        if params.has? :maker
          @models.each do |model|
            if params.has? :model
              selected = ( model.id == Long.parseLong(params[:model]) ? 'selected="selected"' : '')
            end
            model_select += "<option value='#{model.id}' #{selected}>#{model.name}</option>"
          end
        end
        model_select += "</select>";
      
    
    html = <<-HTML
      <h2 class="ribbon full">Vehicles</h2>
        <div class="triangle-ribbon"></div>
        <br class="cl" />       
        <div id="page-content" class="two-col container_12">
         
    HTML
    null

    
    if true
 
    @vehicles.each do |v|
      vehicle = Vehicle(v)
      html += <<-HTML
      <div class="grid_4"> <img class="inlinepic" src="/img/tmp/bmw_small.jpg" alt="" /> </div>
            <div class="grid_8">
              <h4>#{h(vehicle.maker.name)} #{h(vehicle.model_exact)}</h4>
              <h5 class="inline">Distance: <span style="font-weight:normal;">60 541 Km</span></h5> <br class="cl" />
              <h5 class="inline">Mileage: <span style="font-weight:normal;">8.2 l/100Km</span></h5> <br class="cl" />
              <br />
              <a class="button blue small" href='/vehicle/show/#{vehicle.id}'>Detail</a>
              <a class="button black small" href='/fueling/?vehicle=#{vehicle.id}'>fueling entries</a>
              <a class="button black small" href='/stats/?vehicle=#{vehicle.id}'>stats</a>
              <a class="button black small"  href='/garage/edit/#{vehicle.id}'>Edit</a>

            </div>
            <br class="cl" />
            <br />  
      HTML
      end
      html 
    else
      html += "No vehicles"
    end
    
    if !logged_in?
      html += <<-HTML
      <div class="notification tip nopic tc"> <strong>You are not logged in</strong>
        <p><a href="#">Sign in</a> and add your own vehicle. It's fun :-)</p>
      </div>
      HTML
    end
    
    html += <<-HTML
      <br class="cl" />
      #{@pagination}
      <br class="cl" />
    HTML
    
    
    
    
    
    html += <<-HTML 
          </div>
          <aside>
          
            <h3>Filter</h3>
            <form action='' method='get'>
            <input type='hidden' name='search' value='1'>
            <dl>
              <dt>Vehicle type</dt>
              <dd>#{type_select}</dd>
            </dl>
            <dl>
              <dt>Make</dt>
              <dd>#{maker_select}</dd>
            </dl>
            <dl>
              <dt>Model</dt>
              <dd id='model'>#{model_select}</dd>
            </dl>
            <button type="submit">Filter</button>

            </form>
          </aside>

          HTML
    
    
    

  end

  
  def show
    if @vehicle = Vehicle.get(params.id)
      @fuelings = Fueling.all.vehicle_id(@vehicle.id).sort(:date, true).limit(10).run
      show_erb
    else
     redirect '/'
    ""
    end
    
  end
  
  
  def show_erb

    if @fuelings.length > 0
 
      ftable = <<-HTML
      <table class="fueling-table">
        <tr class="no_border">
          <td class="blank">&nbsp;</td>
          <td class="header"><h5>Odometer</h5></td>
          <td class="header"><h5>Quantity</h5></td>
          <td class="header"><h5>Price</h5></td>
          <td class="header"><h5>Mileage</h5></td>
          <td class="blank">&nbsp;</td>
          <td class="blank">&nbsp;</td>
        </tr>
      HTML
      null
      first = true
      alt = false
         
      @fuelings.each do |f|
      #  f = Fueling(f)
        d = TimeHelper.at(f.date)
        
        if f.fueling_type == Fueling.FUELING_TYPE_FULL
          cons = double(int( (f.quantity / f.trip) * 100 * 100 ))/100  
        else
          cons = 0.0
        end
        
        
        if first 
          first = false  
          td_class = 'first' 
        else
          td_class = ''          
        end
        
        if alt 
          tr_class = 'alt' 
          alt = false  
        else
          tr_class = '' 
          alt = true 
        end
        
        
        # class="alt"
        if f.type == Fueling.TYPE_FUELING
          ftable += <<-HTML
          <tr class='fueling #{tr_class}'>
            <td class="feature #{td_class}">#{d.print_date}</td>          	
          	<td>#{f.odometer > 0 ? h(Long.toString(f.odometer) + 'Km') : ''}</td>
          	<td>#{h(Double.toString(f.quantity))} l</td>
          	<td>#{h(Double.toString(f.price))} #{f.price_currency}</td>
          	<td>#{ cons > 0 ? h(Double.toString(cons))+' l/100 Km' : ''}</td>
           	<td class="last #{td_class}"> <a href='/fueling/edit/#{f.id}?vehicle=#{@vehicle.id}'><img class="tooltip" title="Edit" src="/img/edit.png" /></a> </td>
          	<td class="last #{td_class}"> <a href='/fueling/remove/#{f.id}?vehicle=#{@vehicle.id}'><img class="tooltip" title="Delete" src="/img/delete.png" /></a> </td>
          </tr>
          HTML
        elsif f.type == Fueling.TYPE_COST
            ftable += <<-HTML
            <tr class='cost  #{tr_class}'>
              <td class="feature #{td_class}">#{d.print_date}</td>
            	<td>#{f.odometer > 0 ? h(Long.toString(f.odometer) + 'Km') : ''}</td>
            	<td>#{f.cost_type_title}</td>
            	<td>#{h(Double.toString(f.price))} #{f.price_currency}</td>
            	<td></td>
            	<td class="#{td_class}"> <a href='/costs_notes/edit/#{f.id}?vehicle=#{@vehicle.id}'><img class="tooltip" title="Edit" src="/img/edit.png" /></a> </td>
            	<td class="#{td_class}"> <a href='/costs_notes/remove/#{f.id}?vehicle=#{@vehicle.id}'><img class="tooltip" title="Delete" src="/img/delete.png" /></a> </td>
            </tr>
            HTML
        end  
        
      end
    
      ftable += "</table>"
      
  
      null
    else        
      ftable = '<div class="notification info" style="width:80%;"> No fuelings or costs </div>'
      null
    end

    

    if true
      fadd = <<-HTML
          <a href="/fueling/?vehicle=#{@vehicle.id}" class="button blue small">show more</a>
          <a href="/fueling/new?vehicle=#{@vehicle.id}" class="button black small">add fueling</a>
          <a href="/costs_notes/new?vehicle=#{@vehicle.id}" class="button black small">add cost/note</a>
      HTML
    end




      @fuelings = Fueling.all.vehicle_id(@vehicle.id).type(Fueling.TYPE_FUELING).sort(:date).run
          
      min_time = long(0); max_time = long(0)
      first = true
      @fuelings.each do |f|
        if first # prvni zaznam
          min_time = f.date
          first = false
        end
        if min_time > f.date
          min_time = f.date
        end
        if max_time < f.date
          max_time = f.date
        end
      end 
            
      fueling_list = ArrayList.new
      @fuelings.each{ |f| fueling_list.add(f)   }
      months = ArrayHelper.group(fueling_list, :month)
      @months_avg = LinkedHashMap.new

      months.keys.each do |k|
        sum=0.0; count=0;price = 0.0;
        ArrayList(months.get(k)).each do |it|
          if Fueling(it).type == Fueling.TYPE_FUELING and Fueling(it).fueling_type == Fueling.FUELING_TYPE_FULL
            count += 1
            sum += ( Fueling(it).quantity / Fueling(it).trip) * 100
          end
          price += Fueling(it).price
        @months_avg.put(k ,Double.new(sum/count))
        end
      end


    rows = ""
    
    i=0
    @months_avg.keys.each do |k|
      it = @months_avg.get(k)

      month = TimeHelper.at_month_of_epoch(Integer(k)).month_print
      rows += "['#{month}',"+ Double.toString(double(int(Double(it).doubleValue*100))/100) + "],"
      i+=1
    end
    
    
    if TimeHelper.at(min_time).month_of_epoch+2 >= TimeHelper.at(max_time).month_of_epoch
      chart_div = '<div class="notification info" style="width:80%;"> Not enough data </div>'
    else
      chart_div = <<-HTML
      <div id="chart_div"></div>      
      <a href="/stats/?vehicle=#{@vehicle.id}" class="button blue small">show more</a>
      HTML
    end
    
    html =
    <<-HTML
    <h2 class="ribbon full">#{@vehicle.maker.name} #{@vehicle.model_exact} <span>Owner is <a href="" style="color:white">username</a></span></h2>
        <div class="triangle-ribbon"></div>
        <br class="cl" />

        
        <div class="grid_4">
          <img class="inlinepic" src="/img/tmp/bmw_detail.jpg">
        </div>
        <div class="grid_8 vehicle_info">
          <strong>Make</strong> <span>#{@vehicle.maker.name}</span><br />
          <strong>Model</strong> <span>#{@vehicle.model_exact}</span><br />
          <strong>Fuel type</strong> <span>#{@vehicle.fuel_type_title}</span><br />
          <strong>Year</strong> <span>#{@vehicle.year}</span><br />
          <br />
          <strong>Gearing type</strong> <span>#{@vehicle.gearing_title}</span><br />
          <strong>Engine power</strong> <span>#{@vehicle.engine_power} kW</span><br />
          <br />
          <strong>Mileage</strong> <span>5.22 l/100km</span><br />
          <strong>Distance</strong> <span>25 3652 Km</span><br />
        </div>
    
    <br class="cl" /><br />
    <!-- 
    <h2 class="ribbon">Gallery</h2>
        <div class="triangle-ribbon"></div>
         <br class="cl" />
         
         <a class="prev browse left"></a>
         <div id="browsable" class="scrollable">            
            <div class="items">
               <div>
                  <img src="/img/screenshots/buttons.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/gallery.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/calendars.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/charts.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/coding.jpg" height="100" width="100" alt="" />
               </div>
               <div>
                  <img src="/img/screenshots/docs.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/forms.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/gallery.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/notifications.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/pagination.jpg" height="100" width="100" alt="" />
               </div>
               <div>
                  <img src="/img/screenshots/psd.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/switches.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/tabs.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/themes.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/tips.jpg" height="100" width="100" alt="" />
               </div>
            </div>
         </div>
         <a class="next browse right"></a>

         <br class="cl" /><br />
        -->
    <h2 class="ribbon">Fuelings and Costs</h2>
             <div class="triangle-ribbon"></div>
              <br class="cl" />
    #{ftable}
    
    <div style="height:40px;">
    #{fadd}
    </div>
     <br class="cl" />
     
    <h2 class="ribbon">Statistics</h2>
             <div class="triangle-ribbon"></div>
              <br class="cl" />
     
     
     
     
              #{chart_div}
              
     
               <script type="text/javascript" src="https://www.google.com/jsapi"></script>
                    <script type="text/javascript">
                      google.load("visualization", "1", {packages:["corechart"]});
                      google.setOnLoadCallback(drawChart);

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
                                          chartArea:{left:60,top:5,width:"100%",height:"70%"}

                                         });
                      }
                    </script>
     
              
    
              
    HTML
    
  end
  
  
end