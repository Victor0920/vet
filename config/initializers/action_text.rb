Rails.application.config.after_initialize do
  ActiveSupport.on_load(:action_text_content) do
    ActionText::ContentHelper.allowed_tags += %w[ u s ]
  end
end
