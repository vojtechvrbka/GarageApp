import ext.*
import models.*
import java.util.regex.*
import java.util.ArrayList
import java.util.HashMap
import java.util.Calendar

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
  
  def dev_flush_local_data
    FuelType.all.run.each { |ft| ft.delete()  }
    Fueling.all.run.each { |f| f.delete()  }
    NoteEntry.all.run.each { |ne| ne.delete()  }
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
    f.quantity = 39.23
    f.price = 27.2
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(21,1,2010) ;f.date = t.ms
    f.odometer = 128150
    f.quantity = 43
    f.price = 28
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(12,2,2010) ;f.date = t.ms
    f.odometer = 128905 
    f.quantity = 46.04
    f.price = 27.7
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(25,2,2010) ;f.date = t.ms
    f.odometer = 129610
    f.quantity = 46.04
    f.price = 27.7
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(15,3,2010) ;f.date = t.ms
    f.odometer = 130437
    f.quantity = 48.5
    f.price = 28.3
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(31,3,2010) ;f.date = t.ms
    f.odometer = 131205
    f.quantity = 47.17
    f.price = 29.2
    f.save

    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(13,4,2010) ;f.date = t.ms
    f.odometer = 132010
    f.quantity = 49.75
    f.price = 30.5
    f.save
    
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(17,5,2010) ;f.date = t.ms
    f.odometer = 134204
    f.quantity = 49.75
    f.price = 48.2
    f.save    
    
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(24,4,2010) ;f.date = t.ms
    f.odometer = 133410 
    f.quantity = 47
    f.price = 30.4
    f.save
    
    
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(17,5,2010) ;f.date = t.ms
    f.odometer = 134204
    f.quantity = 48.2
    f.price = 30.9
    f.save   
    
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(1,6,2010) ;f.date = t.ms
    f.odometer = 135049
    f.quantity = 53.2
    f.price = 30.9
    f.save    
   
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(15,6,2010) ;f.date = t.ms
    f.odometer = 135764
    f.quantity = 46.88
    f.price = 31.6
    f.save   
       
    t = TimeHelper.new
    f = Fueling.new; f.vehicle_id = Integer.parseInt(params[:vehicle]);f.type = 'full'
    t.date(11,7,2010) ;f.date = t.ms
    f.odometer = 136638
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