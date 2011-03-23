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
      
    
    html = "<h2>Vehicles</h2>"
    
    html += "<h3>Filter</h3>
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
            <input type='submit' name='submit' value='Filter'>
            </form>"
    
    
    
    if !@empty
    html += "
    <table>
      <tr>
    		<th>Make</th>
    		<th>Model</th>
    		<th>Exact</th>
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
    </tr>"
      end
      html += '</table>'
    else
      html += "No vehicles"
    end
  end

  
end