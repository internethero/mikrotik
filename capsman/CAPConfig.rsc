# CAP Config
# Configure CAP's automatically utilizing automatic import
# https://wiki.mikrotik.com/wiki/Manual:Configuration_Management
# 
# For each lease offered by the dhcp server the script
# will run and check if the clients mac-address is a remote cap in capsman and
# check if the mac-address is not in the log file "capconfig.log.txt".
# Only then the script will upload "capconfig.auto.rsc" by ftp to the cap and add
# it's mac-address to "capconfig.log.txt"
#
# Howto:
# Edit capconfig.auto.rsc with your settings and
# upload it to capsman controller
# Add lease script on the dhcp server: CAPConfig
#
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.
#
# Henrik Eliasson
# https://github.com/internethero
#
# Tested on RB2011UAS RouterOS V6.38.3
#
:local user admin
:local password
:local ftpdelay 5s
:local autoscript capconfig.auto.rsc

:local log
:local logfile "capconfig.log.txt"

# Check if its a cap
if ($leaseBound = 1) do={
  if ([/caps-man remote-cap find where name="[$leaseActMAC]"] != "") do={
   
    # Create log file if it does not exists
    :if ([:len [/file find name=$logfile]] = 0) do={
      /file print file=$logfile
      delay 2
      /file set $logfile contents=","
      :delay 1
    }
    
    # Read contents of logfile to variable
    :set $log [/file get $logfile contents]
    
    # Check if CAP mac is in the logfile
    if ([:find $log $leaseActMAC -1]  >= 0) do={
     #nothing
    } else {
     #CAP not in logfile, uploading config...
     :log warn ("[CAP Config] Uploading config",$autoscript," to CAP", $leaseActIP)
     /tool fetch address="$leaseActIP" src-path=$autoscript user=$user mode=ftp password=$password dst-path="/$autoscript" upload=yes
     delay $ftpdelay
     /file set $logfile contents=($log . $leaseActMAC)
    }
  }
}
