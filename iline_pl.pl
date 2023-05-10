# Autor: Jerzy (kofany) Dąbrowski

use strict;
use warnings;
use JSON::PP qw(decode_json);
use LWP::Simple;
use Socket;

my $VERSION = '0.5';
my %IRSSI = (
    authors     => 'Jerzy "kofany" Dabrowski',
    contact     => '/msg kofany@ircnet',
    name        => 'iline',
    description => 'Fetches the I-line servers for an IP address using https://ircnet.info api',
    license     => 'GNU GPLv3 or later',
    url         => 'https://github.com/kofany/irssi_iline',
);

my $waiting_for_stats = 0;
my $requested_nick = "";
my $target_channel = "";

sub on_public {
    my ($server, $msg, $nick, $address, $target) = @_;
    if ($msg =~ /^\.(iline) (\S+)/) {
        my $arg = $2;
        if (is_ipv4($arg) || is_ipv6($arg)) {
            get_iline($server, $target, $arg);
        } else {
            $requested_nick = $arg;
            $waiting_for_stats = 1;
            $target_channel = $target;
            $server->send_raw("STATS L $arg");
        }
    }
}

sub on_server_event {
    my ($server, $data, $nick, $address) = @_;
    if ($waiting_for_stats) {
        if ($data =~ /\S+ (\S+)\[\S+@(\S+)\]/ && lc($1) eq lc($requested_nick)) {
            $waiting_for_stats = 0;
            my $host = $2;
            get_iline($server, $target_channel, $host);
        } elsif ($data =~ /\S+ (\S+)\[@(\S+)\]/ && lc($1) eq lc($requested_nick)) {
            $waiting_for_stats = 0;
            my $host = $2;
            get_iline($server, $target_channel, $host);
        }
    }
}


sub is_ipv4 {
    my ($ip) = @_;
    return $ip =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/;
}

sub is_ipv6 {
    my ($ip) = @_;
    return $ip =~ /^(([\da-fA-F]{1,4}:){7,7}[\da-fA-F]{1,4}|([\da-fA-F]{1,4}:){1,7}:|([\da-fA-F]{1,4}:){1,6}:[\da-fA-F]{1,4}|([\da-fA-F]{1,4}:){1,5}(:[\da-fA-F]{1,4}){1,2}|([\da-fA-F]{1,4}:){1,4}(:[\da-fA-F]{1,4}){1,3}|([\da-fA-F]{1,4}:){1,3}(:[\da-fA-F]{1,4}){1,4}|([\da-fA-F]{1,4}:){1,2}(:[\da-fA-F]{1,4}){1,5}|[\da-fA-F]{1,4}:((:[\da-fA-F]{1,4}){1,6})|:((:[\da-fA-F]{1,4}){1,7}|:))$/;
}


sub get_iline {
    my ($server, $target, $ip) = @_;
    my $ircnet_api_url = "https://bot.ircnet.info/api/i-line?q=$ip";
    my $ip_api_url = "http://ip-api.com/json/$ip?fields=status,countryCode,regionName,city,isp,org,as";
    
    my $iline_response = http_get($ircnet_api_url);
    my $ip_info_response = http_get($ip_api_url);

    if ($iline_response) {
        my $iline_data = decode_json($iline_response);
        if ($iline_data->{"status"} eq "SUCCESS") {
            my @server_list = map { $_->{"serverName"} } @{$iline_data->{"response"}};
            my $server_str = join(', ', @server_list);
            $server->command("MSG $target Iline dla $ip to: $server_str");
        } else {
            $server->command("MSG $target Błąd: Nie udało się pobrać danych iline.");
        }
    } else {
        $server->command("MSG $target Błąd: Nie udało się pobrać danych iline.");
    }

    if ($ip_info_response) {
        my $ip_info_data = decode_json($ip_info_response);
        if ($ip_info_data->{"status"} eq "success") {
            my $country_code = $ip_info_data->{"countryCode"};
            my $region_name = $ip_info_data->{"regionName"};
            my $city = $ip_info_data->{"city"};
            my $isp = $ip_info_data->{"isp"};
            my $org = $ip_info_data->{"org"};
            my $as = $ip_info_data->{"as"};

            $server->command("MSG $target Informacje o IP ($ip): Kraj: $country_code, Region: $region_name, Miasto: $city, ISP: $isp, Organizacja: $org, AS: $as");
        } else {
            $server->command("MSG $target Błąd: Nie udało się pobrać informacji o IP.");
        }
    } else {
        $server->command("MSG $target Błąd: Nie udało się pobrać informacji o IP.");
    }
}


sub http_get {
    my ($url) = @_;
    my $response = get($url);

    if (defined $response) {
        return $response;
    }
    return undef;
}

Irssi::signal_add("message public", "on_public");
Irssi::signal_add("server event", "on_server_event");
Irssi::print("iline by kofany załadowany");
Irssi::print("Informacje pobiera z https://ircnet.info api by patrick");
