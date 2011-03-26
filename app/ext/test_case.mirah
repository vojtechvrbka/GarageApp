import java.util.*
import stdlib.*
import java.util.ArrayList;
import duby.lang.compiler.Block;

import java.io.PrintWriter;
import java.io.StringWriter;

import com.google.appengine.api.datastore.DatastoreService;
import com.google.appengine.api.datastore.DatastoreServiceFactory;
import com.google.appengine.api.datastore.Entity;
import com.google.appengine.api.datastore.Query;
import com.google.appengine.tools.development.testing.LocalDatastoreServiceTestConfig;
import com.google.appengine.tools.development.testing.LocalServiceTestHelper;

/*
class TestCase   
  
  class Fail < Exception; 
    def initialize(message:String); 
      @message = message 
    end
    
    def message
      @message
    end
    
    def getMessage
      @message
    end
  end
  
  def _eq(bool:boolean, a:String, b:String)
    _eq(bool, a, b, "expected #{inspect(b)}, but was #{inspect(a)}")
  end
  
  def _eq(bool:boolean, a:Integer, b:Integer)
    _eq(bool, a, b, "expected #{b}, but was #{a}")
  end
  
  def _eq(bool:boolean, a:Integer, b:Integer, error:String)
    if bool
      pass
    else
      fail error
    end
  end
  
  def inspect(s:String)
    "'#{Element.escape_html(s)}'"
  end
  
  def _eq(bool:boolean, a:String, b:String, error:String)    
    if bool
      pass
    else
      fail error
    end
  end
  
  def _neq(bool:boolean, a:String, b:String)
    _neq(bool, a, b, "#{b} should not be equal to #{a}")
  end
  
  def _neq(bool:boolean, a:String, b:String, error:String)    
    if bool
      pass
    else
      fail error
    end
  end
  
  
  def eq(a:int, b:int)
    _eq(a == b, String.valueOf(a), String.valueOf(b))
  end

  def eq(a:Integer, b:Integer)
    _eq(a.equals(b), a, b)
  end

  def eq(a:int, b:int, message:string)
    _eq(a == b, String.valueOf(a), String.valueOf(b), message)
  end

  def eq(a:Integer, b:Integer, message:string)
    _eq(a.equals(b), a, b, message)
  end

  def eq(a:long, b:long)
    _eq(a == b, String.valueOf(a), String.valueOf(b))
  end

  def eq(a:long, b:long, message:string)
    _eq(a == b, String.valueOf(a), String.valueOf(b), message)
  end

  def eq(a:boolean, b:boolean)
    if a
      if b
        _eq(true, String.valueOf(a), String.valueOf(b))
      else
        _eq(false, String.valueOf(a), String.valueOf(b))
      end
    else
      if b
        _eq(false, String.valueOf(a), String.valueOf(b))
      else
        
        _eq(true, String.valueOf(a), String.valueOf(b))
      end
    end
  end
  
  def not_eq(a:int, b:int)
    _neq(a != b, String.valueOf(a), String.valueOf(b))
  end
  
  def not_eq(a:long, b:long)
    _neq(a != b, String.valueOf(a), String.valueOf(b))
  end
    
  def eq(a:String, b:String)
    _eq(a.equals(b), a, b)
  end

  def eq(a:String, b:String, message:string)
    _eq(a.equals(b), a, b, message)
  end
  
  def not_eq(a:String, b:String)
    _neq(a.equals(b), a, b)
  end
  
  def assert_false(bool:boolean)
    assert_false(bool, 'expected false, was '+String.valueOf(bool))
  end
  
  def assert_false(bool:boolean, message:string)
    if bool
      fail message
    else
      pass
    end
  end
  
  def assert_raise(block:Runnable)
    raised = false
    begin
      block.run
    rescue Exception
      raised = true
    end
    assert raised, 'Expected exception, but none was thrown.'
  end  
  
  def assert_no_raise(block:Runnable)
    raised = false
    begin
      block.run
    rescue Exception
      raised = true
    end
    assert_false raised, 'Expected exception, but none was thrown.'
  end  
  
  def assert_exception(block:Runnable)
    assert_raise(block)
  end    
  
  def assert_no_exception(block:Runnable)
    assert_raise(block)
  end    
  
  def pass; returns void
    @progress += '.'
    return
  end
  
  def fail(message:string); returns void
    raise Fail.new(message)
    return
  end
    
  
  def assert(o:Object)
    assert o, 'Expected to be not null, but was null.'
  end
  
  def assert(o:Object, message:string)
    if o != null
      pass
    else
      fail message
    end
  end
  
  def assert(bool:boolean, message:string)
    if bool
      pass
    else
      fail message
    end
  end

  def assert(bool:boolean)
    assert(bool, 'expected true, was '+String.valueOf(bool))
  end
  
  def self.register(test_case:TestCase)
    puts "\n\n --- REGISTERED TEST CASE "+test_case.toString()
    if @cases
      null
    else
      @cases = ArrayList.new
      null
    end
    @cases.add(test_case)
    null
  end
  
  def initialize
    #@helper = TestHelper.new
  end
  
  def setup
    #@helper.helper.setUp
  end
  
  def teardown
    #@helper.helper.tearDown
  end

  def run; returns String
    report = ''
    getClass().getDeclaredMethods.each { |method|
      if method.getName().startsWith('test_')
        @failed = false
        @failures = ''
        @progress = ''
        begin
          @out = ''
          setup
          method.invoke(self, null)
          teardown
        rescue Fail => f          
          @failed = true    
          @progress += 'F'
          @failures += render_exception(f)
        rescue Exception => ex
          @progress += 'E'
          @failed = true
          if ex.getCause != null
            @failures += pretty_exception(ex.getCause)
          else
            @failures += render_exception(ex)
          end
        end
        @progress += '.' 
        report_part = method.getName().replace('test_', '').replaceAll('_', ' ') + ' ' + @progress
        if @failures != '' || @out != ''
          report_part += "<pre>" + @out + @failures + '</pre>'
        end
        report += '<div class="testmethod '+(@failed ? 'failed' : 'passed')+'">'+report_part+'</div>'
      end
    }
    report
  end

  def p(what:Object)
    @out += what.toString()
  end
  
  def p(what:String)
    @out += what
  end
  
  def pretty_exception(ex:Throwable)
    if ex.getCause != null
      render_exception(ex) + pretty_exception(ex.getCause)
    else
      render_exception(ex)
    end
  end
  
  def render_exception(ex:Throwable); returns String
    sw = StringWriter.new()
    pw = PrintWriter.new(sw, true)
    ex.printStackTrace(pw)
    pw.flush()
    sw.flush()
    
    trace = '<div class="important_part">'
    
    ex_trace = sw.toString()
    
    if ex_trace.split("Fail:").length > 1
      ex_trace = ex_trace.split("Fail:")[1]
    end
    
    ex_trace.split("\n").each { |line|
      chunks = line.split('at ')
      line = chunks[chunks.length-1]
      if chunks.length == 1 || line.startsWith('dubious.TestCase.')
        next
      end
      if internal_line? line
        trace += '<span class="line internals">'+line+'</br></span>'
      else
        trace += '<span class="line">'+line+'</br></span>'
      end
      if line.startsWith('tests.')
        trace += '</div><div class="not_important_part">'
      end
      
    }
    
    '<h3>'+ex.toString()+'</h3><pre>'+trace+'</div></pre>'
  end  
  
  def internal_line?(line:String)
    if line.startsWith('javax.') || 
       line.startsWith('org.mortbay') ||
       line.startsWith('sun.reflect.') ||
       line.startsWith('com.google.')      
      true
    else
      false
    end
  end
  
  
  
end

*/




