import dubious.*
import ext.*
import models.*
import java.util.regex.*
import java.util.ArrayList

import org.apache.commons.codec.binary.*

import com.google.appengine.api.users.UserService
import com.google.appengine.api.users.UserServiceFactory

import com.google.appengine.api.blobstore.BlobKey
import com.google.appengine.api.blobstore.BlobstoreService
import com.google.appengine.api.blobstore.BlobstoreServiceFactory


class AdminController < MyController 
  def index
    redirect_to :vehicle
  end
  
  def vehicle
    c = AdminVehicleController.new
    c.execute(params)    
    @page_content = params.content
    main_erb
  end
 
  def fueling
    c = AdminFuelingController.new
    c.execute(params)    
    @page_content = params.content
    main_erb
  end
 
  def fuel_type
    c = AdminFuelTypeController.new
    c.execute(params)    
    @page_content = params.content
    main_erb
  end
 
  def vehicle_model
    c = AdminVehicleModelController.new
    c.execute(params)    
    @page_content = params.content
    main_erb
  end

  def vehicle_maker
    c = AdminVehicleMakerController.new
    c.execute(params)    
    @page_content = params.content
    main_erb
  end

  def vehicle_type
    c = AdminVehicleTypeController.new
    c.execute(params)    
    @page_content = params.content
    main_erb
  end

  
  def login
    login_erb
  end
  
  def before_action
    @page_title = "MotoCash Admin"
    @userline = ''
    
    if request.getUserPrincipal() != null &&
       (UserServiceFactory.getUserService().isUserAdmin() || request.getUserPrincipal().getName.equals('webkseft@gmail.com'))
      logout = UserServiceFactory.getUserService().createLogoutURL(request.getRequestURI)
      @userline = request.getUserPrincipal().getName +
          ' | <a href="'+logout+'">Sign out</a>'
    else
      self.action = :login
    end
  end
  
  def_edb(main_erb, 'views/layouts/admin.html.erb')
  def_edb(login_erb, 'views/layouts/admin_login.html.erb')
end



### Vehicle controller


class  AdminVehicleController < AdminController
  
  def index
    @empty = false
    begin
      @vehicles = Vehicle.all.run
    rescue
      @empty = true
    end
    list_erb
  end
  
  def new
    @new = true
    @vehicle = Vehicle.blank
    edit_erb
  end
  
  def edit
    @new = false
    if @vehicle = Vehicle.get(params.id)
      edit_erb
    else
      redirect_to :index
    end
  end  
  
  def save
    if params.peek == null || params.peek.equals("new")
      v = Vehicle.new
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
    <<-HTML
    <h1>#{@new ? 'Create vehicle' : 'Edit vehicle'}</h1>

    <form method="post" action="/admin/vehicle/save/#{String.valueOf(@vehicle.url_id)}">

      <dl>
        <dt><label for="type">Type:</label></dt>
    		<dd><input type="text" id="type" name="vehicle[type_id]" value="#{h(Long.toString(@vehicle.type_id))}"></dd>
      </dl>
      <dl>
        <dt><label for="maker">Maker:</label></dt>
    		<dd><input type="text" id="maker" name="vehicle[maker_id]" value="#{h(Long.toString(@vehicle.maker_id))}"></dd>
      </dl>
      <dl>
        <dt><label for="model">Model:</label></dt>
    		<dd><input type="text" id="model" name="vehicle[model_id]" value="#{h(Long.toString(@vehicle.model_id))}"></dd>
      </dl>
      <dl>
        <dt><label for="model_exact">Model exact:</label></dt>
    		<dd><input type="text" id="model_exact" name="vehicle[model_exact]" value="#{h(@vehicle.model_exact)}"></dd>
      </dl>
      <dl>
        <dt><label for="fuel_type">Fuel type:</label></dt>
    		<dd><input type="text" id="fuel_type" name="vehicle[fuel_type_id]" value="#{h(Long.toString(@vehicle.fuel_type_id))}"></dd>
      </dl>
      <dl>
        <dt><label for="fuel_sort">Fuel unit:</label></dt>
    		<dd><input type="text" id="fuel_sort" name="vehicle[fuel_unit]" value="#{h(@vehicle.fuel_unit )}"></dd>
      </dl>
      <dl>
        <dt><label for="year">Year2:</label></dt>
    		<dd><input type="text" id="year" name="vehicle[year]" value="#{h(@vehicle.year)}"></dd>
      </dl>
      <dl>
        <dt><label for="engine_power">Engine power:</label></dt>
    		<dd><input type="text" id="engine_power" name="vehicle[engine_power]" value="#{h(Double.toString(@vehicle.engine_power))}"></dd>
      </dl>
      <dl>
        <dt><label for="odometer">Odometer:</label></dt>
    		<dd><input type="text" id="odometer" name="vehicle[odometer]" value="#{h(Long.toString(@vehicle.odometer))}"></dd>
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
      #{h(Long.toString(@vehicle.fuel_type_id))}
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
    		<th>&nbsp;</th>
      </tr>"
      
    @vehicles.each do |vehicle|
      html += "
    <tr>
      <td>#{h(Long.toString(vehicle.type_id))}</td>
    	<td>#{h(Long.toString(vehicle.maker_id))}</td>
    	<td>#{h(Long.toString(vehicle.model_id))}</td>
    	<td>#{h(vehicle.model_exact)}</td>
    	<td> <a href='/admin/fueling/?vehicle=#{vehicle.id}'>fueling entries</a> </td>
    	<td> <a href='/admin/vehicle/edit/#{vehicle.id}'>Edit</a> </td>
    	<td> <a href='/admin/vehicle/remove/#{vehicle.id}'>Delete</a> </td>
    </tr>"
    end
    html += '</table>'
    end
    html += "<a href='/admin/vehicle/new'>Add vehicle</a>"
  

  end
  #def_edb(show_erb, 'views/vehicle/show.html.erb')
  #def_edb(list_erb, 'views/vehicle/list.html.erb')
  #def_edb(edit_erb, 'views/vehicle/edit.html.erb')

