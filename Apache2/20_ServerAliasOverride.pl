#!/usr/bin/perl

=head1 NAME

    Plugins::Http::ServerAliasOverride;
 
=cut

# i-MSCP - internet Multi Server Control Panel
# Copyright (C) 2010-2013 by internet Multi Server Control Panel
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
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
#
# @category i-MSCP
# @package iMSCP_Plugin
# @subpackage ServerAliasOverride
# @copyright 2010-2013 by i-MSCP | http://i-mscp.net
# @author Laurent Declercq <l.declercq@nuxwin.com>
# @contributor Sascha Bay <info@space2place.de>
# @link http://i-mscp.net i-MSCP Home Site
# @license http://www.gnu.org/licenses/gpl-2.0.html GPL v2

package Plugins::Http::ServerAliasOverride;

use strict;
use warnings;
 
use iMSCP::Debug;
use iMSCP::HooksManager;
use Servers::httpd;

# Configuration variables.
my $searchDomain = 'example.com';
my $addServerAlias = 'example'; # Add more than one alias (example example-2 example-3.com)

=head1 DESCRIPTION

 Hook file allowing to add additional alias domains in the virtual host of a domain.

 How to install:
 - Edit configuration variables above
 - Put this file into the /etc/imscp/hooks.d directory (create it if it doesn't exists)
 - Make this file only readable by root user (chmod 0600);

 Hook file compatible with i-MSCP >= 1.1.0

=head1 PUBLIC METHODS

=over 4

=item

 Adds additional alias domains in the virtual host

 Return int 0 on success, other on failure

=cut

my $hooksManager = iMSCP::HooksManager->getInstance();

sub overrideServerAlias
{
	my ($tplFileContent, $tplFileName) = @_;
	
	my $httpd = Servers::httpd->factory();
	my $domainName = (defined $httpd->{'data'}->{'DOMAIN_NAME'}) ? $httpd->{'data'}->{'DOMAIN_NAME'} : undef;

	if(
		$domainName && $domainName eq $searchDomain &&
		$tplFileName ~~ ['domain_redirect.tpl', 'domain.tpl', 'domain_redirect_ssl.tpl', 'domain_ssl.tpl']
	) {
		$$tplFileContent =~ s/^(\s+ServerAlias.*)/$1 $addServerAlias/m;
	}

	0;
}

$hooksManager->register('afterHttpdBuildConf', \&overrideServerAlias);

1;
