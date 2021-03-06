# fourthcoffee.pp
# example DSC configuration

class dsc_collection::fourthcoffee (
  $websitename = 'FourthCoffee',
  $zipname = 'FourthCoffeeWebSiteContent.zip',
  $sourcerepo = 'http://github.com/msutter/fourthcoffee/raw/master',
  $destinationpath = 'C:\inetpub\FourthCoffee',
  $defaultwebsitepath = 'C:\inetpub\wwwroot',
  $zippath = 'C:\tmp'
  ){
    $zipuri = "${sourcerepo}/${zipname}"
    $zipfile = "${zippath}\\${zipname}"

    reboot { 'before':
      when => pending,
    }
    # Install the IIS role
    dsc_windowsfeature { 'IIS':
      dsc_ensure => 'present',
      dsc_name   => 'Web-Server'
    } ->

    # Install the ASP .NET 4.5 role
    dsc_windowsfeature { 'AspNet45':
      dsc_ensure => 'present',
      dsc_name   => 'Web-Asp-Net45',
    } ->

    # Install IIS Web Management Console
    dsc_windowsfeature { 'IIS Management Console':
      dsc_ensure => 'present',
      dsc_name   => 'Web-Mgmt-Console',
    } ->

    # Stop an existing website (default)
    dsc_xwebsite { 'Stop DefaultSite':
        dsc_ensure       => 'present',
        dsc_name         => 'Default Web Site',
        dsc_state        => 'Stopped',
        dsc_physicalpath => $defaultwebsitepath,
    } ->

    # Create tmp folder
    dsc_file { 'tmp folder':
      dsc_ensure          => 'present',
      dsc_type            => 'Directory',
      dsc_destinationpath => $zippath,
    } ->

    # Download the site content
    dsc_xremotefile {'Download WebContent Zip':
      dsc_destinationpath => $zipfile,
      dsc_uri             => $zipuri,
    } ->

    # Extract the website content
    dsc_archive {'Unzip and Copy the WebContent':
      dsc_ensure      => 'present',
      dsc_path        => $zipfile,
      dsc_destination => $destinationpath,
    } ->

    # Create a new Website
    dsc_xwebsite { 'BackeryWebSite':
      dsc_ensure       => 'present',
      dsc_name         => $websitename,
      dsc_state        => 'Started',
      dsc_physicalpath => $destinationpath,
    }
}
