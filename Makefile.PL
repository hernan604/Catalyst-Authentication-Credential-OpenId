use inc::Module::Install 0.87;
use strict;
use warnings;

name      "Catalyst-Authentication-Credential-OpenID";
all_from  "lib/Catalyst/Authentication/Credential/OpenID.pm";
author    "Ashley Pond V <ashley\@cpan.org>";

requires "Class::Accessor::Fast" => undef;
requires "HTML::Parser"     => "3";
requires "LWP::UserAgent"    => undef;
requires "Cache::FastMmap"    => "1.28";
requires "Catalyst"       => "5.7";
requires "Catalyst::Devel"    => "1";
requires "Net::OpenID::Consumer" => "1.03";
requires "Catalyst::Authentication::User::Hash" => undef;
requires "Catalyst::Plugin::Session::Store::FastMmap" => "0.05";
requires "Catalyst::Plugin::Session::State::Cookie" => "0.08";
requires "Catalyst::Engine::HTTP" => undef;

recommends "Config::General"     => "2";
recommends "YAML"                => "0.6";
recommends "Math::BigInt"        => undef;
recommends "LWPx::ParanoidAgent" => "1.03";

test_requires "Catalyst::Engine::HTTP";

test_requires "Test::More"      => "0.42";
# test_requires "Test::WWW::Mechanize" => "1.20";
# test_requires "Net::OpenID::Server" => "1.02";
# test_requires "Net::DNS"       => undef;
# test_requires "IO::Socket::INET"   => undef;

if ( $Module::Install::AUTHOR )
{
    system("pod2text lib/Catalyst/Authentication/Credential/OpenID.pm > README") == 0
        or die "Couldn't update the README";
}

auto_install;
resources repository => 'http://dev.catalyst.perl.org/repos/Catalyst/Catalyst-Authentication-Credential-OpenID/';

WriteAll;

__END__
