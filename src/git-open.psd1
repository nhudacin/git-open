@{

    # Script module or binary module file associated with this manifest.
    RootModule = 'git-open.psm1'
    
    # Version number of this module.
    ModuleVersion = '0.0.1'
    
    # ID used to uniquely identify this module
    GUID = 'd90bd9b8-8e30-4931-8297-da0cb1a3fffc'
    
    # Author of this module
    Author = 'Nick Hudacin and contributors'
    
    # Copyright statement for this module
    Copyright = '(c) 2010-2019 Nick Hudacin and contributors'
    
    # Description of the functionality provided by this module
    Description = 'Provides a quick way to open the remote URL in a web browser.'
    
    # Minimum version of the Windows PowerShell engine required by this module
    PowerShellVersion = '5.0'
    
    # Functions to export from this module
    FunctionsToExport = @(
        'Invoke-GitOpen'
    )
    
    # Cmdlets to export from this module
    CmdletsToExport = @()
    
    # Variables to export from this module
    VariablesToExport = @()
    
    # Aliases to export from this module
    AliasesToExport = @()   
   
}