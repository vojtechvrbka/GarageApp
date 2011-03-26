import dubious.*
import ext.*
import models.*
import utils.*

class  GarageController < PublicController

  def index
    @logged_in = logged_in?
    if logged_in?
      if @vehicles = Vehicle.all.user_id(user.id).deleted(false).run
        null
      end
      
      @empty = true
      @vehicles.each do |v|
        @empty = false
      end
    end
    list_erb
  end

  
  def new
    @new = true
    @vehicle = Vehicle.blank
    @vehicle_makers = VehicleMaker.all.run
    @vehicle_models = VehicleModel.all.run
    self.page_title = 'Add/Edit Vehicle'
    self.page_description = ''
    edit_erb
  end
  
  def edit
    @new = false
    @vehicle = Vehicle.get(params.id)
  #  if @vehicle.user_id == user.id
      @vehicle_makers = VehicleMaker.all.run
      @vehicle_models = VehicleModel.all.maker_id(@vehicle.maker_id).run
      edit_erb
  #  else
  #    redirect_to :index
  #  end
    
  end  

  
  def save
    if params.peek == null || params.peek.equals("new")
      v = Vehicle.new
      v.user_id = user.id
      v
    else      
      v = Vehicle.get(params.id)
    end
    
    if params.has(:action) && params[:action].equals(:delete)
      v.delete
      null
    else
      if params.multipart?
        v.update(params.multipart_for('vehicle'))
      else
        v.update(params.for(:vehicle))
      end
      v.save      
      null
    end
    
    redirect_to '/garage/garage'
  end 
  
  def remove
    @vehicle = Vehicle.get(params.id)
    @vehicle.delete
    redirect_to '/garage/garage'
  end  
  
  def edit_erb

    


    maker_select = "<select class='middle' name='vehicle[maker_id]' onchange=\"get_models('vehicle_model',this.value);\">"
    maker_select += "<option value='0'> All </option>";
    @vehicle_makers.each do |maker|
      selected = ( maker.id == @vehicle.maker_id ? 'selected="selected"' : '')
      maker_select += "<option value='#{maker.id}' #{selected}>#{maker.name}</option>"
    end
    maker_select += "</select>";
    
    

      model_select = "<select class='middle' name='vehicle[model_id]'>"
      model_select += "<option value='0'> All </option>"
      if @vehicle.maker_id > 0        
        @vehicle_models.each do |model|
          selected = ( model.id == @vehicle.model_id ? 'selected="selected"' : '')
          model_select += "<option value='#{model.id}' #{selected}>#{model.name}</option>"
        end
      end
      model_select += "</select>";
    

    type_select =  Element.select('vehicle[type]').
                               option(Vehicle.TYPE_AUTOMOBILE, 'Automobile').
                               option(Vehicle.TYPE_TWO_WHEELER, 'Two-wheeler').
                               option(Vehicle.TYPE_COMMERCIAL, 'Commercial vehicle').
                               option(Vehicle.TYPE_QUAD, 'Quad').
                               value(@vehicle.type)
    type_select.class(:middle)
    
    fuel_type_select =  Element.select("vehicle[fuel_type]").
                               option(Vehicle.FUEL_DIESEL, 'Diesel').
                               option(Vehicle.FUEL_GASOLINE, 'Gasoline').
                               option(Vehicle.FUEL_LPG, 'LPG').
                               option(Vehicle.FUEL_CNG, 'CNG').
                               option(Vehicle.FUEL_ELECTRICITY, 'Electricity').
                               value(@vehicle.fuel_type)
    fuel_type_select.class(:middle)
                               
    engine_power_unit_select =  Element.select("engine_power_unit").
                               option("kw", "kW").
                               option("ps", "ps").
                               option("hp", "hp").
                               value('kw')
    engine_power_unit_select.class(:small2)
    
    odometer_unit_select =  Element.select("vehicle[odometer_unit]").
                               option("km", "kilometers").
                               option("m", "miles").
                               value(@vehicle.odometer_unit)
    odometer_unit_select.class(:middle)
                               
    gearing_select =  Element.select("vehicle[gearing]").
                              option(Vehicle.GEARING_MANUAL , 'manual').
                              option(Vehicle.GEARING_AUTOMATIC, 'automatic').
                              value(@vehicle.gearing)
    gearing_select.class(:middle)
                                 
    <<-HTML
    <h2 class="ribbon full">#{@new ? 'Create vehicle' : 'Edit vehicle'}  </h2>
        <div class="triangle-ribbon"></div>
        <br class="cl" />

    <form class="vehicle" method="post" action="/garage/save/#{String.valueOf(@vehicle.url_id)}">
      <h3> Basic information </h3>
      <p>
        <label for="type">Vehicle type</label>
    		#{type_select.to_s}
      </p>
      <p>
        <label for="maker">Make</label>
        #{maker_select}
      </p>
      <p>
        <label for="model">Model</label>
    		<span id="vehicle_model">#{model_select}</span>
      </p>
      <p>
        <label for="fuel_type">Fuel type</label>
    		#{fuel_type_select.to_s}
      </p>
      
      <p>
        <label for="model_exact">Exact modelname</label>
    		<input type="text" class="middle" id="model_exact" name="vehicle[model_exact]" value="#{h(@vehicle.model_exact)}">
      </p>
      
      <p>
        <label for="gearing">Gearing type</label>
    		#{gearing_select.to_s}
      </p>

      
      <p>
        <label for="year">Year of manufacture</label>
    		<input type="text" class="small2" id="year" name="vehicle[year]" value="#{h(Long.toString(@vehicle.year))}">
      </p>
      
      <p>
        <label for="engine_power">Engine power</label>
    		<input type="text" class="small" id="engine_power" name="vehicle[engine_power]" value="#{h(Double.toString(@vehicle.engine_power))}"> 
    		#{engine_power_unit_select.to_s}
      </p>
      
    
      
      <h3>Optional data</h3>
      <p>
        <label for="odometer">Odometer in</label>
    		#{odometer_unit_select.to_s} 
      </p>
      
      
      <p>
        <label for="tank_capacity">Tank capacity</label>
    		<input type="text" class="small" id="tank_capacity" name="vehicle[tank_capacity]" value="#{h(Double.toString(@vehicle.tank_capacity))}">
      </p>

      <p>
        <label for="note">Note</label>
    		<textarea id="note" name="vehicle[note]" style="width:200px;height:80px;">#{h(@vehicle.note)}</textarea>
      </p>
     	<p>
    	  <button class="fr" type="submit"> #{@new ? 'Create' : 'Update'} </button>
    	</p>
    </form>
    HTML
    
  end
  
  
  
  def list_erb 
    html = <<-HTML
    <h2 class="ribbon full">My garage </h2>
    <div class="triangle-ribbon"></div>
    <br class="cl" />
   <div id="page-content" class="two-col container_12">
    
    HTML
    if @logged_in
    
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
              <button class="black small" onclick="document.location.href = '/fueling/new?vehicle=#{vehicle.id}'">Add fueling</button>
              <button class="black small" onclick="document.location.href = '/costs_notes/new?vehicle=#{vehicle.id}'">Add note/cost</button>
              <button class="black small"  onclick="document.location.href = '/garage/edit/#{vehicle.id}'">Edit</button>
            <a  href='/fueling/?vehicle=#{vehicle.id}'>fueling entries</a>
            <a  href='/stats/?vehicle=#{vehicle.id}'>stats</a>
            </div>
            <br class="cl" />
            <br />  
      HTML
      
      end

    else
      html += <<-HTML
      <div class="notification info"> You have no vehicles </div>
      HTML
    end    
    
    html += <<-HTML
      <br class="cl" />
      <form action="/garage/new" method="post">
        <button class="large">Add vehicle</button>
      </form>
    HTML
    else
      html += "Please, Login first"
    end
    html += "</div>"
  end

  
end