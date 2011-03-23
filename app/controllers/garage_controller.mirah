import dubious.*
import ext.*
import models.*
import utils.*

class  GarageController < PublicController

  def index
    @logged_in = logged_in?
    if logged_in?
      if @vehicles = Vehicle.all.user_id(user.id).deleted(false).run
        @empty = false
      else
        @empty = true
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

    


    maker_select = "<select name='vehicle[maker_id]' onchange=\"get_models('vehicle_model',this.value);\">"
    maker_select += "<option value='0'>-- choose --</option>";
    @vehicle_makers.each do |maker|
      selected = ( maker.id == @vehicle.maker_id ? 'selected="selected"' : '')
      maker_select += "<option value='#{maker.id}' #{selected}>#{maker.name}</option>"
    end
    maker_select += "</select>";
    
    
    if @vehicle.model_id > 0
      model_select = "<select name='vehicle[model_id]'>"
      @vehicle_models.each do |model|
        selected = ( model.id == @vehicle.model_id ? 'selected="selected"' : '')
        model_select += "<option value='#{model.id}' #{selected}>#{model.name}</option>"
      end
      model_select += "</select>";
    else
      model_select = 'choose maker first'
    end
    

    type_select =  Element.select('vehicle[type]').
                               option(Vehicle.TYPE_AUTOMOBILE, 'Automobile').
                               option(Vehicle.TYPE_TWO_WHEELER, 'Two-wheeler').
                               option(Vehicle.TYPE_COMMERCIAL, 'Commercial vehicle').
                               option(Vehicle.TYPE_QUAD, 'Quad').
                               value(@vehicle.type).to_s

    fuel_type_select =  Element.select("vehicle[fuel_type]").
                               option(Vehicle.FUEL_DIESEL, 'Diesel').
                               option(Vehicle.FUEL_GASOLINE, 'Gasoline').
                               option(Vehicle.FUEL_LPG, 'LPG').
                               option(Vehicle.FUEL_CNG, 'CNG').
                               option(Vehicle.FUEL_ELECTRICITY, 'Electricity').
                               value(@vehicle.fuel_type).to_s
                               
    engine_power_unit_select =  Element.select("engine_power_unit").
                               option("kw", "kW").
                               option("ps", "ps").
                               option("hp", "hp").
                               value('kw').to_s
    
    odometer_unit_select =  Element.select("vehicle[odometer_unit]").
                               option("km", "kilometers").
                               option("m", "miles").
                               value(@vehicle.odometer_unit).to_s     
    gearing_select =  Element.select("vehicle[gearing]").
                              option(Vehicle.GEARING_MANUAL , 'manual').
                              option(Vehicle.GEARING_AUTOMATIC, 'automatic').
                              value(@vehicle.gearing).to_s
                                 
    <<-HTML
    <h1>#{@new ? 'Create vehicle' : 'Edit vehicle'}</h1>

    <form method="post" action="/garage/save/#{String.valueOf(@vehicle.url_id)}">
      <h2> Basic information </h2>
      <dl>
        <dt><label for="type">Vehicle type</label></dt>
    		<dd>#{type_select}</dd>
      </dl>
      <dl>
        <dt><label for="maker">Make</label></dt>
    		<dd id="vehicle_maker">#{maker_select}</dd>
      </dl>
      <dl>
        <dt><label for="model">Model</label></dt>
    		<dd id="vehicle_model">#{model_select}</dd>
      </dl>
      <dl>
        <dt><label for="fuel_type">Fuel type</label></dt>
    		<dd>#{fuel_type_select}</dd>
      </dl>
      
      <dl>
        <dt><label for="model_exact">Exact modelname</label></dt>
    		<dd><input type="text" id="model_exact" name="vehicle[model_exact]" value="#{h(@vehicle.model_exact)}"></dd>
      </dl>
      
      <dl>
        <dt><label for="gearing">Gearing type</label></dt>
    		<dd>#{gearing_select}</dd>
      </dl>

      
      <dl>
        <dt><label for="year">Year of manufacture</label></dt>
    		<dd><input type="text" id="year" name="vehicle[year]" value="#{h(Long.toString(@vehicle.year))}"></dd>
      </dl>
      
      <dl>
        <dt><label for="engine_power">Engine power</label></dt>
    		<dd><input type="text" id="engine_power" name="vehicle[engine_power]" value="#{h(Double.toString(@vehicle.engine_power))}"> 
    		    #{engine_power_unit_select}
    		  </dd>
      </dl>
      
      <br style="clear:both;" />
      
      <h2>Optional data</h2>
      <dl>
        <dt><label for="odometer">Odometer in</label></dt>
    		<dd>#{odometer_unit_select} </dd>
      </dl>
      
      
      <dl>
        <dt><label for="tank_capacity">Tank capacity</label></dt>
    		<dd><input type="text" id="tank_capacity" name="vehicle[tank_capacity]" value="#{h(Double.toString(@vehicle.tank_capacity))}"></dd>
      </dl>

      <dl>
        <dt><label for="note">Note</label></dt>
    		<dd><textarea id="note" name="vehicle[note]" style="width:200px;height:80px;">#{h(@vehicle.note)}</textarea></dd>
      </dl>
     	<dl>
    		<dt>
    			<input type="submit" name="submit" value="#{@new ?'Create':'Update'}">
    		</dt>
    	</dl>
    </form>
    HTML
  end
  
  
  
  def list_erb 
    html = "<h2>My garage</h2>"
    if @logged_in
    
    if !@empty
    html += "
    <table>
      <tr>
    		<th>Maker</th>
    		<th>Model</th>
    		<th>Exact</th>
    		<th>&nbsp;</th>
    		<th>&nbsp;</th>
    		<th>&nbsp;</th>
    		<th>&nbsp;</th>
      </tr>"
      
      @vehicles.each do |vehicle|
      html += "
      <tr>
    	  <td>#{h(vehicle.maker.name)}</td>
    	  <td>#{h(vehicle.model.name)}</td>
    	  <td>#{h(vehicle.model_exact)}</td>
    	  <td> <a class='button' href='/fueling/?vehicle=#{vehicle.id}'>fueling entries</a> </td>
      	<td> <a class='button' href='/stats/?vehicle=#{vehicle.id}'>stats</a> </td>    	  
    	  <td> <a class='button' href='/garage/edit/#{vehicle.id}'>Edit</a> </td>
    	  <td> <a class='button' href='/garage/remove/#{vehicle.id}'>Delete</a> </td>
      </tr>"
      end
      html += '</table>'
    else
      html += "No vehicles"
    end    
    
    html += "<a class='button' href='/garage/new'>Add vehicle</a>"
    else
      html += "Please, Login first"
    end
  end

  
end