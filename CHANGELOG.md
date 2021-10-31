# git-open

## 0.3.1

- Funny bug in TrimEnd(). If a repository name ends with "g", "i", or "t" then that letter gets trimmed with the cleaning up of ".git" from the remote URL. https://github.com/PowerShell/PowerShell/issues/6174

## 0.3.0

-- Will now work when invoked from a folder inside of a repo by finding the git config uproot. 
-- Adding the gitopen alias

## 0.2.0

-- Added support for Azure Devops. 
-- Added new properties to custom repo configurations to make this work for even more source control systems. 


## 0.1.0

-- First version published to Powershell Gallery

## 0.0.1

-- Initial Release