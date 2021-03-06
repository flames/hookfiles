#!/usr/bin/perl

=head1 NAME

    Hooks::Postfix::Sender::Canonical
 
=cut

# i-MSCP - internet Multi Server Control Panel
# Copyright (C) 2013-2014 by Sascha Bay
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
# @category i-MSCP
# @copyright 2013-2014 by Sascha Bay
# @author Sascha Bay <info@space2place.de>
# @link http://i-mscp.net i-MSCP Home Site
# @license http://www.gnu.org/licenses/gpl-2.0.html GPL v2

package Hooks::Postfix::Sender::Canonical;
 
use strict;
use warnings;
 
use iMSCP::Debug;
use iMSCP::HooksManager;
use iMSCP::Execute;

my $postfixSenderCanoncial = '/etc/postfix/imscp/sender_canonical';
my $addSenderCanoncial = "sender_canonical_maps = hash:/etc/postfix/imscp/sender_canonical\n";
 
=head1 DESCRIPTION

 Hook file adds a sender canoncial map to the i-MSCP MTA (Postfix)

 How to install:
 - Create a file /etc/postfix/imscp/sender_canonical if it doesn't exists
 - Put this file into the /etc/imscp/hooks.d directory (create it if it doesn't exists)
 - Make this file only readable by root user (chmod 0600);

 Hook file compatible with i-MSCP >= 1.1.0

=head1 PUBLIC METHODS

=over 4

=item onAfterMtaBuildPostfixSenderCanoncial(\$tplContent)

 Sender canoncial map directive

 Param scalar_ref $tplContent Reference to template content
 Return int 0 on success other on failure

=cut

sub onAfterMtaBuildPostfixSenderCanoncial($)
{
	my $tplContent = shift;

	if (-f $postfixSenderCanoncial) {
		my ($stdout, $stderr);
		my $rs = execute("/usr/sbin/postmap $postfixSenderCanoncial", \$stdout, \$stderr);
		debug($stdout) if $stdout;
		error($stderr) if $stderr && $rs;
		return $rs if $rs;

		$$tplContent .= "$addSenderCanoncial";
	} else {
		error("File: $postfixSenderCanoncial not found");
		return 1;
	}

	0;
}

iMSCP::HooksManager->getInstance()->register('afterMtaBuildMainCfFile', \&onAfterMtaBuildPostfixSenderCanoncial);
 
=back
 
=head1 AUTHOR

 Sascha Bay <info@space2place.de>
 
=cut
 
1;
