use strict;
use warnings;

use IPC::Open3;
use Test::More;

# Make sure Module::Util::is_valid_module_name agrees with perl for every module
# on CPAN

my @modules;

BEGIN {
    require CPAN;

    @modules =
        map  { $_->id }
        CPAN::Shell->expand("Module", "/./");

    plan tests => 1 + @modules;

    use_ok('Module::Util', qw( is_valid_module_name ));
}

# Check that the module name is really valid.
# Not all modules reported by CPAN are!
sub really_valid ($) {
    my $module = shift;

    eval "package $module";
    return !$@;
}

for my $module (@modules) {
    my $valid = really_valid($module);
    my $ok = not (is_valid_module_name($module) xor $valid);

    ok($ok, "'$module' is ".($valid ? '' : 'not')." valid");
}

__END__

vim: ft=perl ts=8 sts=4 sw=4 sr et
