use strict;
use warnings;

use File::Spec::Functions qw( catfile catdir );
use Test::More tests => 42;

our $module;
BEGIN {
    $module = "Module::Util";
    use_ok($module, qw( :all ));
}

ok(is_valid_module_name($module), 'is_valid_module_name');
ok(find_installed($module),       "find_installed");

my @expected_parts = qw( Module Util.pm );

my $path = module_path($module);

ok(exists($INC{$path}), 'module_path agress with %INC');
is_deeply([module_path_parts($module)], \@expected_parts,
        'module_path_parts()');

is(module_path($path), undef, 'module_path($path) is undef');
ok(!is_valid_module_name($path), 'a path is not a valid module name');
ok(!find_installed($path),       'a path is not a valid module');
is(path_to_module($path), $module, "path_to_module($path) == $module");

$path = module_fs_path($module);
ok($path, "module_fs_path($module)");
is(fs_path_to_module($path), $module, "fs_path_to_module($path) == $module");

is(canonical_module_name("Acme::Don't"), 'Acme::Don::t', "Acme::Don't");

# Module names mustn't have leading or trailing '::' or leading numbers
my @invalid = qw(
        ::
        ::My::Module
        My::Module::
        3l337::M0d3wl
    );

for my $invalid (@invalid) {
    ok(!is_valid_module_name($invalid), "'$invalid' is not valid");
    ok(!find_installed($invalid),       "'$invalid' is not a module");
    ok(!module_path($invalid),          "'$invalid' has no path");
    ok(!module_fs_path($invalid),       "'$invalid' has no fs path");
}

ok(module_is_loaded($module), "Module::Util is loaded");
ok(!module_is_loaded("::Invalid"), "::Invalid is not loaded");

ok(!find_installed($module, 't/lib'), "Module::Util not found in t/lib");

is(all_installed($module, 'lib'), 1, "Module::Util only found once in lib");
is(all_installed("::Invalid"), 0, "::Invalid is not installed at all");

SKIP: {
    # These tests require File::Find::Rule
    eval { require File::Find::Rule };
    skip('File::Find::Rule not installed', 2 + @invalid) if $@;

    my @in_ns;
    my $dir = catdir(qw( t data ));
    @in_ns = find_in_namespace('NS', $dir);
    is_deeply(\@in_ns, ['NS::One'], 'find_in_namespace');

    @in_ns = find_in_namespace('', $dir);
    is_deeply(\@in_ns, ['NS::One'], 'find_in_namespace');

    for my $invalid (@invalid) {
        ok(!find_in_namespace($invalid), "'$invalid' is not a valid namespace");
    }
}

$path = catfile('lib', module_fs_path($module)) || '';
ok(-f $path, "'$path' exists");

# path_to_module should fail when given a module name
ok(!path_to_module($module), "path_to_module($module) fails");

# should fail on an absolute path too.
$path = find_installed($module) || '';
ok(!path_to_module($path), "path_to_module($path) fails");

__END__

vim: ft=perl ts=8 sts=4 sw=4 sr et
