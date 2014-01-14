#!/usr/bin/perl

=head1 NAME

 Hooks::Postfix::Smarthost - Hook file allowing to configure the i-MSCP MTA (Postfix) as smarthost with SALS authentication

=cut

# i-MSCP - internet Multi Server Control Panel
# Copyright 2010-2013 by internet Multi Server Control Panel
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# @category    i-MSCP
# @copyright   2010-2013 by i-MSCP | http://i-mscp.net
# @author      Lauren Declercq <l.declercq@nuxwin.com>
# @link        http://i-mscp.net i-MSCP Home Site
# @license     http://www.gnu.org/licenses/gpl-2.0.html GPL v2

package Hooks::Postfix::Smarthost;

use iMSCP::Debug;
use iMSCP::HooksManager;
use iMSCP::Execute;
use iMSCP::File;
use Servers::mta;

# Configuration variables.
my $relayhost = 'smtp.host.tld';
my $relayport = '587';
my $saslAuthUser = '';
my $saslAuthPasswd = '';
my $saslPasswdMapsPath = '/etc/postfix/relay_passwd';

=head1 DESCRIPTION

 Hook file allowing to configure the i-MSCP MTA (Postfix) as smarthost with SASL authentication.

 How to install:
 - Edit configuration variables above
 - Put this file into the /etc/imscp/hooks.d directory (create it if it doesn't exists)
 - Make this file only readable by root user (chmod 0600);

 Hook file compatible with i-MSCP >= 1.1.0

=head1 PUBLIC METHODS

=over 4

=item

 Create SMTP SASL password maps

 Return int 0 on success, other on failure

=cut

sub createSaslPasswdMaps
{
	my $saslPasswdMapsFile = iMSCP::File->new('filename' => $saslPasswdMapsPath);
	$saslPasswdMapsFile->set("$relayhost:$relayport\t$saslAuthUser:$saslAuthPasswd");

	my $rs = $saslPasswdMapsFile->save();
	return $rs if $rs;

	$rs = $saslPasswdMapsFile->mode(0600);
	return $rs if $rs;

	# Schedule postmap of sasl password maps file
	Servers::mta->factory()->{'postmap'}->{$saslPasswdMapsPath} = 1;

	0;
}

=item configureSmartHost()

 Add relayhost and SMTP SASL parameters in Postfix main.cf

 Return int 0

=cut

sub configureSmartHost
{
	my $fileContent = shift;

	$$fileContent .= <<EOF;

# Added by Plugins::Postfix::Smarthost
relayhost=$relayhost:$relayport
smtp_sasl_auth_enable=yes
smtp_sasl_password_maps=hash:$saslPasswdMapsPath
smtp_sasl_security_options=noanonymous
EOF

	0;
}

my $hooksManager = iMSCP::HooksManager->getInstance();
$hooksManager->register('afterMtaBuildMainCfFile', \&createSaslPasswdMaps);
$hooksManager->register('afterMtaBuildMainCfFile', \&configureSmartHost);

=back

=head1 AUTHOR

 Laurent Declercq <l.declercq@nuxwin.com>

=cut

1;
