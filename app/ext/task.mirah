import com.google.appengine.api.taskqueue.Queue
import com.google.appengine.api.taskqueue.QueueFactory
import com.google.appengine.api.taskqueue.TaskOptions

import java.net.MalformedURLException
import java.net.URL
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.IOException
import ext.*


class Task
  
  def initialize()
    @dry_run = false
    @output = ""
    @problem = String(nil)
  end
  
  def params(params:RequestEvent)
    @params = params
    self
  end
  
  def params
    @params
  end
  
  def dry_run?
    @dry_run
  end    
  
  def dry_run
    @dry_run = true
    run
  end
  
  def execute
    info 'EXECUTE '+self.getClass.getName
    run
    if more_work?
      enqueue
    end
    if problem?
      raise problem
    end
  end
  
  def nothing_to_do
    @did_work = false
  end
  
  def work_complete
    @did_work = true
  end
  
  def did_work?
    @did_work
  end
  
  def enqueue_safe(e:RequestEvent)
    #begin
    url = URL.new(e.base_url+task_url)
    reader = BufferedReader.new(
      InputStreamReader.new(url.openStream())
    )
    line = ''
    while (line = reader.readLine()) != null
      'we don care'
      null
    end
    reader.close()
      #rescue
      
      #end        
  end
  
  def enqueue
    queue = QueueFactory.getDefaultQueue()
    url = task_url
    puts "------ Adding task #{url} to queue"
    queue.add(TaskOptions.Builder.withUrl(url))
  end
  
  def task_url; returns String
    "/tasks/"+self.getClass.getName()
  end  
  
  def run; returns void
    raise 'All Tasks should implement run() method.'
  end
  
  def more_work?
    @more_work
  end
  
  def precondition_not_met
    @more_work = false
    puts self.toString+": Precondition not met."
  end
  
  def preconditions_not_met
    precondition_not_met
  end
  
  def there_might_be_more_work
    @more_work = true
  end
  
  def info(line:String)
    puts line
    @output += line+"\n"
  end
  
  def problem(problem:String)
    @problem = problem
  end
  
  def problem?
    @problem != nil
  end
  
  def problem
    @problem
  end
  
  def output
    @output
  end
end


