import dubious.*
import ext.*
import models.*
import java.util.regex.*
import java.util.ArrayList

import org.apache.commons.codec.binary.*

import com.google.appengine.api.users.UserService
import com.google.appengine.api.users.UserServiceFactory

import com.google.appengine.api.blobstore.BlobKey
import com.google.appengine.api.blobstore.BlobstoreService
import com.google.appengine.api.blobstore.BlobstoreServiceFactory


class UploadController < MyController 
  
  def blobstore
    BlobstoreServiceFactory.getBlobstoreService()
  end  
  
  def upload
    #Map<String, BlobKey> 
    blobs = blobstore.getUploadedBlobs(request)    

    if blobKey = BlobKey(blobs.get("main_image"))
      puts "AAAANO"
     # offer = Offer.get(params.id)
    #  offer.main_image_key = blobKey.getKeyString()
    #  offer.save
    end
    #params.response.sendRedirect("/")
    redirect_to '/admin/offers'
    null
  end
end