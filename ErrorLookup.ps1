# Path where exe file should get downloaded to.
$Path = "C:\temp\Err.exe"

# Download Urls for Error Lookup Tool
# https://docs.microsoft.com/en-us/windows/win32/debug/system-error-code-lookup-tool
$Url = "https://download.microsoft.com/download/4/3/2/432140e8-fb6c-4145-8192-25242838c542/Err_6.4.5/Err_6.4.5.exe"

Function Test-URI {
	<#
			.Synopsis
			Test a URI or URL
			.Description
			This command will test the validity of a given URL or URI that begins with either http or https. The default behavior is to write a Boolean value to the pipeline. But you can also ask for more detail.
 
			Be aware that a URI may return a value of True because the server responded correctly. For example this will appear that the URI is valid.
 
			test-uri -uri http://files.snapfiles.com/localdl936/CrystalDiskInfo7_2_0.zip
 
			But if you look at the test in detail:
 
			ResponseUri   : http://files.snapfiles.com/localdl936/CrystalDiskInfo7_2_0.zip
			ContentLength : 23070
			ContentType   : text/html
			LastModified  : 1/19/2015 11:34:44 AM
			Status        : 200
 
			You'll see that the content type is Text and most likely a 404 page. By comparison, this is the desired result from the correct URI:
 
			PS C:\> test-uri -detail -uri http://files.snapfiles.com/localdl936/CrystalDiskInfo6_3_0.zip
 
			ResponseUri   : http://files.snapfiles.com/localdl936/CrystalDiskInfo6_3_0.zip
			ContentLength : 2863977
			ContentType   : application/x-zip-compressed
			LastModified  : 12/31/2014 1:48:34 PM
			Status        : 200
 
			.Example
			PS C:\> test-uri https://www.petri.com
			True
			.Example
			PS C:\> test-uri https://www.petri.com -detail
 
			ResponseUri   : https://www.petri.com/
			ContentLength : -1
			ContentType   : text/html; charset=UTF-8
			LastModified  : 1/19/2015 12:14:57 PM
			Status        : 200
			.Example
			PS C:\> get-content D:\temp\uris.txt | test-uri -Detail | where { $_.status -ne 200 -OR $_.contentType -notmatch "application"}
 
			ResponseUri   : http://files.snapfiles.com/localdl936/CrystalDiskInfo7_2_0.zip
			ContentLength : 23070
			ContentType   : text/html
			LastModified  : 1/19/2015 11:34:44 AM
			Status        : 200
 
			ResponseURI   : http://download.bleepingcomputer.com/grinler/rkill
			ContentLength : 
			ContentType   : 
			LastModified  : 
			Status        : 404
 
			Test a list of URIs and filter for those that are not OK or where the type is not an application.
			.Notes
			Last Updated: January 19, 2015
			Version     : 1.0
 
			Learn more about PowerShell:
			http://jdhitsolutions.com/blog/essential-powershell-resources/
 
			****************************************************************
			* DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
			* THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
			* YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
			* DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
			****************************************************************
 
			.Link
			Invoke-WebRequest
	#>
 
	[cmdletbinding(DefaultParameterSetName="Default")]
	Param(
		[Parameter(Position=0,Mandatory,HelpMessage="Enter the URI path starting with HTTP or HTTPS",
		ValueFromPipeline,ValueFromPipelineByPropertyName)]
		[ValidatePattern( "^(http|https)://" )]
		[Alias("url")]
		[string]$URI,
		[Parameter(ParameterSetName="Detail")]
		[Switch]$Detail,
		[ValidateScript({$_ -ge 0})]
		[int]$Timeout = 30
	)
 
	Begin {
		Write-Verbose -Message "Starting $($MyInvocation.Mycommand)" 
		Write-Verbose -message "Using parameter set $($PSCmdlet.ParameterSetName)" 
	} #close begin block
 
	Process {
 
		Write-Verbose -Message "Testing $uri"
		Try {
			#hash table of parameter values for Invoke-Webrequest
			$paramHash = @{
				UseBasicParsing = $True
				DisableKeepAlive = $True
				Uri = $uri
				Method = 'Head'
				ErrorAction = 'stop'
				TimeoutSec = $Timeout
			}
 
			$test = Invoke-WebRequest @paramHash
 
			if ($Detail) {
				$test.BaseResponse | 
				Select ResponseURI,ContentLength,ContentType,LastModified,
				@{Name="Status";Expression={$Test.StatusCode}}
			} #if $detail
			else {
				if ($test.statuscode -ne 200) {
						#it is unlikely this code will ever run but just in case
						Write-Verbose -Message "Failed to request $uri"
						write-Verbose -message ($test | out-string)
						$False
				 }
				 else {
						$True
				 }
			} #else quiet
     
		}
		Catch {
			#there was an exception getting the URI
			write-verbose -message $_.exception
			if ($Detail) {
				#most likely the resource is 404
				$objProp = [ordered]@{
					ResponseURI = $uri
					ContentLength = $null
					ContentType = $null
					LastModified = $null
					Status = 404
				}
				#write a matching custom object to the pipeline
				New-Object -TypeName psobject -Property $objProp
 
				} #if $detail
			else {
				$False
			}
		} #close Catch block
	} #close Process block
 
	End {
		Write-Verbose -Message "Ending $($MyInvocation.Mycommand)"
	} #close end block
 
}
function DownloadFile {
		param (
				[Parameter(Mandatory=$true,Position=0)] $url,
				[Parameter(Mandatory=$true,Position=1)] $file
		)

		$webclient = New-Object System.Net.WebClient
		$webclient.DownloadFile($url, $file)
} 

