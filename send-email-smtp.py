#!/bin/python3

# Import smtplib for the actual sending function
import smtplib

# For guessing MIME type
import mimetypes

from datetime import datetime

# Import the email modules we'll need
import email
import email.mime.application
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

import os
import sys
import ssl

today=str(datetime.now())

# Create a text/plain message
msg = MIMEMultipart()
msg['Subject'] = f"Motion detected at {today}"
msg['From'] = os.environ['FROM_EMAIL']
msg['To'] = os.environ['TO_EMAIL']

# The main body is just another attachment
body = MIMEText("""I detected a movement! Pls see appended video!""", "plain")
msg.attach(body)

# PDF attachment
filename=sys.argv[1]
fp=open(filename,'rb')
att = email.mime.application.MIMEApplication(fp.read(),_subtype="video/mp4")
fp.close()
att.add_header('Content-Disposition','attachment',filename=filename)
msg.attach(att)

password = os.environ['EMAIL_PASSWORD']

# send via Gmail server
# NOTE: my ISP, Centurylink, seems to be automatically rewriting
# port 25 packets to be port 587 and it is trashing port 587 packets.
# So, I use the default port 25, but I authenticate. 
with smtplib.SMTP_SSL('trabant.worldofjarcraft.cloudns.cl',465,local_hostname="trabant.worldofjarcraft.cloudns.cl") as s:
    s.login(msg['From'],password)
    s.sendmail(msg['From'],[msg['To']], msg.as_string())
