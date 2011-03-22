import dubious.*
import ext.*
import models.*
import utils.*

class  VehicleController < PublicController
  
  def index
    if @vehicles = Vehicle.all.deleted(false).run
      @empty = false
    else
      @empty = true
    end
    list_erb    
  end
  
  def list_erb 
    html = "<h2>Vehicles</h2>"
    if !@empty
    html += "
    <table>
      <tr>
        <th>Type</th>
    		<th>Maker</th>
    		<th>Model</th>
    		<th>Exact</th>
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
    	<td> <a class='button' href='/stats/?vehicle=#{vehicle.id}'>stats</a> </td>
    </tr>"
      end
      html += '</table>'
    else
      html += "No vehicles"
    end
  end

  /*
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
*/
  
end