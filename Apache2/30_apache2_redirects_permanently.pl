# i-MSCP Listener::Apache2::Redirect::Permanently listener file
# Copyright (C) 2015 Ninos Ego <me@ninosego.de>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
#
## i-MSCP listener file which changes the domain redirect type in customers's vhost files from 302 to 301
#

package Listener::Apache2::Redirect::Permanently;

# Listener responsible to change domain redirect type from 302 to 301 in Apache2 vhost files, before they are built by i-MSCP
sub changeRedirectType
{
	my ($cfgTpl, $tplName) = @_;

	if($tplName =~ /^domain_redirect(?:_ssl)?\.tpl$/) {
		my $search = "Redirect / {FORWARD}\n";
		my $replace = "Redirect 301 / {FORWARD}\n";

		$$cfgTpl =~ s/$search/$replace/;
	}

	0;
}

# Register event listeners on the event manager
my $eventManager = iMSCP::EventManager->getInstance();
$eventManager->register('beforeHttpdBuildConf', \&changeRedirectType);

1;
__END__