import dubious.*
import ext.*
import models.*
import utils.*

class  FuelingController < PublicController
  
  
  def index
    self.page_title = 'Obchodní podmínky'
    self.page_description = ''

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

    list_erb
  end
  
  
  def new
    @new = true
    @fueling = Fueling.blank
    self.page_title = 'Add/Edit Fueling entry'
    self.page_description = ''
    edit_erb
  end
  
  def edit
    @new = false
    if @vehicle = Vehicle.get(Integer.parseInt(params[:vehicle]))
      if @vehicle.user_id == user.id
        @fueling = Fueling.get(params.id)
        null
      else
        redirect_to :index
        null
      end  
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
    
    redirect_to '/fueling/?vehicle='+params[:vehicle]
  end 
  
  def remove
    @fueling = Fueling.get(params.id)
    @fueling.delete
    redirect_to '/fueling/?vehicle='+params[:vehicle]
  end  
  
  def show_erb
  
  end
  
  def list_erb
      html = "<h2> My fueling entries</h2>

      <div>
      	#{h(@vehicle.type.name)} <br>
      	#{h(@vehicle.maker.name)} <br>
      	#{h(@vehicle.model.name + ' ' + @vehicle.model_exact)}
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
      	<td> <a href='/fueling/edit/#{fe.id}?vehicle=#{params[:vehicle]}'>Edit</a> </td>
      	<td> <a href='/fueling/remove/#{fe.id}?vehicle=#{params[:vehicle]}'>Delete</a> </td>
      </tr>"
      end
      html += "</table>"
      null
      else
        html += "<div> No fueling entries </div>"
        null
      end
      html += "<a href='/fueling/new?vehicle=#{params[:vehicle]}'>Add fueling entry</a>"
      html
  end
  
  def edit_erb
     <<-HTML
    <h1>#{@new ? 'Add fueling entry' : 'Edit fueling entry'}</h1>

    <form method="post" action="/fueling/save/#{String.valueOf(@fueling.url_id)}?vehicle=#{params[:vehicle]}">

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
        <dt><label for="fuel_sort">fuel_unit:</label></dt>
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