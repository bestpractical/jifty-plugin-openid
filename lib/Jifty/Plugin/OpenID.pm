use strict;
use warnings;

package Jifty::Plugin::OpenID;
use base qw/Jifty::Plugin/;

our $VERSION = '1.00';

=head1 NAME

Jifty::Plugin::OpenID - Provides OpenID authentication for your jifty app

=head1 DESCRIPTION

Provides OpenID authentication for your app

=head1 USAGE

=head2 Config

please provide C<OpenIDSecret> in your F<etc/config.yml> , the C<OpenIDUA> is
B<optional> , OpenID Plugin will use L<LWPx::ParanoidAgent> by default.

    --- 
    application:
        OpenIDSecret: 1234
        OpenIDUA: LWP::UserAgent

or you can set C<OpenIDUserAgent> environment var in command-line:

    OpenIDUserAgent=LWP::UserAgent bin/jifty server

if you are using L<LWPx::ParanoidAgent> as your openid agent. 
you will need to provide C<JIFTY_OPENID_WHITELIST_HOST> for your own OpenID server.

    export JIFTY_OPENID_WHITELIST_HOST=123.123.123.123

=head2 User Model

Create your user model , and let it uses
L<Jifty::Plugin::OpenID::Mixin::Model::User> to mixin "openid" column.
and a C<name> method.

    use TestApp::Record schema {

        column email =>
            type is 'varchar';

    };
    use Jifty::Plugin::OpenID::Mixin::Model::User;

    sub name {
        my $self = shift;
        return $self->email;
    }

Note: you might need to declare a C<name> method. because the OpenID
CreateOpenIDUser action and SkeletonApp needs current_user->username to show
welcome message and success message , which calls C<brief_description> method.
See L<Jifty::Record> for C<brief_description> method.

=head2 View

OpenID plugin provides AuthenticateOpenID Action. so that you can render an
AuthenticateOpenID in your template:

    form {
        my $openid = new_action( class   => 'AuthenticateOpenID',
                                moniker => 'authenticateopenid' );
        render_action( $openid );
    };

this action renders a form which provides openid url field.
and you will need to provide a submit button in your form.  

    form {
        my $openid = new_action( class   => 'AuthenticateOpenID',
                                moniker => 'authenticateopenid' );

        # ....

        render_action( $openid );
        outs_raw(
            Jifty->web->return(
                to     => '/openid_verify_done',
                label  => _("Login with OpenID"),
                submit => $openid
            ));
    };

the C<to> field is for verified user to redirect to.
so that you will need to implement a template called C</openid_verify_done>:

    template '/openid_verify_done' => page {
        h1 { "Done" };
    };

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

    Jifty->log->info( "OpenID Plugin is using $ua_class as UserAgent" );

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

=head1 AUTHORS

Alex Vandiver, Cornelius  <cornelius.howl {at} gmail.com >

=head1 LICENSE

Copyright 2005-2009 Best Practical Solutions, LLC.

This program is free software and may be modified and distributed under the same terms as Perl itself.

=cut

1;
