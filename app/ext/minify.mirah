import java.io.*

import com.yahoo.platform.yui.compressor.JavaScriptCompressor;
import org.mozilla.javascript.ErrorReporter
import org.mozilla.javascript.RhinoException
import org.mozilla.javascript.EvaluatorException


class Minify
  def self.js_file(file:String)
    js(FileReader.new(file))
  end

  def self.js(js:String)
    js StringReader.new(js)
  end
  
  def self.js(reader:Reader)
    os = ByteArrayOutputStream.new()
    err = PrintStream.new(os)
    
    compressor = JavaScriptCompressor.new(reader, MyReporter.new())
    
    disableOptimizations = false
    preserveSemi = false
    noMunge = false
    lineBreak = -1
    
    out = StringWriter.new()    
    compressor.compress(out, lineBreak, !noMunge, false, preserveSemi, disableOptimizations);
    
    #params.response.addCookie(Cookie.new(cookie_name, "123"));
    
    out.toString()  
  end

  
  class MyReporter
    implements ErrorReporter
    
    def warning(message:String, sourceName:String, line:int, lineSource:String, lineOffset:int):void
      puts formatDetailedMessage(message, sourceName, line, lineSource, lineOffset)
    end
    
    def error( message:String,  sourceName:String, line:int, lineSource:String,  lineOffset:int):void
      puts formatDetailedMessage(message, sourceName, line, lineSource, lineOffset)
    end
    
    def runtimeError(message:String, sourceName:String, line:int, lineSource:String, lineOffset:int):EvaluatorException
      return EvaluatorException.new(message, sourceName, line, lineSource, lineOffset)
    end
    
    def formatDetailedMessage(message:String, sourceName:String, line:int, lineSource:String, lineOffset:int)
      e = RhinoException.new(message)
      if (sourceName != null)
        e.initSourceName(sourceName)
      end
      if (lineSource != null) 
        e.initLineSource(lineSource);
      end
      if (line > 0)
        e.initLineNumber(line);
      end
      if (lineOffset > 0)
        e.initColumnNumber(lineOffset);
      end
      return e.getMessage()
    end
    
  end  
  
end
