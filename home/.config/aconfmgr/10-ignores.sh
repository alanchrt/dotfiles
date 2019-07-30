# Boot partition
IgnorePath '/boot/*'

# Certificate databases
IgnorePath '/etc/ca-certificates/extracted/*'
IgnorePath '/etc/ssl/certs/*'
IgnorePath '/etc/pacman.d/gnupg/*'

# Cache and generated files
IgnorePath '/etc/*.cache'
IgnorePath '/etc/*.gen'

# Password files
IgnorePath '/etc/*shadow*'
IgnorePath '/usr/share/*'

# Configuration database
IgnorePath '/etc/dconf'

# Mount files
IgnorePath '*/.updated'
IgnorePath '*/lost+found/*'

# Opt packages (check that they don't include config)
IgnorePath '/opt/*'

# Binary libraries
IgnorePath '/usr/lib/*'

# Local binaries
IgnorePath '/usr/local/include/*'
IgnorePath '/usr/local/lib/*'
IgnorePath '/usr/local/share/applications/mimeinfo.cache'

# Var databases, logs, swap and temp files
IgnorePath '/var/db/sudo'
IgnorePath '/var/lib/*'
IgnorePath /var/log/*
IgnorePath '/var/swap*'
IgnorePath '/var/tmp/*'

# Machine-specific config
IgnorePath '/etc/hostname'
IgnorePath '/etc/fstab'
IgnorePath '/etc/resolv.conf*'
IgnorePath '/etc/adjtime'
IgnorePath '/etc/machine-id'
IgnorePath '/etc/default/grub'
IgnorePath '/etc/NetworkManager/*'
