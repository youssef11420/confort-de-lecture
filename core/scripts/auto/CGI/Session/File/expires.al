# NOTE: Derived from blib\lib\CGI\Session.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package CGI::Session;

#line 1153 "blib\lib\CGI\Session.pm (autosplit into blib\lib\auto\CGI\Session\expires.al)"
# expires() - alias to expire(). For backward compatibility
sub expires {
	return expire(@_);
}

# end of CGI::Session::expires
1;
