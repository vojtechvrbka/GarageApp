import dubious.*
import ext.*
import models.*
import utils.*

import java.lang.Math

class  NoteController < PublicController
  
  
  def index
    vehicle_id = Integer.parseInt(params[:vehicle])
    if @vehicle = Vehicle.get(vehicle_id)  
      if Vehicle.get(vehicle_id).user_id == user.id
        if @fuelings = Fueling.all.vehicle_id(vehicle_id).sort(:date).run                            
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
   #   if @vehicle.user_id == user.id
        @fueling = Fueling.get(params.id)
        null
  #    else
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
      f.type = Fueling.TYPE_COST
    #  f.quantity = 1
      
    if params.has(:action) && params[:action].equals(:delete)
      f.delete
      null
    else
      if params.multipart?
        f.update(params.multipart_for(:note))
      else
        f.update(params.for(:note))
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
      html = "<h2> My costs notes</h2>

      <div>
      	Type: #{h(@vehicle.type.name)} <br>
      	Maker: #{h(@vehicle.maker.name)} <br>
      	Model: #{h(@vehicle.model.name + ' ' + @vehicle.model_exact)}<br>
      </div>"

      if !@empty
        html += "
        <table style='width:100%;'>
        <tr>
          <th>Date</th>
      		<th>Odometer</th>
      		<th>Fueling</th>
      		<th>Price</th>
        </tr>"
        
        
        @fuelings.each do |n|
          d = TimeHelper.at(n.date)
          
          html += "
          <tr>
            <td>#{d.month}/#{d.month_day}/#{d.year}</td>
          	<td>#{h(Double.toString(n.odometer))} Km</td>
          	<td>#{h(n.note)}</td>
          	<td>#{h(Double.toString(n.price))}</td>
          	<td> <a class='button'  href='/costs_notes/edit/#{n.id}?vehicle=#{params[:vehicle]}'>Edit</a> </td>
          	<td> <a class='button'  href='/costs_notes/remove/#{n.id}?vehicle=#{params[:vehicle]}'>Delete</a> </td>
          </tr>"
        end
        html += "</table>"
        null
      else
        html += "<div> No costs or notes </div>"
        null
      end
      html += "<a class='button'  href='/costs_notes/new?vehicle=#{params[:vehicle]}'>Add fueling entry</a>"
      html
  end
  
  def edit_erb
    

    price_currency_select  = Element.select('note[price_currency]').
                             option("usd", "USD").
                             option("eur", "EUR").
                             option("kc", "Kč").
                             value(@fueling.price_currency).to_s
    type_select =  Element.select('note[cost_type]').
                            option("1", "Maintenance").
                            option("2", "Repair").
                            option("3", "Change tires").
                            option("4", "Change oil").
                            option("5", "Insurance").
                            option("6", "Tax").
                            option("7", "Supervisory board").
                            option("8", "Tuning").
                            option("9", "Accessories").
                            option("10", "Purchase price").
                            option("11", "Miscellaneous").
                            option("12", "Care").
                            option("13", "Payment").
                            option("14", "Registration").
                            option("15", "Financing").
                            option("16", "Refund").
                            option("17", "Fine").
                            option("18", "Parking tax").
                            option("19", "Toll").
                            option("20", "Spare parts").
                            value(@fueling.cost_type).to_s
                                      
     <<-HTML
    <h1>#{@new ? 'Add note/cost entry' : 'Edit note/cost entry'}</h1>

    <form method="post" action="/costs_notes/save/#{String.valueOf(@fueling.url_id)}?vehicle=#{params[:vehicle]}">
      <dl>
        <dt><label for="date">Date:</label></dt>
    		<dd>
    		  <input type="text" class="date-field" id="date_to_human">
    		  <input type="hidden" id="date_to_ts"  name="note[date]" value="#{h(Long.toString(@fueling.date))}">	
    		</dd>
      </dl>
      <dl>
        <dt><label for="odometer">Odometer:</label></dt>
    		<dd><input type="text" id="odometer" name="note[odometer]" value="#{h(Long.toString(@fueling.odometer))}"></dd>
      </dl>  
      <dl>
        <dt><label for="type">Type:</label></dt>
    		<dd>#{type_select}</dd>
      </dl>

      <dl>
        <dt><label for="price">Price:</label></dt>
    		<dd><input type="text" id="price" name="note[price]" value="#{h(Double.toString(@fueling.price))}">  
    		  #{price_currency_select}
    		  </dd>
      </dl>
      
      <dl>
        <dt><label for="note">Note:</label></dt>
    		<dd><textarea id="note" name="note[note]" style="width:300px;height:80px;">#{h(@fueling.note)}</textarea></dd>
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