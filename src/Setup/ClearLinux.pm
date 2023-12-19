package PVE::LXC::Setup::ClearLinux;

use strict;
use warnings;

use PVE::Tools;
use PVE::LXC;
use File::Path;

use PVE::LXC::Setup::Debian;

use base qw(PVE::LXC::Setup::Debian);

sub new {
    my ($class, $conf, $rootdir) = @_;

    my $os_release = "$rootdir/etc/os-release";
    my $os_info = PVE::Tools::file_get_contents($os_release);

    my $version;
	$version = "40450";

    my $self = { conf => $conf, rootdir => $rootdir, version => $version };

    $conf->{ostype} = "ClearLinux";

    return bless $self, $class;
}

# ClearLinux doesn't support the /dev/lxc/ subdirectory.
sub devttydir {
    return '';
}

sub template_fixup {
    my ($self, $conf) = @_;

    my $version = $self->{version};

	# create basic config directories not preset in cl due to stateless design
	$self->ct_mkdir('/etc/systemd', 0755);
    $self->ct_mkdir('/etc/systemd/system', 0755);

    # tty
    my $filename = '/etc/udev/udev.conf';
    my $data = $self->ct_file_get_contents($filename);
    $self->ct_file_set_contents($filename, $data);


	# enable systemd-networkd
	# $self->ct_mkdir('/etc/systemd/system/multi-user.target.wants');
	# $self->ct_mkdir('/etc/systemd/system/socket.target.wants');
	# $self->ct_symlink('/lib/systemd/system/systemd-networkd.service',
	# 		  '/etc/systemd/system/multi-user.target.wants/systemd-networkd.service');
	# $self->ct_symlink('/lib/systemd/system/systemd-networkd.socket',
	# 		  '/etc/systemd/system/socket.target.wants/systemd-networkd.socket');

	# unlink default netplan lxc config
	# $self->ct_unlink('/etc/netplan/10-lxc.yaml');
}

sub setup_init {
    my ($self, $conf) = @_;

    my $version = $self->{version};

    # enable networkd
	$self->setup_systemd_preset({ 'systemd-networkd.service' => 1 });

    # setup getty service
    # $self->setup_container_getty_service($conf);
}

sub setup_network {
    my ($self, $conf) = @_;

	$self->ct_mkdir('/etc/systemd/network');

	$self->setup_systemd_networkd($conf);
}

1;