end





class  AdminFuelingController < AdminController
  
  
  def index

    if params.has(:vehicle)
      vehicle_id = Integer.parseInt(params[:vehicle])
    
    if @vehicle = Vehicle.get(vehicle_id)  
      if @fuelings = Fueling.all.vehicle_id(vehicle_id).run
        @emtry = false
      else
        @empty = true
      end        
      null
    else 
      # vehicle not exists
      redirect_to :index
      null
    end

    end

    list_erb
  end
  
  
  def new
    @new = true
    @fueling = Fueling.blank
    edit_erb
  end
  
  def edit
    @new = false
    if @vehicle = Vehicle.get(Integer.parseInt(params[:vehicle]))
      @fueling = Fueling.get(params.id)
      null
    else
      redirect_to :index
      null
    end
    edit_erb
  end  
  
  def save
    if params.peek == null || params.peek.equals("new")
      fe = Fueling.new
      fe.vehicle_id = Integer.parseInt(params[:vehicle])
      fe
    else      
      fe = Fueling.get(params.id)
    end
      
    if params.has(:action) && params[:action].equals(:delete)
      fe.delete
      null
    else
      if params.multipart?
        fe.update(params.multipart_for(:fueling))
      else
        fe.update(params.for(:fueling))
      end
      fe.save      
      null
    end
    
    redirect_to '/admin/fueling/?vehicle='+params[:vehicle]
  end 
  
  def remove
    @fueling = Fueling.get(params.id)
    @fueling.delete
    redirect_to '/admin/fueling/?vehicle='+params[:vehicle]
  end  
  
  def show_erb
  
  end
  
  def list_erb
      html = "<h2> My fueling entries</h2>

      <div>
      	#{h(Long.toString(@vehicle.type_id))} <br>
      	#{h(Long.toString(@vehicle.maker_id))} <br>
      	#{h(Long.toString(@vehicle.model_id) + ' ' + @vehicle.model_exact)}
      </div>"

      if !@empty
        html += "
        <table>
        <tr>
          <th>Date</th>
      		<th>Type</th>
      		<th>Odometer</th>
      		<th>Quantity</th>
      		<th>Fuel Sort</th>
      		<th>Price</th>
        </tr>"
      @fuelings.each do |fe|
      html += "
      <tr>
        <td>#{h(Long.toString(fe.date))}</td>
      	<td>#{h(fe.type)}</td>
      	<td>#{h(Double.toString(fe.odometer))}km</td>
      	<td>#{h(Double.toString(fe.quantity))}</td>
      	<td>#{h(fe.fuel_unit)}</td>
      	<td>#{h(Double.toString(fe.price) + ' ' + fe.price_currency)}</td>
      	<td> <a href='/admin/fueling/edit/#{fe.id}?vehicle=#{params[:vehicle]}'>Edit</a> </td>
      	<td> <a href='/admin/fueling/remove/#{fe.id}?vehicle=#{params[:vehicle]}'>Delete</a> </td>
      </tr>"
      end
      html += "</table>"
      null
      else
        html += "<div> No fueling entries </div>"
        null
      end
      html += "<a href='/admin/fueling/new?vehicle=#{params[:vehicle]}'>Add fueling entry</a>"
      html
  end
  
  def edit_erb
     <<-HTML
    <h1>#{@new ? 'Add fueling entry' : 'Edit fueling entry'}</h1>

    <form method="post" action="/admin/fueling/save/#{String.valueOf(@fueling.url_id)}?vehicle=#{params[:vehicle]}">

      <dl>
        <dt><label for="date">date:</label></dt>
    		<dd><input type="text" id="date" name="fueling[date]" value="#{h(Long.toString(@fueling.date))}"></dd>
      </dl>
      <dl>
        <dt><label for="type">type:</label></dt>
    		<dd><input type="text" id="type" name="fueling[type]" value="#{h(@fueling.type)}"></dd>
      </dl>
      <dl>
        <dt><label for="odometer">odometer:</label></dt>
    		<dd><input type="text" id="odometer" name="fueling[odometer]" value="#{h(Long.toString(@fueling.odometer))}"></dd>
      </dl>
      <dl>
        <dt><label for="quantity">quantity:</label></dt>
    		<dd><input type="text" id="quantity" name="fueling[quantity]" value="#{h(Double.toString(@fueling.quantity))}"></dd>
      </dl>
      <dl>
        <dt><label for="fuel_sort">fuel_sort:</label></dt>
    		<dd><input type="text" id="fuel_sort" name="fueling[fuel_unit]" value="#{h(@fueling.fuel_unit)}"></dd>
      </dl>
      <dl>
        <dt><label for="price">price:</label></dt>
    		<dd><input type="text" id="price" name="fueling[price]" value="#{h(Double.toString(@fueling.price))}"></dd>
      </dl>
      <dl>
        <dt><label for="price_currency">price_currency:</label></dt>
    		<dd><input type="text" id="price_currency" name="fueling[price_currency]" value="#{h(@fueling.price_currency)}"></dd>
      </dl>
      <dl>
        <dt><label for="note">note:</label></dt>
    		<dd><input type="text" id="note" name="fueling[note]" value="#{h(@fueling.note)}"></dd>
      </dl>
     	<dl>
    		<dt>
    			<input type="submit" name="submit" value=" #{@new ? 'Create' : 'Update'}">
    		</dt>
    	</dl>
    </form>


    HTML
  end
  
  #def_edb(show_erb, 'views/fueling_entry/show.html.erb')
  #def_edb(list_erb, 'views/fueling_entry/list.html.erb')
  #def_edb(edit_erb, 'views/fueling_entry/edit.html.erb')

