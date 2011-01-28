import ext.*
import models.*
import utils.*
#import tasks.*
import java.util.regex.*
import java.util.ArrayList;

import org.apache.commons.codec.binary.*

import java.lang.reflect.InvocationTargetException

import com.google.appengine.api.users.UserService;
import com.google.appengine.api.users.UserServiceFactory;

import java.io.PrintWriter;
import java.io.StringWriter;

import com.google.appengine.ext.duby.db.Model


class TaskController < MyController
  def index 
    a = params.action
    if a.endsWith('Task')
      begin
        taskClass = Class.forName('tasks.'+a)
      rescue
        return 'Bad task name.'
      end
      task = Task(taskClass.newInstance())
      task.params(params)
      task.execute()
      
      s = "Task #{a}<br>"
      
      if task.did_work?
        s += " + did some work"
      else
        s += " - had nothing to do"
      end
      
      s += "<br>"
      
      if task.more_work?
        s += " + there is more work!"
      else
        s += " - there is no more work"
      end      
    else
      s = 'Give me a task.'
    end
    s
  end
  
end



