use strict;
use warnings;

package TestApp::Model::User;
use Jifty::DBI::Schema;

use TestApp::Record schema {

column email =>
   type is 'varchar';

};

use Jifty::Plugin::OpenID::Mixin::Model::User;

# Your model-specific methods go here.

# Openid Plugin use brief_description to get an user identity.
sub name {
    my $self = shift;
    $self->email;
}

1;

