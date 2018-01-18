%global pypi_name demo_app

Name:           python-%{pypi_name}
Version:        1.0
Release:        1%{?dist}
Summary:        Simple Flask Demo application
License:        Public Domain
Source0:        %{name}-%{version}.tar.gz
BuildArch:      noarch
 
BuildRequires:  python2-devel
BuildRequires:  python-setuptools
BuildRequires:  python-nose
BuildRequires:  python-flask
BuildRequires:  python2-hello_lib

#BuildRequires:  python-sphinx
 
#BuildRequires:  python%{python3_pkgversion}-devel
#BuildRequires:  python%{python3_pkgversion}-setuptools
#BuildRequires:  python%{python3_pkgversion}-nose
#BuildRequires:  python%{python3_pkgversion}-flask
#BuildRequires:  python%{python3_pkgversion}-hello_lib

%description
Simple Flask Demo application

%package -n     python2-%{pypi_name}
Summary:        %{summary}
Requires:       python-flask
Requires:       python2-hello_lib

%description -n python2-%{pypi_name}
Simple Flask Demo application

#%package -n     python%{python3_pkgversion}-%{pypi_name}
#Summary:        %{summary}
#Requires:       python%{python3_pkgversion}-flask
#Requires:       python%{python3_pkgversion}-hello_lib
#
#%description -n python%{python3_pkgversion}-%{pypi_name}
#Simple Flask Demo application

#%package -n python-%{pypi_name}-doc
#Summary:        %{pypi_name} documentation
#
#%description -n python-%{pypi_name}-doc
#Documentation for %{pypi_name}

%prep
%autosetup

%build
%{__python2} setup.py build
#%{__python3} setup.py build
# generate html docs 
#sphinx-build docs html
# remove the sphinx-build leftovers
#rm -rf html/.{doctrees,buildinfo}

%install
%{__python2} setup.py install --skip-build --root %{buildroot}
#%{__python3} setup.py install --skip-build --root %{buildroot}

%check
%{__python2} setup.py test
#%{__python3} setup.py test

%files -n python2-%{pypi_name}
#%doc 
%{python2_sitelib}/%{pypi_name}
%{python2_sitelib}/%{pypi_name}-%{version}-py?.?.egg-info

#%files -n python%{python3_pkgversion}-%{pypi_name}
#%doc 
#%{python3_sitelib}/%{pypi_name}
#%{python3_sitelib}/%{pypi_name}-%{version}-py?.?.egg-info

#%files -n python-%{pypi_name}-doc
#%doc html 

%changelog
* Tue Sep 06 2011 John Smith <jsmith@example.com>
- Initial version of the package

