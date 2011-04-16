import ext.*
import models.*
import java.util.*
import domain.*

import org.jsoup.Jsoup;
import org.jsoup.helper.Validate;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

class SpritmonitorImportTask < Task

  def run
    if st = Setting.all.first
      null
    else
      st = Setting.new
      st.spritmonitor = 100000
      null
    end
    
    if st.spritmonitor > 101000
      return 
    end
    
    puts 'import vehicles '
    imp = 0
    rows = 0
    while imp < 10 and rows < 100
      st.spritmonitor = st.spritmonitor + 1
      ret = import_vehicle(int(st.spritmonitor))
      if ret.equals('true')
        imp+=1
        st.save    
      end
      rows += 1
    end
    
    
  end



  def import_vehicle(sprit_id:int) 
    
     url = "http://www.spritmonitor.de/en/detail/#{sprit_id}.html"
     begin
       doc = Jsoup.connect(url).get();
     rescue 
       return "false"
     end
      puts sprit_id
    
     # Ford - Focus - Focus II Turnier 1.6 TDCi
     # Diesel, year 2006, 66 kW (90 PS), manual User: ralf1982 - f?hrt immer mit Abblendlicht - im Sommer Alufelgen mit Michelin Energy Safer 195/65 R15
       if doc.getElementsByTag("h1").first.text.equals('Error')
         return "false"
       end

       details = doc.getElementById("vehicledetails")
       h1 = details.getElementsByTag("h1").first.text
       titles = h1.split(' - ')
       info = details.text.replace(h1,'').trim.split(', ')


       vehicle = Vehicle.new
       vehicle.type = Vehicle.TYPE_AUTOMOBILE
       vehicle.spritmonitor_id = sprit_id
     
       # vyrobce
       begin
         if make = VehicleMaker.all.name(titles[0].trim).first
           null
         else
           make = VehicleMaker.new
           make.name = titles[0].trim
           make.save
           null
         end
         vehicle.maker_id = make.id
       rescue
         null
       end
       
       # model
       begin
         if model = VehicleModel.all.name(titles[1].trim).first
           null
         else
           model = VehicleModel.new
           model.name = titles[1].trim
           model.maker_id = make.id
           model.save
           null
         end
         vehicle.model_id = model.id    
       rescue
          null
        end
        
       # exact name
       begin
         vehicle.model_exact = titles[2].trim
       rescue
         null
       end
     
       # fuel type
       if info[0].trim.equals('Diesel')
         vehicle.fuel_type = Vehicle.FUEL_DIESEL
       elsif info[0].trim.equals('Gasoline')
         vehicle.fuel_type = Vehicle.FUEL_GASOLINE
       elsif info[0].trim.equals('LPG')
         vehicle.fuel_type = Vehicle.FUEL_LPG
       elsif info[0].trim.equals('CNG')
         vehicle.fuel_type = Vehicle.FUEL_CNG
       elsif info[0].trim.equals('Electricity')
         vehicle.fuel_type = Vehicle.FUEL_ELECTRICITY
       end  
       
      i=1
      5.times {
        begin
          if info[i].trim.startsWith('year')
             vehicle.year = Integer.parseInt(info[1].replace('year ','').trim)
             null
          elsif (info[i].trim.endsWith('PS)'))
            vehicle.engine_power = Double.parseDouble(info[i].split(' ')[0].trim)
            null
          elsif info[i].trim.startsWith('manual')
            vehicle.gearing = Vehicle.GEARING_MANUAL
            null
          elsif info[i].trim.startsWith('automatic')
            vehicle.gearing = Vehicle.GEARING_AUTOMATIC
            null
          end
        rescue
          null
        end
        i+=1
      }

      vehicle.save

       i = 1
       20.times {
         if !import_fuelings(url+"?page="+Integer.toString(i), vehicle.id)
           break
         end
         i+=1
       }
   
     "true"
   end
 
 
  def import_fuelings(url:String,vehicle_id:long)
     begin
       doc = Jsoup.connect(url).get();
     rescue 
       return false
     end
 
     if table = doc.getElementsByClass('itemtable').first
       true
     else
       return false
     end
   
     rows = table.getElementsByTag("tbody").first.getElementsByTag("tr")
     puts url
     rows.each do |row| # zaznamy
     
       f = Fueling.blank
       f.vehicle_id = vehicle_id
       f.fueling_type = Fueling.FUELING_TYPE_FULL
       cols = Element(row).getElementsByTag("td")
       cols.each do |c| # sloupce
         col = Element(c)
         
           # rozliseni typu
           if col.attr('class').equals('fuelkmpos') 
             f.type = Fueling.TYPE_FUELING
           elsif  col.attr('class').equals('costkmpos') 
             f.type = Fueling.TYPE_COST          
           end

         if col.attr('class').equals('fueldate') || col.attr('class').equals('costdate')
           begin
             arr = String(col.text).split('\.') 
             if arr.length == 3
               f.date = TimeHelper.at_date(Integer.parseInt(arr[0]), Integer.parseInt(arr[1]), Integer.parseInt(arr[2]) ).ms
             end
           rescue
             null
           end
           null
         elsif col.attr('class').equals('fuelkmpos') || col.attr('class').equals('costkmpos') 
           if !col.text.equals('')
             f.odometer = Integer.parseInt(col.text.replace('.',''))
             null
           else
           #  f.fueling_type = Fueling.FUELING_TYPE_INVALID
             null
           end
           null
         elsif col.attr('class').equals('trip')
           if !col.text.equals('')
             f.trip = int(Double.parseDouble(col.text.replace('.','').replace(',','.')))
             null
           else
         #    f.fueling_type = Fueling.FUELING_TYPE_INVALID
             null
           end
           null
         elsif !col.text.equals('') and col.attr('class').equals('quantity')
           begin
             f.quantity = Double.parseDouble(col.text.replace('.','').replace(',','.'))
           rescue
            f.quantity = 1.0
           end
           
           null
         elsif col.attr('class').equals('fuelsort')
           if img = col.getElementsByTag('img').first
             tmpn =  Integer.parseInt(img.attr('src').replace('pics/fuelsort/fuelsort_','').replace('.png',''))
             f.fuelsort = tmpn        
           end
           null
         elsif col.attr('class').equals('tire') 
           if img = col.getElementsByTag('img').first
              tmpn =  Integer.parseInt(img.attr('src').replace('pics/vdetail/tire_','').replace('.png',''))
              if tmpn == 1
                f.tires = Fueling.TIRES_SUMMER
              elsif tmpn == 2
                f.tires = Fueling.TIRES_SUMMER
              elsif tmpn == 3
                f.tires = Fueling.TIRES_ALL_YEAR
              end
           end
           null
         elsif col.attr('class').equals('street')
           imgs = col.getElementsByTag('img')
           imgs.each do |imgo|
             img = Element(imgo)
             if img.attr('src').equals('pics/vdetail/street_1.png')
               f.route_motorway = 1
             elsif img.attr('src').equals('pics/vdetail/street_2.png')
               f.route_city = 1            
             elsif img.attr('src').equals('pics/vdetail/street_3.png')
               f.route_country_roads = 1 
             end
           end
           null
         elsif col.attr('class').equals('style')
           imgs = col.getElementsByTag('img')
           imgs.each do |imgo|
             img = Element(imgo)
             if img.attr('src').equals('pics/vdetail/style_1.png')
               f.driving = Fueling.DRIVING_MODERATE
             elsif img.attr('src').equals('pics/vdetail/style_2.png')
               f.driving = Fueling.DRIVING_NORMAL       
             elsif img.attr('src').equals('pics/vdetail/style_3.png')
               f.driving = Fueling.DRIVING_FAST
             end
           end          
           null
         elsif !col.text.equals('') and col.attr('class').equals('fuelprice') 

           arr = col.attr('onmouseover').replace("showTooltip('",'').replace("')",'').split('<br/>')
           begin
             f.price = Double.parseDouble(arr[0].split(' ')[0].replace('.','').replace(',','.'))
            f.price_currency = arr[0].split(' ')[1]
           rescue
             f.price = 0.0
             f.price_currency = 'EUR'
           end
           
           

           null
         elsif !col.text.equals('') and col.attr('class').equals('costprice')   
           tmpt = col.attr('onmouseover').replace("showTooltip('",'').replace("')",'')
           begin
             f.price = Double.parseDouble(tmpt.split(' ')[0].replace('.','').replace(',','.'))
             f.price_currency = tmpt.split(' ')[1]
           rescue
             f.price = 0.0
             f.price_currency = 'EUR'
           end
           

           null
         elsif col.attr('class').equals('consumption')
           # spotreba
           #if f.fueling_type == Fueling.FUELING_TYPE_INVALID
           #  f.fueling_type = Fueling.FUELING_TYPE_FIRST
           #end
            if img = col.getElementsByTag('img').first             
               if img.attr('src').equals('pics/vdetail/fueling_first.png')
                 f.fueling_type = Fueling.FUELING_TYPE_FIRST
               elsif img.attr('src').equals('pics/vdetail/fueling_invalid.png')
                 f.fueling_type = Fueling.FUELING_TYPE_INVALID
               elsif img.attr('src').equals('pics/vdetail/fueling_notfull.png')
                 f.fueling_type = Fueling.FUELING_TYPE_PARTLY_FULL
               end             
            end
         
           null
         elsif col.attr('class').equals('costname') and !col.text.trim.equals('')
           cost = col.text.trim
           if cost.equals('Maintenance')
             f.cost_type = Fueling.COST_MAINTENANCE
           elsif cost.equals('Repair')
             f.cost_type = Fueling.COST_REPAIR
           elsif cost.equals('Change tires')
             f.cost_type = Fueling.COST_CHANGE_TIRES
           elsif cost.equals('Change oil')    
             f.cost_type = Fueling.COST_CHANGE_OIL
           elsif cost.equals('Insurance')
             f.cost_type = Fueling.COST_INSURANCE
           elsif cost.equals('Tax')
             f.cost_type = Fueling.COST_TAX
           elsif cost.equals('Supervisory board')
             f.cost_type = Fueling.COST_SUPERVISORY_BOARD
           elsif cost.equals('Tuning')    
             f.cost_type = Fueling.COST_TUNING
           elsif cost.equals('Accessories')
             f.cost_type = Fueling.COST_ACCESSORIES
           elsif cost.equals('Purchase price')
             f.cost_type = Fueling.COST_PURCHASE_PRICE
           elsif cost.equals('Miscellaneous')
             f.cost_type = Fueling.COST_MISCELLANEOUS
           elsif cost.equals('Care')    
             f.cost_type = Fueling.COST_CARE
           elsif cost.equals('Payment')
             f.cost_type = Fueling.COST_PAYMENT
           elsif cost.equals('Registration')
             f.cost_type = Fueling.COST_REGISTRATION
           elsif cost.equals('Financing')    
             f.cost_type = Fueling.COST_FINANCING
           elsif cost.equals('Refund')
             f.cost_type = Fueling.COST_REFUND
           elsif cost.equals('Fine')
             f.cost_type = Fueling.COST_FINE
           elsif cost.equals('Parking tax')    
             f.cost_type = Fueling.COST_PARKING_TAX
           elsif cost.equals('Toll')
             f.cost_type = Fueling.COST_TOLL  
           elsif cost.equals('Spare parts')    
             f.cost_type = Fueling.COST_SPARE_PARTS
           end
        
           null
         elsif col.attr('class').equals('fuelnote')
           imgs = col.getElementsByTag('img')
           imgs.each do |imgo|
             img = Element(imgo)
             if img.attr('src').equals('pics/vdetail/ac.png')
               f.ac = 1
             end
           end
           null
         end
       end #vehicle
     
       f.save
     
     #  tmp += "\n<br>"
     end
   
   
   true
 end
  
end
