notes about dockerfile non-root builds

By default, build will fail if install scripts present in RPM

%post
echo "Infecting filesystem..."
touch /evilfile
