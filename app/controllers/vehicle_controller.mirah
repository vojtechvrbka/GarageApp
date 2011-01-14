import dubious.*
import ext.*
import models.*
import utils.*

class  VehicleController < PublicController
  
  
  def index
    self.page_title = 'Obchodní podmínky'
    self.page_description = ''
    
    @empty = false
    begin
      @vehicles = Vehicle.all.user_id(user.id).deleted(false).run
    rescue
      @empty = true
    end
    list_erb
  end
  
  def new
    @new = true
    @vehicle = Vehicle.blank
    @vehicle_types = VehicleType.all.run
    @vehicle_makers = VehicleMaker.all.run
    @vehicle_models = VehicleModel.all.run
    self.page_title = 'Add/Edit Vehicle'
    self.page_description = ''
    edit_erb
  end
  
  def edit
    @new = false
    @vehicle = Vehicle.get(params.id)
    if @vehicle.user_id == user.id
      @vehicle_types = VehicleType.all.run
      @vehicle_makers = VehicleMaker.all.type_id(@vehicle.type_id).run
      @vehicle_models = VehicleModel.all.maker_id(@vehicle.maker_id).run
      edit_erb
    else
      redirect_to :index
    end
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
    
    redirect_to :index
  end 
  
  def remove
    @vehicle = Vehicle.get(params.id)
    @vehicle.delete
    redirect_to :index
  end  
  
  def edit_erb
    
    type_select = "<select name='vehicle[type_id]' onchange=\"get_makers('vehicle_maker',this.value);\">"
    type_select += "<option value='0'>-- choose --</option>";
    @vehicle_types.each do |type|
      selected = ( type.id == @vehicle.type_id ? 'selected="selected"' : '')
      type_select += "<option value='#{type.id}' #{selected}>#{type.name}</option>"
    end
    type_select += "</select>";

    if @vehicle.maker_id > 0
      maker_select = "<select name='vehicle[maker_id]' onchange=\"get_models('vehicle_model',this.value);\">"
      maker_select += "<option value='0'>-- choose --</option>";
      @vehicle_makers.each do |maker|
        selected = ( maker.id == @vehicle.maker_id ? 'selected="selected"' : '')
        maker_select += "<option value='#{maker.id}' #{selected}>#{maker.name}</option>"
      end
      maker_select += "</select>";
    else
      maker_select = 'choose type first'
    end
    
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
    
    @fuel_type = FuelType.all.run
    fuel_type_select = "<select name='vehicle[fuel_type_id]'>"
    @fuel_type.each do |fuel_type|
      selected = (fuel_type.id == @vehicle.fuel_type_id ? 'selected="selected"' : '')
      fuel_type_select += "<option value='#{fuel_type.id}' #{selected}>#{fuel_type.name}</option>"
    end
    fuel_type_select += "</select>"
    
    fuel_unit_select = "<select name='vehicle[fuel_unit]'>" +
                        "<option value='l'>liter</option>" +
                        "<option value='gal_us'>Gallon (US)</option>" +
                         "<option value='gal_gb'>Gallon (GB)</option>" +
                        "</select>"
    
    engine_power_unit_select = "<select name='vehicle[engine_power_unit]'>" +
                        "<option value='kw'>kW</option>" +
                        "<option value='ps'>PS</option>" +
                         "<option value='hp'>hp</option>" +
                        "</select>"
                        
    odometer_unit_select = "<select name='vehicle[odometer_unit]'>" +
                           "<option value='km'>kilometers</option>" +
                            "<option value='m'>miles</option>" +
                            "</select>"    
    
    
    <<-HTML
    <h1>#{@new ? 'Create vehicle' : 'Edit vehicle'}</h1>

    <form method="post" action="/vehicle/save/#{String.valueOf(@vehicle.url_id)}">
      <h2> Basic information </h2>
      <dl>
        <dt><label for="type">Type:</label></dt>
    		<dd>#{type_select}</dd>
      </dl>
      <dl>
        <dt><label for="maker">Maker:</label></dt>
    		<dd id="vehicle_maker">#{maker_select}</dd>
      </dl>
      <dl>
        <dt><label for="model">Model:</label></dt>
    		<dd id="vehicle_model">#{model_select}</dd>
      </dl>
      <dl>
        <dt><label for="model_exact">Model exact:</label></dt>
    		<dd><input type="text" id="model_exact" name="vehicle[model_exact]" value="#{h(@vehicle.model_exact)}"></dd>
      </dl>
      

      <dl>
        <dt><label for="fuel_type">Fuel type:</label></dt>
    		<dd>#{fuel_type_select}</dd>
      </dl>
      <dl>
        <dt><label for="fuel_sort">Fuel unit:</label></dt>
    		<dd>#{fuel_unit_select}</dd>
      </dl>
      <dl>
        <dt><label for="year">Year:</label></dt>
    		<dd><input type="text" id="year" name="vehicle[year]" value="#{h(@vehicle.year)}"></dd>
      </dl>
      
      <dl>
        <dt><label for="engine_power">Engine power:</label></dt>
    		<dd><input type="text" id="engine_power" name="vehicle[engine_power]" value="#{h(Double.toString(@vehicle.engine_power))}"> 
    		    #{engine_power_unit_select}
    		  </dd>
      </dl>
      <dl>
        <dt><label for="odometer">Odometer:</label></dt>
    		<dd><input type="text" id="odometer" name="vehicle[odometer]" value="#{h(Long.toString(@vehicle.odometer))}">
    		  #{odometer_unit_select}
    		  </dd>
      </dl>
      
      
      <dl>
        <dt><label for="tank_capacity">Tank capacity:</label></dt>
    		<dd><input type="text" id="tank_capacity" name="vehicle[tank_capacity]" value="#{h(Double.toString(@vehicle.tank_capacity))}"></dd>
      </dl>
      <dl>
        <dt><label for="license_number">License number:</label></dt>
    		<dd><input type="text" id="license_number" name="vehicle[license_number]" value="#{h(@vehicle.license_number)}"></dd>
      </dl>
      <dl>
        <dt><label for="note">Note:</label></dt>
    		<dd><input type="text" id="note" name="vehicle[note]" value="#{h(@vehicle.note)}"></dd>
      </dl>
     	<dl>
    		<dt>
    			<input type="submit" name="submit" value="#{@new ?'Create':'Update'}">
    		</dt>
    	</dl>
    </form>
    HTML
  end
  
  def show_erb
    <<-HTML
    <p>
      <b>Title:</b>
      #{h(Long.toString(@vehicle.maker_id))}
    </p>

    <p>
      <b>Type:</b>
      #{h(Long.toString(@vehicle.type_id))}
    </p>
    <p>
      <b>Maker:</b>
      #{h(Long.toString(@vehicle.maker_id))}
    </p>
    <p>
      <b>Model:</b>
      #{h(Long.toString(@vehicle.model_id))}
    </p>
    <p>
      <b>Exact model:</b>
      #{h(@vehicle.model_exact)}
    </p>
    <p>
      <b>Fuel type:</b>
      #{h(@vehicle.fuel_type.name)}
    </p>
    <p>
      <b>fuel sort:</b>
      #{h(@vehicle.fuel_unit)}
    </p>
    <p>
      <b>Year:</b>
      #{h(@vehicle.year)}
    </p>

    <p>
      <b>Engine power:</b>
      #{h(Double.toString(@vehicle.engine_power))}
    </p>

    <p>
      <b>Odometer:</b>
      #{h(Long.toString(@vehicle.odometer))}
    </p>

    <p>
      <b>Tank capacity:</b>
      #{h(Double.toString(@vehicle.tank_capacity))}
    </p>

    <p>
      <b>License number:</b>
      #{h(@vehicle.license_number)}
    </p>

    <p>
      <b>Note:</b>
      #{h(@vehicle.note)}
    </p>
    HTML
  end
  
  def list_erb 
  
    html = "<h2> My vehicles</h2>"
    if !@empty
    html = "
    <table>
      <tr>
        <th>Type</th>
    		<th>Maker</th>
    		<th>Model</th>
    		<th>Exact</th>
    		<th>&nbsp;</th>
    		<th>&nbsp;</th>
    		<th>&nbsp;</th>
      </tr>"
      
    @vehicles.each do |vehicle|
      html += "
    <tr>
      <td>#{h(vehicle.type.name)}</td>
    	<td>#{h(vehicle.maker.name)}</td>
    	<td>#{h(vehicle.model.name)}</td>
    	<td>#{h(vehicle.model_exact)}</td>
    	<td> <a class='button' href='/fueling/?vehicle=#{vehicle.id}'>fueling entries</a> </td>
    	<td> <a class='button' href='/vehicle/edit/#{vehicle.id}'>Edit</a> </td>
    	<td> <a class='button' href='/vehicle/remove/#{vehicle.id}'>Delete</a> </td>
    </tr>"
    end
    html += '</table>'
    end
    html += "<a class='button' href='/vehicle/new'>Add vehicle</a>"
  

  end
  #def_edb(show_erb, 'views/vehicle/show.html.erb')
  #def_edb(list_erb, 'views/vehicle/list.html.erb')
  #def_edb(edit_erb, 'views/vehicle/edit.html.erb')

end