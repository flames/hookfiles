#!/usr/bin/perl

=head1 NAME

 Hooks::Bind9::Localnets

=cut

# i-MSCP - internet Multi Server Control Panel
# Copyright (C) 2013-2014 by Laurent Declercq
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
# @category    i-MSCP
# @copyright   2013-2014 by i-MSCP | http://i-mscp.net
# @author      Laurent Declercq <l.declercq@nuxwin.com>
# @link        http://i-mscp.net i-MSCP Home Site
# @license     http://www.gnu.org/licenses/gpl-2.0.html GPL v2

package Hooks::Bind9::Localnets;

use iMSCP::HooksManager;

=head1 DESCRIPTION

 Hook file allowing usage of i-MSCP DNS server on local network.

 Hook file compatible with i-MSCP >= 1.1.0

=head1 PUBLIC METHODS

=over 4

=item onBeforeNamedBuildConf

 Allow usage of i-MSCP DNS server on local network.

 Return int 0

=cut

sub onBeforeNamedBuildConf
{
	my $tplContent = shift;
	my $tplName = shift;

	if($tplName eq 'named.conf.options') {
		$$tplContent =~ s/^(\s*allow-recursion).*$/$1 { localnets; };/m;
		$$tplContent =~ s/^(\s*allow-query-cache).*$/$1 { localnets; };/m;
		$$tplContent =~ s/^(\s*allow-transfer).*$/$1 { localnets; };/m;
	}

	0;
}

iMSCP::HooksManager->getInstance()->register('beforeNamedBuildConf', \&onBeforeNamedBuildConf);

=back

=head1 AUTHOR

 Laurent Declercq <l.declercq@nuxwin.com>

=cut

1;
