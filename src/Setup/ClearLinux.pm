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
    $self->ct_mkdir('/etc/systemd/system/multi-user.target.wants', 0755);
     $self->ct_mkdir('/etc/systemd/system/getty.target.wants', 0755);

    #$self->ct_symlink('/lib/systemd/system/container-getty@.service', '/etc/systemd/system/multi-user.target.wants/systemd-networkd.service');

    

    # create empty shadow file to set root password
    $self->ct_file_set_contents('/etc/shadow', '');

    # tty
    my $filename = '/etc/udev/udev.conf';
    if ($self->ct_file_exists($filename)) {
    	my $data = $self->ct_file_get_contents($filename);
	$self->ct_file_set_contents($filename, $data);
    }
    
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
    $self->setup_container_getty_service($conf);
}

sub setup_network {
    my ($self, $conf) = @_;

    $self->ct_mkdir('/etc/systemd/network');
    $self->setup_systemd_networkd($conf);
}

sub setup_container_getty_service {
    my ($self, $conf) = @_;

    my $sd_dir = $self->ct_is_executable("/lib/systemd/systemd") ?
	"/lib/systemd/system" : "/usr/lib/systemd/system";

    # prefer container-getty.service shipped by newer systemd versions
    # fallback to getty.service and just return if that doesn't exists either..
    my $template_base = "container-getty\@";
    my $template_path = "${sd_dir}/${template_base}.service";
    my $instance_base = $template_base;

    if (!$self->ct_file_exists($template_path)) {
	$template_base = "getty\@";
	$template_path = "${template_base}.service";
	$instance_base = "{$template_base}tty";
	return if !$self->ct_file_exists($template_path);
    }

    my $raw = $self->ct_file_get_contents($template_path);
    my $ttyname = $self->devttydir($conf) . 'tty%I';
    if ($raw =~ s@pts/%I|lxc/tty%I@$ttyname@g) {
	$self->ct_file_set_contents($template_path, $raw);
    }

    my $getty_target_fn = "/etc/systemd/system/getty.target.wants/";
    my $ttycount = PVE::LXC::Config->get_tty_count($conf);

    for (my $i = 1; $i < 7; $i++) {
	# ensure that not two gettys are using the same tty!
	$self->ct_unlink("$getty_target_fn/getty\@tty$i.service");
	$self->ct_unlink("$getty_target_fn/container-getty\@$i.service");

	# re-enable only those requested
	if ($i <= $ttycount) {
	    my $tty_service = "${instance_base}${i}.service";

	    $self->ct_symlink($template_path, "$getty_target_fn/$tty_service");
	}
    }

    # ensure getty.target is not masked
    $self->ct_unlink("/etc/systemd/system/getty.target");
}

1;