end









class  AdminVehicleMakerController < AdminController
  
  
  def index
  
    if @vehicle_makers = VehicleMaker.all.run
      @empty = false
    else
      @empty = true
    end
    list_erb
  end
  
  def new
    @new = true
    @types = VehicleType.all.run
    @vehicle_maker = VehicleMaker.blank
    edit_erb
  end
  
  def edit
    @new = false
    @types = VehicleType.all.run
    if @vehicle_maker = VehicleMaker.get(params.id)
      edit_erb
    else
      redirect_to :index
    end
  end  
  
  def save
    if params.peek == null || params.peek.equals("new")
      v = VehicleMaker.new
      v
    else      
      v = VehicleMaker.get(params.id)
    end
    
    if params.has(:action) && params[:action].equals(:delete)
      v.delete
      null
    else
      if params.multipart?
        v.update(params.multipart_for('vehicle_maker'))
      else
        v.update(params.for(:vehicle_maker))
      end
      v.save      
      null
    end
    
    redirect_to :index
  end 
  
  def remove
    @vehicle_maker = VehicleMaker.get(params.id)
    @vehicle_maker.delete
    redirect_to :index
  end  
  
  def edit_erb
    type_select = "<select name='vehicle_maker[type_id]'>"
    @types.each do |type|
      selected = ( type.id == @vehicle_maker.type_id ? 'selected="selected"' : '');
      type_select += "<option value='#{type.id}' #{selected}>#{type.name}</option>"
    end
    type_select += "</select>"
    <<-HTML
    <h1>#{@new ? 'Create vehicle maker' : 'Edit vehicle maker'}</h1>

    <form method="post" action="/admin/vehicle_maker/save/#{String.valueOf(@vehicle_maker.url_id)}">
      <dl>
        <dt><label for="type">Type:</label></dt>
    		<dd>#{type_select}</dd>
      </dl>
      
      <dl>
        <dt><label for="name">Name:</label></dt>
    		<dd><input type="text" id="name" name="vehicle_maker[name]" value="#{h(@vehicle_maker.name)}"></dd>
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
      #{h(@vehicle_maker.name)}
    </p>
    HTML
  end
  
  def list_erb 
  
    html = "<h2>Vehicle makers</h2>"
    if !@empty
    html = "
    <table>
      <tr>
        <th>Name</th>
    		<th>&nbsp;</th>
    		<th>&nbsp;</th>
    		<th>&nbsp;</th>
      </tr>"
      
    @vehicle_makers.each do |vehicle_maker|
      html += "
    <tr>
      <td>#{h(vehicle_maker.name)}</td>
      <td> <a href='/admin/vehicle_model/?maker=#{vehicle_maker.id}'>Models</a> </td>
    	<td> <a href='/admin/vehicle_maker/edit/#{vehicle_maker.id}'>Edit</a> </td>
    	<td> <a href='/admin/vehicle_maker/remove/#{vehicle_maker.id}'>Delete</a> </td>
    </tr>"
    end
    html += '</table>'
    end
    html += "<a href='/admin/vehicle_maker/new'>Add vehicle maker</a><br>"
  

  end
  #def_edb(show_erb, 'views/vehicle/show.html.erb')
  #def_edb(list_erb, 'views/vehicle/list.html.erb')
  #def_edb(edit_erb, 'views/vehicle/edit.html.erb')

