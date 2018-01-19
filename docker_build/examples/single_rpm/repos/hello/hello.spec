Name:           hello
Version:        1.0
Release:        1%{?dist}
Summary:        Example Hello World CGI application
License:        Public Domain
URL:            https://git.example.org/hello
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  gcc
BuildRequires:  make

Requires:       python

%description 
Example Hello World CGI application.

%prep
%autosetup

%build
cd src
make

%install
cd src
make install DESTDIR=%{buildroot}

%check
cd src
make test

%files
/usr/bin/*
/var/www/*

%changelog
* Tue Sep 06 2011 John Hancock <johnh@example.com>
- Initial version of the package
