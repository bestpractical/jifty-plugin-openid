use inc::Module::Install;
name('Jifty-Plugin-OpenID');
all_from('lib/Jifty/Plugin/OpenID.pm');

requires('Jifty');
requires('Net::OpenID::Consumer');
requires('Cache::FileCache');
requires('Test::OpenID::Server' );
requires('LWPx::ParanoidAgent');

auto_install();
tests(qw( t/*/t/*.t ));

WriteAll;