end



class  AdminVehicleTypeController < AdminController
  
  
  def index
  
    if @vehicle_types = VehicleType.all.run
      @empty = false
    else
      @empty = true
    end
    list_erb
  end
  
  def new
    @new = true
    @vehicle_type = VehicleType.blank
    edit_erb
  end
  
  def edit
    @new = false
    if @vehicle_type = VehicleType.get(params.id)
      edit_erb
    else
      redirect_to :index
    end
  end  
  
  def save
    if params.peek == null || params.peek.equals("new")
      v = VehicleType.new
      v
    else      
      v = VehicleType.get(params.id)
    end
    
    if params.has(:action) && params[:action].equals(:delete)
      v.delete
      null
    else
      if params.multipart?
        v.update(params.multipart_for('vehicle_type'))
      else
        v.update(params.for(:vehicle_type))
      end
      v.save      
      null
    end
    
    redirect_to :index
  end 
  
  def remove
    @vehicle_type = VehicleType.get(params.id)
    @vehicle_type.delete
    redirect_to :index
  end  
  
  def edit_erb
    <<-HTML
    <h1>#{@new ? 'Create vehicle type' : 'Edit vehicle type'}</h1>

    <form method="post" action="/admin/vehicle_type/save/#{String.valueOf(@vehicle_type.url_id)}">

      <dl>
        <dt><label for="name">Name:</label></dt>
    		<dd><input type="text" id="name" name="vehicle_type[name]" value="#{h(@vehicle_type.name)}"></dd>
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
      #{h(@vehicle_type.name)}
    </p>
    HTML
  end
  
  def list_erb 
  
    html = "<h2>Vehicle types</h2>"
    if !@empty
    html = "
    <table>
      <tr>
        <th>Name</th>
    		<th>&nbsp;</th>
    		<th>&nbsp;</th>
      </tr>"
      
    @vehicle_types.each do |vehicle_type|
      html += "
    <tr>
      <td>#{h(vehicle_type.name)}</td>
    	<td> <a href='/admin/vehicle_type/edit/#{vehicle_type.id}'>Edit</a> </td>
    	<td> <a href='/admin/vehicle_type/remove/#{vehicle_type.id}'>Delete</a> </td>
    </tr>"
    end
    html += '</table>'
    end
    html += "<a href='/admin/vehicle_type/new'>Add vehicle type</a><br>"

  end

end

