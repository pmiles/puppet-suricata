# == Class: suricata
#
# Module to install and configure Suricata IDS
#
# === Parameters
#
# 
#
# [*ensure*]
#   Passes to suricata package
#   Defaults to present
#
# [*package_name*]
#   Name of suricata package in repo
#   Default to suricata
#
#
class suricata (
  String $ensure,
  String $package_name,
  Stdlib::Absolutepath $config_dir,
  String $config_name,
  Stdlib::Absolutepath $log_dir,
  Enum['running', 'stopped'] $service_ensure,
  String $service_name,
  Boolean $service_enable,
  String $service_provider,  # Maybe change to Enum.
  Boolean $manage_user,
  String $user,
  String $group,
  Stdlib::Absolutepath $user_shell,
  Stdlib::Absolutepath $bin_path,
  Boolean $base_config_enabled,
  Hash $base_config,
  Optional[String] $interfaces  = split($::interfaces, ',')[0],
  Optional[String] $cmd_options = undef,

    ### START Hiera Lookups ###
  Optional[Hash] $config                 = undef,
  Optional[Array] $classification_config = undef,
  Optional[Array] $reference_config      = undef,
  Optional[Hash] $threshold_config       = undef,
    ### STOP Hiera lookups ###

) {

  if $base_config_enabled and $config {
    $master_config = merge($base_config, $config)
  } elsif $base_config_enabled and ! $config {
    $master_config = $base_config
  } elsif ! $base_config_enabled and $config {
    $master_config = $config
  } elsif ! $base_config_enabled and ! $config {
    fail("${title}: Add config or enable base config")
  }

  contain ::suricata::install
  contain ::suricata::config
  contain ::suricata::service

  Class['::suricata::install']->
  Class['::suricata::config']~>
  Class['::suricata::service']
}
