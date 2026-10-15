# Linked into every uv-managed interpreter's stdlib dir by install/mise.sh,
# so it runs at startup of that interpreter and of every venv built from it.
#
# Netskope's root CA (caadmin.netskope.com) has a non-critical Basic Constraints
# and no Key Usage, which OpenSSL rejects under X509_STRICT. Python 3.13+ sets
# that flag by default (ssl.create_default_context, urllib3), so drop just that
# flag; chain and hostname verification stay intact.
import ssl

_verify_flags = ssl.SSLContext.verify_flags
ssl.SSLContext.verify_flags = property(
    _verify_flags.fget,
    lambda self, value: _verify_flags.fset(self, value & ~ssl.VERIFY_X509_STRICT),
)
