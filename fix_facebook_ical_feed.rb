#!/usr/local/bin/ruby

# filter out any events you have not rsvped 'yes' to on facebook
ONLY_INCLUDE_RSVP_YES=true

# put your facebook ical URL here
ICAL_URL="http://www.facebook.com/ical/u.php?uid=@@@@&key=@@@@@"

#####################################################################
puts "Content-Disposition: attachment; filename=foo.ics"
puts "Content-Type: text/calendar;charset=utf-8"
print "\r\n"
STDOUT.flush

# change CLASS:PRIVATE to CLASS:PUBLIC due to bug in google calendar
# that causes events marked 'private' on external calendars to not
# show any event details
IO.popen("curl -s '#{ICAL_URL}' | sed s/CLASS:PRIVATE/CLASS:PUBLIC/") do |f|
  event = ""
  confirmed = false
  f.each do |line|
   line.chomp!
   if (line == "BEGIN:VEVENT") then
     if(confirmed || !ONLY_INCLUDE_RSVP_YES) then
      print event
     end
     event = ""
    confirmed=false
   end
   if (line == "PARTSTAT:ACCEPTED") then
     confirmed = true
   end
   event << line + "\n"
 end
end
