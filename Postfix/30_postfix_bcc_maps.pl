#!/usr/bin/perl

=head1 NAME

    Hooks::Postfix::BCC::Maps
 
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

package Hooks::Postfix::BCC::Maps;
 
use strict;
use warnings;
 
use iMSCP::Debug;
use iMSCP::HooksManager;
use iMSCP::Execute;

my $postfixRecipientBccMap = '/etc/postfix/imscp/recipient_bcc_map';
my $postfixSenderBccMap = '/etc/postfix/imscp/sender_bcc_map';
my $addRecipientBccMap = "recipient_bcc_maps = hash:/etc/postfix/imscp/recipient_bcc_map\n";
my $addSenderBccMap = "sender_bcc_maps = hash:/etc/postfix/imscp/sender_bcc_map\n";
 
=head1 DESCRIPTION

 Hook file adds a recipient/sender bcc map to the i-MSCP MTA (Postfix)

 How to install:
 - Create a file /etc/postfix/imscp/recipient_bcc_map if it doesn't exists
 - Create a file /etc/postfix/imscp/sender_bcc_map if it doesn't exists
 - Put this file into the /etc/imscp/hooks.d directory (create it if it doesn't exists)
 - Make this file only readable by root user (chmod 0600);

 Hook file compatible with i-MSCP >= 1.1.0

=head1 PUBLIC METHODS

=over 4

=item onAfterMtaBuildPostfixBccMap(\$tplContent)

 Postfix Bcc Map directive

 Param scalar_ref $tplContent Reference to template content
 Return int 0 on success other on failure

=cut

sub onAfterMtaBuildPostfixBccMap($)
{
	my $tplContent = shift;

	if (-f $postfixRecipientBccMap) {
		if (-f $postfixSenderBccMap) {
			my ($stdout, $stderr);
			my $rs = execute("/usr/sbin/postmap $postfixRecipientBccMap", \$stdout, \$stderr);
			debug($stdout) if $stdout;
			error($stderr) if $stderr && $rs;
			return $rs if $rs;
			 
			$rs = execute("/usr/sbin/postmap $postfixSenderBccMap", \$stdout, \$stderr);
			debug($stdout) if $stdout;
			error($stderr) if $stderr && $rs;
			return $rs if $rs;

			$$tplContent .= "$addRecipientBccMap";
			$$tplContent .= "$addSenderBccMap";
		} else {
			error("File $postfixSenderBccMap not found");
			return 1;
		}
	} else {
		error("File: $postfixRecipientBccMap not found");
		return 1;
	}

	0;
}

iMSCP::HooksManager->getInstance()->register('afterMtaBuildMainCfFile', \&onAfterMtaBuildPostfixBccMap);
 
=back
 
=head1 AUTHOR

 Sascha Bay <info@space2place.de>
 
=cut
 
1;
