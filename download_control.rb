#!/usr/bin/env ruby
# encoding: UTF-8

#
# BigBlueButton open source conferencing system - http://www.bigbluebutton.org/
#
# Copyright (c) 2012 BigBlueButton Inc. and by respective authors (see below).
#
# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU Lesser General Public License as published by the Free
# Software Foundation; either version 3.0 of the License, or (at your option)
# any later version.
#
# BigBlueButton is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
# details.
#
# You should have received a copy of the GNU Lesser General Public License along
# with BigBlueButton; if not, see <http://www.gnu.org/licenses/>.
#

require "trollop"
require File.expand_path('../../../lib/recordandplayback', __FILE__)
require 'builder'

opts = Trollop::options do
  opt :meeting_id, "Meeting id to archive", :type => String
  opt :url, "Presentation url", :type => String
end
meeting_id = opts[:meeting_id]
url = opts[:url]

logger = Logger.new("/var/log/bigbluebutton/post_publish.log", 'weekly' )
logger.level = Logger::INFO
BigBlueButton.logger = logger

published_files = "/var/bigbluebutton/published/presentation/#{meeting_id}"
meeting_metadata = BigBlueButton::Events.get_meeting_metadata("/var/bigbluebutton/recording/raw/#{meeting_id}/events.xml")

#
# This runs the download script
#
#download_status = system("/usr/bin/python /usr/local/bigbluebutton/core/scripts/post_publish/download.py #{meeting_id}")

tmp = meeting_id.split('-')

if !tmp[2].nil? && tmp[2] == 'presentation'
  meetingId = tmp[0] + '-' + tmp[1]
else
  meetingId = meeting_id
end

logs = '/var/log/bigbluebutton/download/'
logfile = logs + meetingId + '.log'

system("echo Generating in 10.. >> #{logfile}")
sleep(10)

script_dir = "bbb-recorder/"
pwd = Dir.pwd

Dir.chdir(script_dir)
download_status = system("node export.js #{url} #{meetingId + '.webm'} 0 true 2>> #{logfile}")
Dir.chdir(pwd)

system("echo node ended procesing, output: #{download_status} >> #{logfile}")

exit 0
