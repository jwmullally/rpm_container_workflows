Name:           hello
Version:        1.0
Release:        1%{?dist}
Summary:        Simple Hello World application
License:        Public Domain
Source0:        hello.tar.gz

BuildRequires: gcc
BuildRequires: make

%description 
Example "Hello World" program.

%prep
%autosetup -n hello/src

%build
make

%install
make install DESTDIR=%{buildroot}

%check
make test

%files
/usr/bin/*

%changelog
* Tue Sep 06 2011 John Hancock <johnh@example.com>
- Initial version of the package
