#!/usr/bin/perl

# Skript zum Importieren einer vCard in die SQL Ledger-Datenbank

use strict;
use warnings;
use DBI;

my $filename = $ARGV[0];
my ($name, $number);

my $driver = "Pg"; 
my $database = "sql-ledger";
my $dsn = "DBI:$driver:database=$database";
my $userid = "postgres";
my $password = "";

my $dbh = DBI->connect($dsn, $userid, $password ) or die $DBI::errstr;




die "Usage: $0 filename\n" unless $filename; # checking command line parameter
open my $fh, "<", "$filename" or die "$!";
open my $fh2, ">", "list.txt" or die "$!";

my @matches=();

while(my $line = <$fh>) {

        if (grep { $line =~ $_ } qr/^\s*FN/, qr/\s*TEL/){

                if( $line =~ /^\s*FN:(.*)/ ) {
                  push(@matches,$1);
                }
                elsif( $line =~ /^\s*TEL;TYPE=CELL;TYPE=PREF:(.*)/ ) {
                  push(@matches , $1);
                }
       }
       else{
               next;
       }
}
print $fh2 "@matches" ;

my $sth = $dbh->prepare("INSERT INTO names (first_name) VALUES 
                            ('@matches')");
$sth->execute;

close $fh2 or die "$!";
close $fh or die "$!";
