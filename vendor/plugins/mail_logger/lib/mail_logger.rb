module ActionMailer
  class Base

    def deliver!(mail = @mail)
      raise "No mail object available for delivery!" unless mail
      
      logger.info "MailLogger sent mail:\n #{mail.encoded}" unless logger.nil?
      log_to_db("#{mail.encoded}")
      
      begin
        send("perform_delivery_#{delivery_method}", mail) if perform_deliveries
      rescue Object => e
        raise e if raise_delivery_errors
      end

      return mail
    end

  private

    def log_to_db(mail)
      begin
        MailLog.new({:form_name => subject, :message => mail}).save
        logger.info "MailLogger logged okay" unless logger.nil?
      rescue
        logger.info "MailLogger failed"
      end
    end
        
   end
end
