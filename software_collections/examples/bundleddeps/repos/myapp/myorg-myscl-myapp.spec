%define scl_vendor myorg
%define scl_name_base myscl
%define scl %{scl_vendor}-%{scl_name_base}
%define _scl_prefix /opt/%{scl_vendor}
%define nfsmountable 1

%scl_package    myapp

Name:           %{scl_prefix}%{pkg_name}
Version:        0.1
Release:        1%{?dist}
Summary:        Python virtualenv for %{name}
License:        Public Domain
Source0:        %{pkg_name}.tar.gz
Source1:        dependencies.tar

BuildRequires:  rh-python36
BuildRequires:  rh-python36-python-virtualenv
BuildRequires:  postgresql-devel
BuildRequires:  /usr/bin/gcc
BuildRequires:  /usr/bin/make
Requires:       %scl_runtime
Requires:       rh-python36
Requires:       postgresql-libs

AutoReqProv: no
%define debug_package %{nil}
%define __spec_install_post %{nil}
%define _build_id_links none
%define python3_version 3.6


%description
Python virtualenv for %{name}


%prep
%setup -n %{pkg_name}
tar -xf %{SOURCE1}
scl enable rh-python36 "make venv"


%build
make build


%install
make install BUILDROOT=%{buildroot} DESTDIR=%{_scl_root}


%check
make test


%files
%defattr(-,root,root,-)
%{_scl_root}/bin/*
%{_scl_root}/include/*
%{_scl_root}/lib/*
%{_scl_root}/lib64/*
%{_scl_root}/man/*/*

%changelog
