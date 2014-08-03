class Image < ActiveRecord::Base
    # extend CarrierWave::Mount
    mount_uploader :avatar, AvatarUploader

    validates_integrity_of  :avatar

    def pixelize
        #break image up into small pieces
    end


end
