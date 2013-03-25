if Rails.env.production?
  ExceptionNotifier::Notifier.prepend_view_path File.join(Rails.root, 'app/views')

  recipients = Settings.get('exception_notification_recipients').split(',') rescue 'root@localhost'
  sender = Settings.get('exception_notification_sender') rescue 'root@localhost'
  email_subject_prefix = Settings.get('exception_notification_email_prefix') rescue '[OWUMS] '

  Owums::Application.config.middleware.use ExceptionNotifier,
    :email_prefix => email_subject_prefix,
    :sender_address => sender,
    :exception_recipients => recipients,
    :sections =>  %w(request session authlogic environment backtrace)
end
