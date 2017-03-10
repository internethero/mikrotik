# Set admin password
/user set admin password="pa$$word"

# Disable telnet mac server
/tool mac-server set [ find default=yes ] disabled=yes

# Disable mac winbox
/tool mac-server mac-winbox set [ find default=yes ] disabled=yes

# Disable services
/ip service
  set telnet disabled=yes
  set www disabled=yes
  set api disabled=yes
  set api-ssl disabled=yes