$WebContentexe=Test-URI $Url -Detail
$FileContentexe = Get-ItemProperty $Path -ErrorAction SilentlyContinue

if ($WebContentexe.ContentLength -ne $FileContentexe.Length){
	DownloadFile -url $Url -file $Path
	}

[xml]$XAML  = @'
<Window  xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
  xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
  xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
  xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
  xmlns:local="clr-namespace:MyFirstWPF"
  Title="PowerShell Error Code Lookup" Height="450"  Width="625">
  <Grid>
  <GroupBox  x:Name="Actions" Header="Actions"  HorizontalAlignment="Left" Height="399"  VerticalAlignment="Top" Width="90"  Margin="0,11,0,0">
  <StackPanel>
  <Button  x:Name="getError" Content="Error Lookup"/>
  <Label  />
  </StackPanel>
  </GroupBox>
  <GroupBox  x:Name="ErrorCode" Header="Enter Error Code"  HorizontalAlignment="Left" Margin="92,11,0,0" VerticalAlignment="Top"  Height="45" Width="515">
  <TextBox  x:Name="InputBox_txtbx" TextWrapping="Wrap"/>            
  </GroupBox>
  <GroupBox  x:Name="Results" Header="Results"  HorizontalAlignment="Left" Margin="92,61,0,0"  VerticalAlignment="Top" Height="348"  Width="515">
  <TextBox  x:Name="Output_txtbx" IsReadOnly="True"  HorizontalScrollBarVisibility="Auto"  VerticalScrollBarVisibility="Auto" />
  </GroupBox>
    </Grid>
  </Window>
'@ 

[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
$reader=(New-Object System.Xml.XmlNodeReader  $xaml)
$Window=[Windows.Markup.XamlReader]::Load(  $reader )

#Connect to Controls 

$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach {
	New-Variable  -Name $_.Name -Value $Window.FindName($_.Name) -Force
}


#region Events 

	$getError.Add_Click({

		If (-NOT ([string]::IsNullOrEmpty($InputBox_txtbx.Text)))  {

			$ErrorCode  = $InputBox_txtbx.Text
		}
		Try  {
			$ErrorCodeLookup  = & $Path $ErrorCode -argument 2>$null

			$Output_txtbx.Text = ($ErrorCodeLookup |  Out-String)

		}

		Catch  {

			Write-Warning  $_

		}
	})
	#endregion Events 


$out = $Window.ShowDialog()