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
        if ($data =~ /\S+ (\S+)\[\S+@(\S+)\]/ && $1 eq $requested_nick) {
            $waiting_for_stats = 0;
            my $host = $2;
            get_iline($server, $target_channel, $host);
        } elsif ($data =~ /\S+ (\S+)\[@(\S+)\]/ && $1 eq $requested_nick) {
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
    return $ip =~ /^[\dA-Fa-f]{1,4}(:[\dA-Fa-f]{1,4})*$/;
}

sub get_iline {
    my ($server, $target, $ip) = @_;
    my $api_url = "https://bot.ircnet.info/api/i-line?q=$ip";
    my $response = http_get($api_url);

    if ($response) {
        my $data = decode_json($response);
        if ($data->{"status"} eq "SUCCESS") {
            my @server_list = map { $_->{"serverName"} } @{$data->{"response"}};
            my $server_str = join(', ', @server_list);
            $server->command("MSG $target Iline dla $ip to: $server_str");
        } else {
            $server->command("MSG $target Błąd: Nie udało się pobrać danych iline.");
        }
    } else {
        $server->command("MSG $target Błąd: Nie udało się pobrać danych iline.");
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
