# Emails the developer about each new feedback (Feedback#after_create_commit). It links to the inbox
# instead of attaching the screenshots: five 10 MB images would be too big for most mail servers
class FeedbackMailer < ApplicationMailer
  def submitted(feedback)
    @feedback = feedback
    mail to: Rails.configuration.x.support.email,
         subject: t(".subject", kind: t(feedback.kind, scope: "feedbacks.kinds"), enterprise: feedback.enterprise.name)
  end
end
