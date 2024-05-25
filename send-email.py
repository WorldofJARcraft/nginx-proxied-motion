#!/usr/bin/python3
import sys
import sendgrid
import os
from datetime import datetime
import base64
from python_http_client.exceptions import HTTPError
today = str(datetime.now())

sendgrid_api_key = os.environ['SG_API_KEY']
from_email = os.environ['FROM_EMAIL']
to_email = os.environ['TO_EMAIL']

from sendgrid import Email, Attachment, Content
from sendgrid.helpers.mail import Mail
sg = sendgrid.SendGridAPIClient(sendgrid_api_key)

from_email = (from_email)
subject = "Motion Detected!"
to_email = (to_email)
content = "I detected a movement at {}!".format(today)
file = None
with open(sys.argv[1], "rb") as video:
    file=video.read()
    video.close()
file = base64.b64encode(file).decode()
print(file)
attachment = Attachment()
attachment.file_content=(file)
attachment.file_type=("video/x-matroska")
attachment.file_name=("video.mkv")
attachment.disposition=("attachment")
attachment.content_id=("Motion Video")

mail = Mail(from_email=from_email, subject=subject, to_emails=to_email, html_content=content)
mail.add_attachment(attachment)
try:
    response = sg.send(mail.get())
    print(response.status_code)
    print(response.body)
    print(response.headers)
except HTTPError as e:
    print(e.to_dict)
