import dubious.*
import ext.*
import models.*
import utils.*

import java.util.ArrayList

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
    
    if @vehicles = vehicles_tmp.run
      @empty = false
    else
      @empty = true
    end
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
    

    
    if !@empty
 
    @vehicles.each do |vehicle|
      html += <<-HTML
      <div class="grid_4"> <img class="inlinepic" src="/img/tmp/bmw_small.jpg" alt="" /> </div>
            <div class="grid_8">
              <h4>#{h(vehicle.maker.name)} #{h(vehicle.model_exact)}</h4>
              <h5 class="inline">Distance: <span style="font-weight:normal;">60 541 Km</span></h5> <br class="cl" />
              <h5 class="inline">Mileage: <span style="font-weight:normal;">8.2 l/100Km</span></h5> <br class="cl" />
              <br />
              <button class="blue small" onclick="document.location.href = '/vehicle/show/#{vehicle.id}'">Detail</button>
              <button class="black small" onclick="document.location.href = '/fueling/?vehicle=#{vehicle.id}'">fueling entries</button>
              <button class="black small" onclick="document.location.href = '/stats/?vehicle=#{vehicle.id}'">stats</button>
              <button class="black small"  onclick="document.location.href = '/garage/edit/#{vehicle.id}'">Edit</button>

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
      <div class="pagination fr"> <a href="#">&lt; Prev</a> <a href="#" class="number">1</a> <a href="#" class="number current">2</a> <span class="dots">...</span> <a href="#" class="number">8</a> <a href="#" class="number">9</a> <a href="#">Next &gt;</a> </div>
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
      @exists = true
    else
      @exists = false
    end
    
    show_erb
  end
  
  
  def show_erb
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
          <br />
          <strong>Gearing type</strong> <span>#{@vehicle.gearing_title}</span><br />
          <strong>Engine power</strong> <span>#{@vehicle.engine_power} kW</span><br />
          <br />
          <strong>Mileage</strong> <span>5.22 l/100km</span><br />
          <strong>Distance</strong> <span>25 3652 Km</span><br />
        </div>
    
    <br class="cl" /><br />
    
    <h2 class="ribbon">Gallery</h2>
        <div class="triangle-ribbon"></div>
         <br class="cl" />

         <!-- "previous page" action -->
         <a class="prev browse left"></a>
         <div id="browsable" class="scrollable">   

            <!-- root element for the items -->
            <div class="items">

               <!-- 1-5 -->
               <div>
                  <img src="/img/screenshots/buttons.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/gallery.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/calendars.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/charts.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/coding.jpg" height="100" width="100" alt="" />
               </div>

               <!-- 5-10 -->
               <div>
                  <img src="/img/screenshots/docs.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/forms.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/gallery.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/notifications.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/pagination.jpg" height="100" width="100" alt="" />
               </div>

               <!-- 10-15 -->
               <div>
                  <img src="/img/screenshots/psd.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/switches.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/tabs.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/themes.jpg" height="100" width="100" alt="" />
                     <img src="/img/screenshots/tips.jpg" height="100" width="100" alt="" />
               </div>

            </div>

         </div>
         <!-- "next page" action -->
         <a class="next browse right"></a>


         <br class="cl" /><br />

    <h2 class="ribbon">Fuelings and Costs</h2>
             <div class="triangle-ribbon"></div>
              <br class="cl" />

     <button class="black small" onclick="document.location.href = '/fueling/?vehicle=#{@vehicle.id}'">show more</button>
     <br class="cl" /><br />
     
    <h2 class="ribbon">Statistics</h2>
             <div class="triangle-ribbon"></div>
              <br class="cl" />
              
    <button class="black small" onclick="document.location.href = '/stats/?vehicle=#{@vehicle.id}'">show more</button>
    HTML
  end
  
  
end