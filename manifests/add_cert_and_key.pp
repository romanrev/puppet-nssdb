# Loads a certificate and key into an NSS database. 
#
# Parameters:
#   $dbname           - required - the directory to store the db
#   $nickname         - required - the nickname for the NSS certificate
#   $cert             - required - path to certificate in PEM format
#   $key              - required - path to unencrypted key in PEM format
#   $basedir          - optional - defaults to /etc/pki
#
# Actions:
#   loads certificate and key into the NSS database.
#
# Requires:
#   $dbname
#   $nickname
#   $cert
#   $key
#
# Sample Usage:
# 
#      nssdb::add_cert_and_key{"qpidd":
#        nickname=> 'Server-Cert',
#        cert => '/tmp/server.crt',
#        key  => '/tmp/server.key',
#      }
#
define nssdb::add_cert_and_key (
  $dbname = $title,
  $nickname,
  $cert,
  $key,
  $basedir = '/etc/pki',
  $password_file = "${basedir}/${dbname}/password.conf",
) {
  package { 'openssl': ensure => present }

  exec {'generate_pkcs12':
    command => "/usr/bin/openssl pkcs12 -export -in $cert -inkey $key -password 'file:${password_file}' -out '${basedir}/${dbname}/$dbname.p12' -name $nickname",
    require => [
        File["${password_file}"],
        File["${basedir}/${dbname}/cert8.db"],
        Package['openssl'],
    ],
    before => Exec['load_pkcs12'],
    notify => Exec['load_pkcs12'],
    subscribe => File["${password_file}"],
    refreshonly => true,
  }

  exec {'load_pkcs12':
    command => "/usr/bin/pk12util -i '${basedir}/${dbname}/$dbname.p12' -d '${basedir}/${dbname}' -w '${password_file}' -k '${password_file}'",
    require => [
        Exec["generate_pkcs12"],
        Package['nss-tools'],
    ],
    refreshonly => true,
  }
}
