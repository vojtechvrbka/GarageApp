import dubious.*
import ext.*
import models.*
import utils.*

class  FuelingController < PublicController
  
  
  def index
    vehicle_id = Integer.parseInt(params[:vehicle])
    if @vehicle = Vehicle.get(vehicle_id)  
      if Vehicle.get(vehicle_id).user_id == user.id
        if @fuelings = Fueling.all.vehicle_id(vehicle_id).sort(:date).run
          
              
          fuelings = Fueling.all.vehicle_id(@vehicle.id).sort(:date).run
          prev = Fueling.blank
          count = 0
          sum = 0.0
          fuelings.each do |f|
            if prev.odometer > 0    
              distance = f.odometer - prev.odometer
              sum += (f.quantity / distance) * 100  
              count += 1
            end
            prev = f
          end
          @consumption = Double.toString(sum/count)
          
          
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
      	Type: #{h(@vehicle.type.name)} <br>
      	Maker: #{h(@vehicle.maker.name)} <br>
      	Model: #{h(@vehicle.model.name + ' ' + @vehicle.model_exact)}<br>
      	Avg consumption #{@consumption}
      </div>"

      if !@empty
        html += "
        <table style='width:100%;'>
        <tr>
          <th>Date</th>
      		<th>Type</th>
      		<th>Odometer</th>
      		<th>Quantity</th>
      		<th>Price</th>
      		<th>Fuel consumption</th>
        </tr>"
        
        
        prev = Fueling.blank
        cons = 0.0
        @fuelings.each do |fe|
          d = TimeHelper.at(fe.date)
           if prev.odometer > 0    
              distance = fe.odometer - prev.odometer
              cons = double(int( (fe.quantity / distance) * 100 * 100 ))/100
            end
          html += "
          <tr>
            <td>#{d.month}/#{d.month_day}/#{d.year}</td>
          	<td>#{h(fe.type)}</td>
          	<td>#{h(Double.toString(fe.odometer))} Km</td>
          	<td>#{h(Double.toString(fe.quantity))}</td>
          	<td>#{h(Double.toString(fe.price))}</td>
          	<td>#{h(Double.toString(cons))} l/100 Km</td>
          	<td> <a class='button'  href='/fueling/edit/#{fe.id}?vehicle=#{params[:vehicle]}'>Edit</a> </td>
          	<td> <a class='button'  href='/fueling/remove/#{fe.id}?vehicle=#{params[:vehicle]}'>Delete</a> </td>
          </tr>"
          prev = fe
        end
        html += "</table>"
        null
      else
        html += "<div> No fueling entries </div>"
        null
      end
      html += "<a class='button'  href='/fueling/new?vehicle=#{params[:vehicle]}'>Add fueling entry</a>"
      html
  end
  
  def edit_erb
    
    type_select = Element.select('fueling[type]').
                   option("full", "Full").
                   option("partly_full", "Partly full").
                   option("first_fueling", "First fueling").
                   option("invalid", "Invalid").
                   value(@fueling.type).to_s
    
    fuel_unit_select = Element.select('fueling[fuel_unit]').
                             option("l", "l").
                             option("us.gal", "US.gal").
                             option("imp.gal", "Imp.gal").
                             value(@fueling.fuel_unit).to_s
                             
    price_currency_select  = Element.select('fueling[price_currency]').
                             option("usd", "USD").
                             option("eur", "EUR").
                             option("kc", "Kč").
                             value(@fueling.price_currency).to_s
              
              
                                                          
     <<-HTML
    <h1>#{@new ? 'Add fueling entry' : 'Edit fueling entry'}</h1>

    <form method="post" action="/fueling/save/#{String.valueOf(@fueling.url_id)}?vehicle=#{params[:vehicle]}">

      <dl>
        <dt><label for="date">Date:</label></dt>
    		<dd>
    		  <input type="text" class="date-field" id="date_to_human">
    		  <input type="hidden" id="date_to_ts"  name="fueling[date]" value="#{h(Long.toString(@fueling.date))}">	
    		</dd>
      </dl>
      <dl>
        <dt><label for="type">Type:</label></dt>
    		<dd>#{type_select}</dd>
      </dl>
      <dl>
        <dt><label for="odometer">Odometer:</label></dt>
    		<dd><input type="text" id="odometer" name="fueling[odometer]" value="#{h(Long.toString(@fueling.odometer))}"></dd>
      </dl>
      <dl>
        <dt><label for="quantity">Quantity:</label></dt>
    		<dd><input type="text" id="quantity" name="fueling[quantity]" value="#{h(Double.toString(@fueling.quantity))}">
    		  #{fuel_unit_select}
    		  </dd>
      </dl>

      <dl>
        <dt><label for="price">Price:</label></dt>
    		<dd><input type="text" id="price" name="fueling[price]" value="#{h(Double.toString(@fueling.price))}">  
    		  #{price_currency_select}
    		  </dd>
      </dl>
      <dl>
        <dt><label for="note">Note:</label></dt>
    		<dd><input type="text" id="note" name="fueling[note]" value="#{h(@fueling.note)}"></dd>
      </dl>
     	<dl>
    		<dt>
    			<input type="submit" name="submit" value=" #{@new ? 'Create' : 'Update'}">
    		</dt>
    	</dl>
    </form>
    <script>
    	$(function() 
      {
        console.log('yes');
        $('.date-field').each(function() {
          var ts_field = $('#'+this.id.replace('human', 'ts'))[0];
          ts_field.value = ts_field.value*1 + new Date().getTimezoneOffset()*60*1000;
          var dp = $(this).datepicker({
            altField: ts_field,
      			altFormat: '@',
            dateFormat: 'mm/dd/yy',
            firstDay: 0,
            /*
            onSelect: function(dateText) { 
              //ts_field.value = ts_field.value*1 - new Date().getTimezoneOffset()*60*1000;
            } 
            */
          });

          $(this.form).submit(function() {
              ts_field.value = ts_field.value*1 - new Date().getTimezoneOffset()*60*1000;
            })

          var date = new Date();
          date.setTime(ts_field.value);
          //console.log(ts_field);
          this.value = $.datepicker.formatDate('mm/dd/yy', date);

        })
    	});
    </script>
    HTML
  end

end