import models.*

import com.google.apphosting.api.ApiProxy;
import java.util.Properties
import java.util.ArrayList
import java.lang.System


import java.io.PrintWriter
import java.io.StringWriter

import javax.servlet.http.*

class ShowException

  def self.plain(e:Throwable)
    new.plaintext(e)
  end
  
  def initialize
    @html = '<html>
    <style>
      body { 
        font-family:arial;
        margin:0;
        padding:0;
      }
      th { text-align:left }      
      .vars {
        border:1px solid #ccc;
        margin:0.5em;
        width:45%;
        border-spacing:0;
        font-size:13px;
        float:left;
      }
      .vars td, .vars th {
        background:#fff;
        line-height:190%;
        padding:0 8px;
      }
      .vars tr:nth-child(odd) td, .vars tr:nth-child(odd) th {
        background:#f8f8f8;
      }
      .fw { display:none }
      .fw-reflection { display:none }
      .trace {
        background:#fff;
        padding:1em 2em;
        border:1px solid #eee;
      }
      .trace .line {
        padding:2px 4px; 
      }
      .exception_message {
        background:#ffc; 
        padding:20px 15px; 
        margin:0;
        border-bottom:1px solid #ccc;  
      }
      .more_info {
        background:#eee; 
        padding:10px;
      }
      .exception_class {
        color:gray;
        font-size:14px;
        padding-bottom:0.6em;
      }
      .clear { clear:both }
      .first {
        background-color:blue;
        color:white;
        font-weight:bold;
      }
      table h2 {
        margin:0;
        line-height:180%;
      }
    </style>
    <body> 
    '
    @vars = ''
  end
  
  
  def plaintext(ex:Throwable):String
    sw = StringWriter.new()
    pw = PrintWriter.new(sw, true)
    ex.printStackTrace(pw)
    pw.flush() 
    sw.flush()
    
    trace = ''
    lineno = 0
    first_app = true
    sw.toString().split("\n").each { |_line|
      if lineno == 0
        lineno += 1
        next
      end
      lineno += 1
      
      chunks = _line.split("at ")
      if chunks.length > 1
        line = _line.split("at ")[1]
      else
        line = _line
      end
      
      cls = 'app'
      
      if line.startsWith('dubious.') || 
          line.startsWith('org.mortbay') ||
          line.startsWith('javax.servlet')
        next
      end
      
      if cls.equals('app') && first_app
        first_app = false
        cls += ' first'
      end
      
      if line.startsWith('sun.reflect')
        cls = 'fw-reflection'
      end      
      
      trace += "\n  "+line
    }
    
    
    text = "#{ex.getMessage} (#{ex.getClass.getName})#{trace}"
    
  end
  
  def pretty(request:HttpServletRequest, ex:Throwable)
    sw = StringWriter.new()
    pw = PrintWriter.new(sw, true)
    ex.printStackTrace(pw)
    pw.flush() 
    sw.flush()
    
    trace = ''
    lineno = 0
    first_app = true
    sw.toString().split("\n").each { |_line|
      if lineno == 0
        lineno += 1
        next
      end
      lineno += 1
      
      chunks = _line.split("at ")
      if chunks.length > 1
        line = _line.split("at ")[1]
      else
        line = _line
      end
      
      cls = 'app'
      
      if line.startsWith('dubious.') || line.startsWith('org.mortbay.jetty')
        cls = 'fw' 
      end
      
      if cls.equals('app') && first_app
        first_app = false
        cls += ' first'
      end
      
      if line.startsWith('sun.reflect')
        cls = 'fw-reflection'
      end      
      
      trace += "<div class=\"line lineno-#{lineno} #{cls}\">#{line}</div>"
    }
    
    
    @html += "<h1 class=\"exception_message\"><div class=\"exception_class\">#{ex.getClass.getName}</div> #{ex.getMessage}</h1>\n<div class=\"more_info\"><pre class=\"trace\">#{trace}</pre>"
    
    @html += "<table class=\"vars\">"
    @html += "<th colspan=\"2\"><h2>Request</h2></th>"
    set(:AUTH_TYPE,	request.getAuthType())
    set(:CONTENT_TYPE,	request.getContentType())
    set(:CONTENT_LENGTH,	request.getContentLength())
    set(:PATH_INFO,	request.getPathInfo())
    set(:PATH_TRANSLATED,	request.getPathTranslated())
    set(:QUERY_STRING,	request.getQueryString())
    set(:REMOTE_ADDR,	request.getRemoteAddr())
    set(:REMOTE_HOST,	request.getRemoteHost())
    set(:REMOTE_USER,	request.getRemoteUser())
    set(:REQUEST_METHOD,	request.getMethod())
    set(:SCRIPT_NAME,	request.getServletPath())
    set(:SERVER_NAME,	request.getServerName())
    set(:SERVER_PROTOCOL,	request.getProtocol())
    set(:SERVER_PORT, request.getServerPort())
    @html += '</table>'
    
    
    @html += "<table class=\"vars\">"
    @html += "<th colspan=\"2\"><h2>Request headers</h2></th>"
    enames = request.getHeaderNames
    while enames.hasMoreElements
      name = String(enames.nextElement)
      value = request.getHeader(name)
      set(name, value)
    end
    @html += '</table>'
    
    
    @html += "<table class=\"vars\">"
    @html += "<th colspan=\"2\"><h2>Params</h2></th>"
    map = request.getParameterMap
    i = map.keySet.iterator
    while i.hasNext()
      key = String(i.next)
      set(key, request.getParameter(key))
    end
    @html += '</table>'
    
    
    
    @html += "<table class=\"vars\">" 
    @html += "<th colspan=\"2\"><h2>Session</h2></th>"
    session = request.getSession()
    names = session.getAttributeNames
    
    while names.hasMoreElements
      key = String(names.nextElement)
      set(key, String.valueOf(session.getAttribute(key)))
    end
    @html += '</table>'
    
    
    @html + '<div class="clear"></div></div></body></html>'
  end
  
  
  def set(k:String, v: String)
    @html += "<tr><th>#{k}</th><td>#{v}</td></tr>"
  end
  
  def set(k:String, v: int)
    set(k, String.valueOf(v))
  end

  
end