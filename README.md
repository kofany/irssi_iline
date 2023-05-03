# Skrypt I-Line dla Irssi kożysta z api https://ircnet.info (Polski)

Ten skrypt pozwala na pobieranie informacji o I-Line dla podanego adresu IP lub nicku w kliencie IRC Irssi. Wysyła żądanie do API, a następnie wyświetla informacje o I-Line na kanale, na którym wydano polecenie.

## Instalacja

1. Zapisz skrypt w katalogu `~/.irssi/scripts/`. Jeśli katalog `scripts` nie istnieje, najpierw go utwórz.

2. Jeśli chcesz, aby skrypt był automatycznie ładowany podczas uruchamiania Irssi, utwórz katalog `~/.irssi/scripts/autorun/` (jeśli jeszcze nie istnieje) i utwórz w nim dowiązanie symboliczne do skryptu:

ln -s ~/.irssi/scripts/iline_pl.pl ~/.irssi/scripts/autorun/iline_pl.pl


3. Aby załadować skrypt ręcznie, wpisz w oknie Irssi:

/script load iline_pl.pl


## Użycie

Na kanale wpisz:

.iline IP_adres


lub

.iline nick

Skrypt pobierze informacje o I-Line dla podanego adresu IP lub nicku i wyświetli je na kanale.


# I-Line Script for Irssi use https://ircnet.info api (English)

This script allows you to get I-Line information for a given IP address or nickname in the Irssi IRC client. It sends a request to an API and then displays the I-Line information in the channel where the command was issued.

## Installation

1. Save the script to your `~/.irssi/scripts/` directory. If the `scripts` directory doesn't exist, create it first.

2. If you want the script to be automatically loaded when starting Irssi, create the `~/.irssi/scripts/autorun/` directory (if it doesn't exist yet) and create a symbolic link to the script in it:

ln -s ~/.irssi/scripts/iline_en.pl ~/.irssi/scripts/autorun/iline_en.pl


3. To manually load the script, type in the Irssi window:

/script load iline_en.pl


## Usage

In a channel, type:

.iline IP_address

or

.iline nickname


The script will fetch the I-Line information for the given IP address or nickname and display it in the channel.
