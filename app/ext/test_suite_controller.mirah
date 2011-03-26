import ext.*
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
class TestSuiteController < MyController

  def cases:List
    raise 'Not implemented'
  end

  def index
    out = "
<html>
<head>
<title>Tests</title>
<style>
.testmethod {
  padding-left:10px;
  margin-left:10px;
  color:white;
  margin-bottom:1px;
  font-family:consolas;
  padding:3px 6px;
  padding-top:6px;
}
.testmethod pre {
  background:white;
  padding:10px;
  color:black;
  margin:0;
  margin-bottom:5px;
}
.failed { 
  background:red;
}
.passed { 
  background:green;
}
.important_part .internals {
  color:gray;
}
.not_important_part {
  display:none;
}
.line {
  padding-left:1em;
}
h3 {
  margin-bottom:0;
} 
.testname {
  font-family:arial, sans;
}
.testname a {
  /*color:black;*/
  text-decoration:none;
  line-height:200%; 
}
</style>
<body>
<pre>
 __       __)                                    /  
(, )  |  /        /)                    /)  /)  /   
   | /| /   _    // ____ _   _    _/_ _(/ _(/  /    
   |/ |/  _(/_  (/_(_) (/___(/_   (__(_(_(_(_ o     
   /  |                                           
</pre>"

    
    action = params.peek
    
    cases.each { |test_case|
      tc = TestCase(test_case)
      chunks = tc.getClass.toString.split('\.')
      name = chunks[chunks.length-1]
      if (action == null) || (name.equals(action))
        if name.equals(action)
          out += '<h3 class="go_up"><a href="'+(link :index)+'">..</a></h3>'
        end
        out += '<h3 class="testname"><a href="'+(link name)+'">'+name+"</a></h3>"
        out += '<div class="testrun">'+tc.run+'</div>'
      end
      null
    }
 
    out
  end

  def exception
    out = ''
    raise 'Test exception.'
    out
  end  
  
end
*/