import dubious.*
import ext.*
import models.*
import utils.*

import java.lang.Math

class  FuelingController < PublicController
  
  
  def index
    vehicle_id = Integer.parseInt(params[:vehicle])
   
    if @vehicle = Vehicle.get(vehicle_id)  
    #  if Vehicle.get(vehicle_id).user_id == user.id
        if @fuelings = Fueling.all.vehicle_id(vehicle_id).sort(:date).run
                        
          fuelings = Fueling.all.vehicle_id(@vehicle.id).sort(:date).run
          prev = Fueling.blank
          count = 0
          sum = 0.0
          fuelings.each do |f|
              sum += (f.quantity / f.trip) * 100  
              count += 1
            prev = f
          end
          @consumption = Double.toString(sum/count)          
          
          @emtry = false
        else
          @empty = true
        end        
        
        
        null
 #     else
        # not my vehicle
  #      redirect_to :index        
  #      null
  #    end
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
    # if @vehicle.user_id == user.id
        @fueling = Fueling.get(params.id)
        null
   #   else
  #      redirect_to :index
  #      null
  #    end  
    else
      redirect_to :index
      null
    end
    edit_erb
  end  
  
  def save
    if params.peek == null || params.peek.equals("new")
      f = Fueling.new
      f.vehicle_id = Integer.parseInt(params[:vehicle])
      f
    else      
      f = Fueling.get(params.id)
    end
      f.type = Fueling.TYPE_FUELING
    if params.has(:action) && params[:action].equals(:delete)
      f.delete
      null
    else
      if params.multipart?
        f.update(params.multipart_for(:fueling))
      else
        f.update(params.for(:fueling))
      end
      f.save      
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
      	Make: #{h(@vehicle.maker.name)} <br>
      	Model: #{h(@vehicle.model.name + ' ' + @vehicle.model_exact)}<br>
      	Avg consumption #{@consumption}
      </div>"

      if !@empty
        html += "
        <style>
          tr.fueling td { color:blue; }
          tr.cost td { color:red;  }
        </style>
        <table style='width:100%;'>
        <tr>
          <th>Date</th>
      	
      		<th>Odometer</th>
      		<th>Quantity</th>
      		<th>Price</th>
      		<th>Fuel consumption</th>
        </tr>"
        
        
        prev = Fueling.blank
        cons = 0.0
        @fuelings.each do |f|
          d = TimeHelper.at(f.date)
          cons = double(int( (f.quantity / f.trip) * 100 * 100 ))/100
          
          if f.type == Fueling.TYPE_FUELING
            html += "
            <tr class='fueling'>
              <td>#{d.print_date}</td>          	
            	<td>#{h(Long.toString(f.odometer))} Km</td>
            	<td>#{h(Double.toString(f.quantity))} l</td>
            	<td>#{h(Double.toString(f.price))} #{f.price_currency}</td>
            	<td>#{h(Double.toString(cons))} l/100 Km</td>
            	<td> <a class='button'  href='/fueling/edit/#{f.id}?vehicle=#{params[:vehicle]}'>Edit</a> </td>
            	<td> <a class='button'  href='/fueling/remove/#{f.id}?vehicle=#{params[:vehicle]}'>Delete</a> </td>
            </tr>"
          elsif f.type == Fueling.TYPE_COST
              html += "
              <tr class='cost'>
                <td>#{d.print_date}</td>
              	<td>#{h(Long.toString(f.odometer))} Km</td>
              	<td></td>
              	<td>#{h(Double.toString(f.price))} #{f.price_currency}</td>
              	<td></td>
              	<td> <a class='button'  href='/costs_notes/edit/#{f.id}?vehicle=#{params[:vehicle]}'>Edit</a> </td>
              	<td> <a class='button'  href='/costs_notes/remove/#{f.id}?vehicle=#{params[:vehicle]}'>Delete</a> </td>
              </tr>"
          end
          
          prev = f
        end
        html += "</table>"
        null
      else
        html += "<div> No fueling entries </div>"
        null
      end
      html += "<a class='button'  href='/fueling/new?vehicle=#{params[:vehicle]}'>Add fueling entry</a> "
      html += "<a class='button'  href='/costs_notes/new?vehicle=#{params[:vehicle]}'>Add costs/note entry</a> "
      html
      
  end
  
  def edit_erb
    
    type_select = Element.select('fueling[fueling_type]').
                   option( Fueling.FUELING_TYPE_FULL, "Full").
                   option( Fueling.FUELING_TYPE_PARTLY_FULL, "Partly full").
                   option( Fueling.FUELING_TYPE_FIRST, "First fueling").
                   option( Fueling.FUELING_TYPE_INVALID, "Invalid").
                   value(@fueling.fueling_type).to_s
                                      
    fuel_unit_select = Element.select('fueling[quantity_unit]').
                             option("l", "l").
                             option("g_us", "Gallon (US)").
                             option("g_imp", "Gallon (Imperial)").
                             value(@fueling.quantity_unit).to_s
                             
    price_currency_select  = Element.select('fueling[price_currency]').
                             option("USD", "USD").
                             option("EUR", "EUR").
                             option("KC", "Kč").
                             value(@fueling.price_currency).to_s
              
    tires_summer_checked = @fueling.tires == Fueling.TIRES_SUMMER ? 'checked="checked"' : '' 
    tires_winter_checked = @fueling.tires == Fueling.TIRES_WINTER ? 'checked="checked"' : ''  
    tires_all_year_checked =  @fueling.tires == Fueling.TIRES_ALL_YEAR ? 'checked="checked"' : ''            

    driving_moderate_checked =  @fueling.driving == Fueling.DRIVING_MODERATE ? 'checked="checked"' : ''                                                             
    driving_normal_checked =  @fueling.driving == Fueling.DRIVING_NORMAL ? 'checked="checked"' : ''                                                             
    driving_fast_checked =  @fueling.driving == Fueling.DRIVING_FAST ? 'checked="checked"' : ''                                                                                                                     
            
    route_motorway_checked =  @fueling.route_motorway == 1 ? 'checked="checked"' : ''
    route_city_checked =  @fueling.route_city == 1 ? 'checked="checked"' : ''
    route_country_roads_checked =  @fueling.route_country_roads == 1 ? 'checked="checked"' : ''
            
    ac_checked = @fueling.ac == 1 ? 'checked="checked"' : ''
    trailer_checked = @fueling.trailer == 1 ? 'checked="checked"' : ''
                                                        
     <<-HTML
    <h1>#{@new ? 'Add fueling entry' : 'Edit fueling entry'}</h1>

    <form method="post" action="/fueling/save/#{String.valueOf(@fueling.url_id)}?vehicle=#{params[:vehicle]}">
      <h3> Basic data </h3>
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
    		<dd><textarea id="note" name="fueling[note]" style="width:200px;height:40px;">#{h(@fueling.note)}</textarea></dd>
      </dl>
     	
     	<h3 style="clear:left;padding-top:20px;"> Conditions </h3>

     	<dl>
     	  <dt>Tires</dt>
     	  <dd>
     	    <input type="radio" name="fueling[tires]" value="#{Fueling.TIRES_SUMMER}" id="tires_summer" #{tires_summer_checked}> 
     	      <label for="tires_summer"> Summer </label> &nbsp;
     	    <input type="radio" name="fueling[tires]" value="#{Fueling.TIRES_WINTER}" id="tires_winter" #{tires_winter_checked}> 
     	      <label for="tires_winter"> Winter </label> &nbsp; 
     	    <input type="radio" name="fueling[tires]" value="#{Fueling.TIRES_ALL_YEAR}" id="tires_all_year" #{tires_all_year_checked}> 
     	      <label for="tires_all_year"> All-year </label> &nbsp; 
     	  </dd>
   	  </dl>

     	<dl>
     	  <dt>Driving style</dt>
     	  <dd>
     	    <input type="radio" name="fueling[driving]" value="#{Fueling.DRIVING_MODERATE}" id="driving_moderate" #{driving_moderate_checked}> 
     	      <label for="driving_moderate"> Moderate </label>
     	    <input type="radio" name="fueling[driving]" value="#{Fueling.DRIVING_NORMAL}" id="driving_normal" #{driving_normal_checked}> 
     	      <label for="driving_normal"> Normal </label>
     	    <input type="radio" name="fueling[driving]" value="#{Fueling.DRIVING_FAST}" id="driving_fast" #{driving_fast_checked}> 
     	      <label for="driving_fast"> Fast </label>
     	  </dd>
   	  </dl>
   	  
      <dl>
     	  <dt>Route(s)</dt>
     	  <dd>
     	    <input type="checkbox" name="fueling[route_motorway]" id="route_motorway" value="1" #{route_motorway_checked}> <label for="route_motorway"> Motor-way </label>
     	    <input type="checkbox" name="fueling[route_city]" id="route_city" value="1" #{route_city_checked}> <label for="route_city"> City </label>
     	    <input type="checkbox" name="fueling[route_country_roads]" id="route_country_roads" value="1" #{route_country_roads_checked}> <label for="route_country_roads"> Country roads </label>
     	  </dd>
   	  </dl>
   	  
      <dl>
     	  <dt>Extras</dt>
     	  <dd>
     	     <input type="checkbox" name="fueling[ac]" id="ac" value="1" #{ac_checked}> <label for="ac"> A/C </label>
       	    <input type="checkbox" name="fueling[trailer]" id="trailer" value="1" #{trailer_checked}> <label for="trailer"> Trailer </label>
     	  </dd>
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