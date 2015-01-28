# Loads a certificate and key into an NSS database. 
#
# Parameters:
#   $dbname           - required - the directory to store the db
#   $nickname         - required - the nickname for the NSS certificate
#   $cert             - required - path to certificate in PEM format
#   $basedir          - optional - defaults to /etc/pki
#
# Actions:
#   loads certificate into the NSS database.
#
# Requires:
#   $dbname
#   $nickname
#   $cert
#   $key
#
# Sample Usage:
# 
#      nssdb::add_cert{"qpidd":
#        nickname=> 'Server-Cert',
#        cert => '/tmp/server.crt',
#        key  => '/tmp/server.key',
#      }
#
define nssdb::add_cert (
  $dbname = $title,
  $nickname,
  $cert,
  $basedir = '/etc/pki',
) {

  exec {'add_certificate':
    command => "/usr/bin/certutil -A -d '${basedir}/${dbname}' -n '$nickname' -t ',,' -a -i '$cert'",
    require => [
        File["${basedir}/${dbname}/cert8.db"],
        Package['nss-tools'],
    ],
    # The below command checks if the certificate is already imported into the NSS db
    unless => "/usr/bin/certutil -L -d '${basedir}/${dbname}' -n '$nickname' -a | diff -u - '$cert' >/dev/null 2>&1",
  }
}
