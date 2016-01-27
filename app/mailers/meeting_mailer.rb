#-- copyright
# OpenProject Meeting Plugin
#
# Copyright (C) 2011-2014 the OpenProject Foundation (OPF)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See doc/COPYRIGHT.md for more details.
#++

class MeetingMailer < UserMailer
  def content_for_review(content, content_type, address)
    @meeting = content.meeting
    @content_type = content_type

    open_project_headers 'Project' => @meeting.project.identifier,
                         'Meeting-Id' => @meeting.id

    subject = "[#{@meeting.project.name}] #{I18n.t(:"label_#{content_type}")}: #{@meeting.title}"
    mail to: address, subject: subject
  end
  
  def publish_icalendar(content, content_type, address)
    @meeting = content.meeting
    @content_type = content_type
    
    open_project_headers 'Project' => @meeting.project.identifier,
                         'Meeting-Id' => @meeting.id
    headers['Content-Type'] = 'text/calendar; charset=utf-8; method="PUBLISH"; name="meeting.ics"'
    headers['Content-Transfer-Encoding'] = '8bit'
    subject = "[#{@meeting.project.name}] #{I18n.t(:"label_#{content_type}")}: #{@meeting.title}"
    mystartdate = @meeting.start_time.strftime("%Y%m%dT%H%M%SZ")
    myenddate = @meeting.end_time.strftime("%Y%m%dT%H%M%SZ")
    url = meeting_url(@meeting)
    now = DateTime.now.strftime("%Y%m%dT%H%M%SZ")

    ical = "BEGIN:VCALENDAR
VERSION:2.0
PRODID:OpenProject Meeting
BEGIN:VEVENT
SUMMARY:[#{@meeting.project.name}] #{@meeting.title}
LOCATION:#{@meeting.location}
DTSTAMP:#{now}
DTSTART:#{mystartdate}
DTEND:#{myenddate}
DESCRIPTION:
METHOD:PUBLISH
ORGANIZER;CN=\"#{@meeting.author}\":MAILTO:#{@meeting.author.mail}
UID:#{@meeting.id}@#{@meeting.project.identifier}
SEQUENCE:0
URL:#{url}
END:VEVENT
END:VCALENDAR"

    mail(to: address, subject: subject) do |format|
       format.ics {
         render :text => ical, :layout => false
      }
    end
  end
end
