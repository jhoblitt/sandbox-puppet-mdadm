include stdlib
include augeas

class { 'mdadm':
  config_file_options => { 'mailaddr' => 'root' },
}
