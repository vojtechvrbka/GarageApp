import ext.*
import models.*
import java.util.regex.*
import java.util.ArrayList
import java.util.HashMap
import java.util.Calendar


import org.jsoup.Jsoup;
import org.jsoup.helper.Validate;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.select.Elements;

class MigrationController < MyController
  def index
    list
  end
  
  def list
    html = '<h1>Available migrations</h1><ul>'
    getClass().getDeclaredMethods.each { |method|
      if method.getName().startsWith('migrate_')
        html += "<li><a href=\"/migrate/#{method.getName()}\">#{method.getName().split('migrate_')[1]}</a></li>"
      end
      if method.getName().startsWith('dev_')
        html += "<li><a href=\"/migrate/#{method.getName()}\">#{method.getName().split('dev_')[1]}</a></li>"
      end
    }    
    html += '</ul>'
    html
  end

  def dev_delete_fuelings
    fuelings = Fueling.all.vehicle_id(Integer.parseInt(params[:vehicle])).run
    fuelings.each do |f|
      f.delete
    end
    "fuelings delete"
  end
  
  def dev_import_spritmonitor

    import_vehicle(178505)
    "jo"
  end
  
  
  def import_vehicle(sprit_id:int) 

    url = "http://www.spritmonitor.de/en/detail/#{sprit_id}.html"
    doc = Jsoup.connect(url).get();

    # Ford - Focus - Focus II Turnier 1.6 TDCi
    # Diesel, year 2006, 66 kW (90 PS), manual User: ralf1982 - f?hrt immer mit Abblendlicht - im Sommer Alufelgen mit Michelin Energy Safer 195/65 R15


      details = doc.getElementById("vehicledetails")
      h1 = details.getElementsByTag("h1").first.text
      titles = h1.split(' - ')
      info = details.text.replace(h1,'').trim.split(', ')


      vehicle = Vehicle.new

      # vyrobce
      if make = VehicleMaker.all.name(titles[0].trim).first
        null
      else
        make = VehicleMaker.new
        make.type_id = 0
        make.name = titles[0].trim
        make.save
        null
      end
      vehicle.maker_id = make.id

      # model
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

      # exact name

      vehicle.model_exact = titles[2].trim

      vehicle.save

      puts "h1"
      puts h1
      puts "details"
      puts info
      puts "-------"
      i = 1
      10.times {
        if !import_fuelings(url+"?page="+Integer.toString(i), vehicle.id)
          break
        end
        i+=1
      }
    
    
  end
  
  
  def import_fuelings(url:String,vehicle_id:long)
    doc = Jsoup.connect(url).get();
    
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
          arr = String(col.text).split('\.')
  
          if arr.length == 3
            f.date = TimeHelper.at_date(Integer.parseInt(arr[0]), Integer.parseInt(arr[1]), Integer.parseInt(arr[2]) ).ms
          end
          null
        elsif col.attr('class').equals('fuelkmpos') || col.attr('class').equals('costkmpos') 
          f.odometer = Integer.parseInt(col.text.replace('.',''))
          null
        elsif col.attr('class').equals('trip')
          f.trip = int(Double.parseDouble(col.text.replace('.','').replace(',','.')))
          null
        elsif col.attr('class').equals('quantity')
          f.quantity = Double.parseDouble(col.text.replace('.','').replace(',','.'))
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
             f.tires = 10+tmpn        
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
        elsif col.attr('class').equals('fuelprice') 
          arr = col.attr('onmouseover').replace("showTooltip('",'').replace("')",'').split('<br/>')
          f.price = Double.parseDouble(arr[0].split(' ')[0].replace('.','').replace(',','.'))
          f.price_currency = arr[0].split(' ')[1]
          null
        elsif  col.attr('class').equals('costprice')   
          tmpt = col.attr('onmouseover').replace("showTooltip('",'').replace("')",'')
          f.price = Double.parseDouble(tmpt.split(' ')[0].replace('.','').replace(',','.'))
          f.price_currency = tmpt.split(' ')[1]
        elsif col.attr('class').equals('consumption')
          # spotreba
          null
        elsif col.attr('class').equals('fuelnote')

          null
        end
        
        
        
        /*
        if img = col.getElementsByTag('img').first
          alt = String(img.attr('alt'))
          null
        else
          alt = ""
          null
        end
      #  tmp += "\n" + col.attr('class') +"  - "+ alt +"  - "+ col.text 
        */
      end #vehicle
      
      f.save
      
    #  tmp += "\n<br>"
    end
    
    
    true
  end
  
  
  def dev_flush_local_data
    FuelType.all.run.each { |ft| ft.delete()  }
    Fueling.all.run.each { |f| f.delete()  }
    Note.all.run.each { |ne| ne.delete()  }
    # User.all.run.each { |u| u.delete()  }
    Vehicle.all.run.each { |v| v.delete()  }
    VehicleMaker.all.run.each { |vm| vm.delete()  }
    VehicleModel.all.run.each { |vmo| vmo.delete()  }
    VehicleType.all.run.each { |vt| vt.delete()  }
  end
  
  def dev_fill_data_for_localhost
    dev_flush_local_data()
    
    t = VehicleType.new
    t.name = 'Car'
    t.save
    
      m = VehicleMaker.new
      m.type_id = t.id
      m.name = 'Audi'
      m.save
        
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'A4' 
        mo.save
        
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'A5' 
        mo.save
        
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'A6' 
        mo.save
        
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'Q5' 
        mo.save
        
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'Q7' 
        mo.save
        
      m = VehicleMaker.new
      m.type_id = t.id
      m.name = 'BMW'
      m.save
      
      
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'X1' 
        mo.save
        
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'X3'
        mo.save
         
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'X5'
        mo.save
         
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'X6' 
        mo.save
        
      m = VehicleMaker.new
      m.type_id = t.id
      m.name = 'Volvo'
      m.save
      
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'S70' 
        mo.save
      
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'S80'
        mo.save
       
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'XC70'
        mo.save
       
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'XC90' 
        mo.save
        
    t = VehicleType.new
    t.name = 'Motorbike'
    t.save

      m = VehicleMaker.new
      m.type_id = t.id
      m.name = 'Yamaha'
      m.save

        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'SRX' 
        mo.save
        
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'XT' 
        mo.save
        
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'DragStar' 
        mo.save

      m = VehicleMaker.new
      m.type_id = t.id
      m.name = 'Suzuki'
      m.save

        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'GS' 
        mo.save
      
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'GSF Bandit' 
        mo.save
      
        mo = VehicleModel.new
        mo.maker_id = m.id
        mo.name = 'GSR' 
        mo.save
        
    ['Diesel','Gasoline','LPG','CNG','Electricity'].each do |n|     
      f = FuelType.new     
      f.name = n
      f.save   
    end      
        
    # u = User.register('Vojta', 'test', 'test')
    #   u.save
           
    'congrats, new data created'
  end
  

  def dev_add_fueling
    if Integer.parseInt(params[:vehicle]) > 0
      /*
      t = TimeHelper.new
      t.date(3,2,2010)
      f = Fueling.new
      f.vehicle_id = Integer.parseInt(params[:vehicle])
      f.date = t.ms
      f.type = 'full'
      f.quantity = 35
      f.price = 2560
      f.save
     */
     
     
     
    fuelings = Fueling.all.vehicle_id(Integer.parseInt(params[:vehicle])).run
    fuelings.each do |f|
      f.delete
    end

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(7,1,2010) ;f.date = t.ms
    f.odometer = 127400
    f.trip = 792
    f.quantity = 39.23
    f.price = 27.2
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(21,1,2010) ;f.date = t.ms
    f.odometer = 128150
    f.trip = 750
    f.quantity = 43
    f.price = 28
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(12,2,2010) ;f.date = t.ms
    f.odometer = 128905 
    f.trip = 755
    f.quantity = 46.04
    f.price = 27.7
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(25,2,2010) ;f.date = t.ms
    f.odometer = 129610
    f.trip = 705
    f.quantity = 46.04
    f.price = 27.7
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(15,3,2010) ;f.date = t.ms
    f.odometer = 130437
    f.trip = 827
    f.quantity = 48.5
    f.price = 28.3
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(31,3,2010) ;f.date = t.ms
    f.odometer = 131205
    f.trip = 768
    f.quantity = 47.17
    f.price = 29.2
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(13,4,2010) ;f.date = t.ms
    f.odometer = 132010
    f.trip = 805
    f.quantity = 49.75
    f.price = 30.5
    f.save
    
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(17,5,2010) ;f.date = t.ms
    f.odometer = 134204
    f.trip = 656
    f.quantity = 49.75
    f.price = 48.2
    f.save    
    
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(24,4,2010) ;f.date = t.ms
    f.odometer = 133410 
    f.trip = 744
    f.quantity = 47
    f.price = 30.4
    f.save
    
    
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(17,5,2010) ;f.date = t.ms
    f.odometer = 134204
    f.trip = 794
    f.quantity = 48.2
    f.price = 30.9
    f.save   
    
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(1,6,2010) ;f.date = t.ms
    f.odometer = 135049
    f.trip = 845
    f.quantity = 53.2
    f.price = 30.9
    f.save    
   
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(15,6,2010) ;f.date = t.ms
    f.odometer = 135764
    f.trip = 715
    f.quantity = 46.88
    f.price = 31.6
    f.save   
       
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(11,7,2010) ;f.date = t.ms
    f.odometer = 136638
    f.trip = 874
    f.quantity = 54.85
    f.price = 30.9
    f.save
    
        
    
    
    
    /*
    
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(,,2010)
    f.odometer =
    f.quantity = 
    f.price = 
    f.save

      
     */ 
      
      'fueling sucessfully added'
    else
      'Error: no param vehicle'
    end
    
    
  end
  
  
  def migrate_test
    'lalala'
  end
end