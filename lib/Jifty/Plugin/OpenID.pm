use strict;
use warnings;

package Jifty::Plugin::OpenID;
use base qw/Jifty::Plugin/;

our $VERSION = '0.10';

=head1 NAME

Jifty::Plugin::OpenID - Provides OpenID authentication for your jifty app

=head1 DESCRIPTION

Provides OpenID authentication for your app

=cut

sub init {
    my $self = shift;
    my %opt = @_;
    my $ua_class = $self->get_ua_class;
    eval "require $ua_class";
}

sub get_ua_class {
    return Jifty->config->app('OpenIDUA') 
                || $ENV{OpenIDUserAgent} 
                || 'LWPx::ParanoidAgent' ;
}

sub new_ua {
    my $class = shift;
    my $ua;
    my $ua_class = $class->get_ua_class;
    if( $ua_class eq 'LWPx::ParanoidAgent' ) {
         $ua = LWPx::ParanoidAgent->new(
                        whitelisted_hosts => [ $ENV{JIFTY_OPENID_WHITELIST_HOST} ]
                     );
    }
    else {
        $ua = $ua_class->new;
    }
    return $ua;
}


sub get_csr {
    my $class = shift;
    return Net::OpenID::Consumer->new(
        ua              => $class->new_ua ,
        cache           => Cache::FileCache->new,
        args            => scalar Jifty->handler->cgi->Vars,
        consumer_secret => Jifty->config->app('OpenIDSecret'),
        @_,
    );
}

1;
