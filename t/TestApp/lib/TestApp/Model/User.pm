use strict;
use warnings;

package TestApp::Model::User;
use Jifty::DBI::Schema;

use TestApp::Record schema {


column name =>
    type is 'varchar';

column email =>
    type is 'varchar';

};

use Jifty::Plugin::OpenID::Mixin::Model::User;

# Your model-specific methods go here.

1;

