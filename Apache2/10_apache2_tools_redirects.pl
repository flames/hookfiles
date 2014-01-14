#!/usr/bin/perl

=head1 NAME

 Hooks::Apache2::Tools::Redirects - Hook file which adds redirects in customers's vhost files for the i-MSCP tools

=cut

# i-MSCP - internet Multi Server Control Panel
# Copyright (C) 2010-2014 by Laurent Declercq
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
# @copyright   2010-2014 by Laurent Declercq
# @author      Laurent Declercq <l.declercq@nuxwin.com>
# @link        http://i-mscp.net i-MSCP Home Site
# @license     http://www.gnu.org/licenses/gpl-2.0.html GPL v2

package Hooks::Apache2::Tools::Redirects;

use iMSCP::HooksManager;
use iMSCP::TemplateParser;

=head1 DESCRIPTION

 Hook file which adds redirects in customers's vhost files for the i-MSCP tools.

 Hook file compatible with i-MSCP >= 1.1.0

=head1 PUBLIC METHODS

=over 4

=item addToolsRedirects

 Add redirects in customers vhost.

 Return int 0

=cut

sub addToolsRedirects
{
	my ($cfgTpl, $tplName) = @_;

	if($tplName =~ /^domain(?:_ssl)?\.tpl$/) {
		$$cfgTpl = replaceBloc(
			"# SECTION addons BEGIN.\n",
			"# SECTION addons END.\n",
			"    # SECTION addons BEGIN.\n" .
			getBloc(
				"# SECTION addons BEGIN.\n",
				"# SECTION addons END.\n",
				$$cfgTpl
			) .
			process(
				{
					BASE_SERVER_VHOST_PREFIX => $main::imscpConfig{'BASE_SERVER_VHOST_PREFIX'},
					BASE_SERVER_VHOST => $main::imscpConfig{'BASE_SERVER_VHOST'},
				},
				"    RedirectMatch permanent ^(/(?:ftp|pma|webmail)[\/]?)\$ {BASE_SERVER_VHOST_PREFIX}{BASE_SERVER_VHOST}\$1\n"
			) .
			"    # SECTION addons END.\n",
			$$cfgTpl
		);
	}

	0;
}

iMSCP::HooksManager->getInstance()->register('afterHttpdBuildConf', \&addToolsRedirects);

=back

=head1 AUTHOR

 Laurent Declercq <l.declercq@nuxwin.com>

=cut

1;
