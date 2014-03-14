#!/usr/bin/perl

=head1 NAME

    Plugin::CustomHosts
 
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
# @category    i-MSCP
# @copyright   2010-2013 by i-MSCP | http://i-mscp.net
# @author      Joan Juvanteny <aseques@gmail.com>
# @link        http://i-mscp.net i-MSCP Home Site
# @license     http://www.gnu.org/licenses/gpl-2.0.html GPL v2

package Plugin::CustomHost;

use strict;
use warnings;
 
use iMSCP::Debug;
use iMSCP::HooksManager;
use iMSCP::File;
 
my $sysHostsFile = '/etc/hosts';
my $customHostsFile = '/etc/imscp/hooks.files/hosts.custom';
 
=head1 DESCRIPTION
 
 Plugin allowing to add custom content at end of system hosts file.

 How to install:
 - If it doesn't exist create the folder /etc/imscp/hooks.files/
 - Create the file /etc/imscp/hooks.files/hosts.custom with the hosts entries
     that you want to preserve across imscp upgrades
 - This hook will be triggered with 'perl imscp-setup' without parameters

 Hook file compatible with i-MSCP >= 1.1.0
 
=head1 PUBLIC METHODS
 
=over 4
 
=item addCustomHosts
 
 Add custom hosts file content to the end of system hosts file
 
 Return int 0 on success, other on failure
 
=cut
 
sub addCustomHosts
{
    if (-f $sysHostsFile) {
        if(-f $customHostsFile) {
            my $sysHostsFile = iMSCP::File->new('filename' => $sysHostsFile);
            my $sysHostsFileContent = $sysHostsFile->get();

            unless(defined $sysHostsFileContent) {
                error("Unable to read $sysHostsFile");
                return 1;
            }
        
            my $customHostsFile = iMSCP::File->new('filename' => $customHostsFile);
            my $customHostsFileContent = $customHostsFile->get();

            if(defined $customHostsFileContent) {
                $sysHostsFileContent .= $customHostsFileContent;
                $sysHostsFile->set($sysHostsFileContent);

                my $rs = $sysHostsFile->save();
                return $rs if $rs;

                $rs = $sysHostsFile->owner('user' => $main::imscpConfig{'ROOT_USER'}, 'group' => $main::imscpConfig{'ROOT_GROUP'});
                return $rs if $rs;

                $rs = $sysHostsFile->mode(0644);
                return $rs if $rs;
            } else {
                error('Unable to read $customHostsFile');
                return 1;
            }
        } else {
            debug("Custom host file not found");
        }
    } else {
        error("System host file not found");
        return 1;
    }
 
    0;
}

my $hooksManager = iMSCP::HooksManager->getInstance();
$hooksManager->register('afterSetupServerHostname', \&addCustomHosts);
 
=back
 
=head1 AUTHOR
 
 Joan Juvanteny <aseques@gmail.com>
 
=cut
 
1; 
