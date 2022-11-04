class AttachmentController < ActionController::Base
  def download
    #ActiveStorage::Blob.find(params[:id]).download
    ActiveStorage::Attachment.find(params[:id]).download
  end
end
