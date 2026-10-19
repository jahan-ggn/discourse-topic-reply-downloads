# Discourse Topic Reply Downloads Plugin

**Plugin Summary**

Sends a private message with downloads when a member replies to a configured topic. Each member receives one PM per topic.

Each topic can have its own PM subject, message, and multiple attachments.

Reference attachments using their identifiers:

    The file {{attachment:starter_pack}} contains the material you requested.

Attachments not referenced in the message are appended automatically. Actual line breaks and literal `\n` are supported.

## Upload URLs

Upload files to a post in an admin-only private category. Publish the post, copy each file’s download URL, and use it as the attachment URL in the rule. Keep the source post and uploads intact.

Local uploads render as native attachments or images. External URLs render as ordinary links.