class  AdminFuelTypeController < AdminController
  
  
  def index
  
    if @fuel_types = FuelType.all.run
      @empty = false
    else
      @empty = true
    end
    list_erb
  end
  
  def new
    @new = true
    @fuel_type = FuelType.blank
    edit_erb
  end
  
  def edit
    @new = false
    if @fuel_type = FuelType.get(params.id)
      edit_erb
    else
      redirect_to :index
    end
  end  
  
  def save
    if params.peek == null || params.peek.equals("new")
      v = FuelType.new
      v
    else      
      v = FuelType.get(params.id)
    end
    
    if params.has(:action) && params[:action].equals(:delete)
      v.delete
      null
    else
      if params.multipart?
        v.update(params.multipart_for('fuel_type'))
      else
        v.update(params.for(:fuel_type))
      end
      v.save      
      null
    end
    
    redirect_to :index
  end 
  
  def remove
    @fuel_type = FuelType.get(params.id)
    @fuel_type.delete
    redirect_to :index
  end  
  
  def edit_erb
    <<-HTML
    <h1>#{@new ? 'Create fuel type' : 'Edit fuel type'}</h1>

    <form method="post" action="/admin/fuel_type/save/#{String.valueOf(@fuel_type.url_id)}">

      <dl>
        <dt><label for="name">Name:</label></dt>
    		<dd><input type="text" id="name" name="fuel_type[name]" value="#{h(@fuel_type.name)}"></dd>
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
      #{h(@fuel_type.name)}
    </p>
    HTML
  end
  
  def list_erb 
  
    html = "<h2>Fuel types</h2>"
    if !@empty
    html = "
    <table>
      <tr>
        <th>Name</th>
    		<th>&nbsp;</th>
    		<th>&nbsp;</th>
      </tr>"
      
    @fuel_types.each do |fuel_type|
      html += "
    <tr>
      <td>#{h(fuel_type.name)}</td>
    	<td> <a href='/admin/fuel_type/edit/#{fuel_type.id}'>Edit</a> </td>
    	<td> <a href='/admin/fuel_type/remove/#{fuel_type.id}'>Delete</a> </td>
    </tr>"
    end
    html += '</table>'
    end
    html += "<a href='/admin/fuel_type/new'>Add vehicle type</a><br>"

  end

end



class  AdminVehicleModelController < AdminController
  
  
  def index
     if params.has(:maker)
        maker_id = Integer.parseInt(params[:maker])

      if @vehicle_maker = VehicleMaker.get(maker_id)  
        if @vehicle_models = VehicleModel.all.maker_id(maker_id).run
          @emtry = false
        else
          @empty = true
        end        
        null
      else 
        # vehicle not exists
        redirect_to :index
        null
      end
    end
    list_erb
  end
  
  def new
    @new = true
    @vehicle_model = VehicleModel.blank
    edit_erb
  end
  
  def edit
    @new = false
    if @vehicle_model = VehicleModel.get(params.id)
      edit_erb
    else
      redirect_to :index
    end
  end  
  
  def save
    if params.peek == null || params.peek.equals("new")
      v = VehicleModel.new
      v.maker_id = Integer.parseInt(params[:maker])
      v
    else      
      v = VehicleModel.get(params.id)
    end
    
    if params.has(:action) && params[:action].equals(:delete)
      v.delete
      null
    else
      if params.multipart?
        v.update(params.multipart_for('vehicle_model'))
      else
        v.update(params.for(:vehicle_model))
      end
      v.save      
      null
    end
    
    redirect_to '/admin/vehicle_model/?maker='+params[:maker]
  end 
  
  def remove
    @vehicle_model = VehicleModel.get(params.id)
    @vehicle_model.delete
    redirect_to '/admin/vehicle_model/?maker='+params[:maker]
  end  
  
  def edit_erb
    <<-HTML
    <h1>#{@new ? 'Create vehicle model' : 'Edit vehicle model'}</h1>

    <form method="post" action="/admin/vehicle_model/save/#{String.valueOf(@vehicle_model.url_id)}?maker=#{params[:maker]}">

      <dl>
        <dt><label for="name">Name:</label></dt>
    		<dd><input type="text" id="name" name="vehicle_model[name]" value="#{h(@vehicle_model.name)}"></dd>
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
      #{h(@vehicle_model.name)}
    </p>
    HTML
  end
  
  def list_erb 
  
    html = "<h2>Vehicle models</h2>"
    if !@empty
    html = "
    <table>
      <tr>
        <th>Name</th>
    		<th>&nbsp;</th>
    		<th>&nbsp;</th>
      </tr>"
      
    @vehicle_models.each do |vehicle_model|
      html += "
    <tr>
      <td>#{h(vehicle_model.name)}</td>
    	<td> <a href='/admin/vehicle_model/edit/#{vehicle_model.id}'>Edit</a> </td>
    	<td> <a href='/admin/vehicle_model/remove/#{vehicle_model.id}'>Delete</a> </td>
    </tr>"
    end
    html += '</table>'
    end
    html += "<a href='/admin/vehicle_model/new?maker=#{params[:maker]}'>Add vehicle model</a><br>"
  

  end
  #def_edb(show_erb, 'views/vehicle/show.html.erb')
  #def_edb(list_erb, 'views/vehicle/list.html.erb')
  #def_edb(edit_erb, 'views/vehicle/edit.html.erb')

end






















