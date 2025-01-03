<#
.SYNOPSIS
    Generates or updates Jekyll blog post drafts from a schedule file.

.DESCRIPTION
    This script processes a pipe-delimited schedule file (post-schedule.psv) to create or update Jekyll blog post drafts.
    For new posts, it creates markdown files with frontmatter and placeholder content.
    For existing posts, it updates only the frontmatter while preserving the existing content.
    
    The script handles:
    - Slug generation from post titles
    - Frontmatter generation with title, date, categories, and tags
    - Content preservation during updates
    - Debug output for troubleshooting

.PARAMETER None
    This script does not accept parameters.

.EXAMPLE
    PS> .\generate-post-schedule.ps1
    Processes post-schedule.psv in the current directory and generates/updates posts in _drafts folder.

.EXAMPLE
    PS> .\generate-post-schedule.ps1
    Found 'post-schedule.psv'. Starting to process posts...
    Created new file: _drafts/2024-06-04-building-a-proxmox-based-cybersecurity-lab.md
    Completed processing post-schedule.psv: 1 new posts, 0 updated

.NOTES
    File Name      : generate-post-schedule.ps1
    Requirements   : PowerShell 5.1 or later
    Input File     : post-schedule.psv (pipe-delimited: Date|Title|Categories|Tags)
    Output         : Markdown files in _drafts folder
    Author        : robertsinfosec (with GitHub CoPilot, mostly Claude 3.5 Sonnet)
    Version       : 1.0

.LINK
    https://github.com/yourusername/yourrepo
#>

$postScheduleFile = "post-schedule.psv"
$draftsFolder = "_drafts"

function Format-Array {
    <#
    .SYNOPSIS
        Formats a comma-separated string into a clean, consistently-formatted array string.
    
    .DESCRIPTION
        Takes a string of comma-separated values and normalizes it by:
        - Removing extra whitespace before and after each value
        - Removing empty entries
        - Adding consistent comma+space separation
        Used for cleaning up category and tag lists in Jekyll frontmatter.
    
    .PARAMETER items
        A string containing comma-separated values that may have inconsistent spacing.
    
    .EXAMPLE
        PS> Format-Array "item1,item2, item3,   item4  "
        Returns: "item1, item2, item3, item4"
    
    .EXAMPLE
        PS> Format-Array "category1,  category2,category3"
        Returns: "category1, category2, category3"
    
    .OUTPUTS
        System.String. A cleaned string with items separated by ", "
    #>
    param(
        [Parameter(Mandatory=$true,
                   Position=0,
                   HelpMessage="Comma-separated string to format")]
        [string]$items
    )
    return ($items -split ',' | ForEach-Object { $_.Trim() } | Where-Object { $_ }) -join ', '
}

function Get-Slug {
    <#
    .SYNOPSIS
        Converts a title string into a URL-friendly slug.
    
    .DESCRIPTION
        Transforms a string into a lowercase, hyphenated slug suitable for URLs and filenames.
        Removes special characters, converts spaces to hyphens, and ensures clean formatting.
    
    .PARAMETER Title
        The string to convert into a slug.
    
    .EXAMPLE
        PS> Get-Slug "Hello World! This is a Test"
        Returns: "hello-world-this-is-a-test"
    #>
    param(
        [Parameter(Mandatory=$true,
                   Position=0,
                   ValueFromPipeline=$true,
                   HelpMessage="Title to convert to slug")]
        [string]$Title
    )
    Write-Host "Debug - Original title: $Title" -ForegroundColor DarkGray
    
    # Convert to lowercase and remove special characters
    $slug = $Title.ToLower()
    Write-Host "Debug - After lowercase: $slug" -ForegroundColor DarkGray
    
    # Replace special chars and spaces with dashes
    $slug = $slug -replace '[^a-z0-9\s-]', ''
    $slug = $slug -replace '\s+', '-'
    $slug = $slug -replace '-+', '-'
    $slug = $slug.Trim('-')
    
    Write-Host "Debug - Final slug: $slug" -ForegroundColor DarkGray
    return $slug
}

Write-Host "Found '$postScheduleFile'. Starting to process posts..." -ForegroundColor Cyan

$lineCount = 0
$newCount = 0
$updateCount = 0

# Create drafts folder if it doesn't exist
if (!(Test-Path $draftsFolder)) {
    New-Item -ItemType Directory -Path $draftsFolder | Out-Null
}

Get-Content $postScheduleFile | ForEach-Object {
    # Skip empty lines and comment lines
    if ([string]::IsNullOrWhiteSpace($_) -or $_ -match '^\s*#') {
        return
    }

    if ($_ -match '\|') {
        $lineCount++
        
        $parts = $_ -split '\|', 4
        $postDate = $parts[0].Trim()
        $postTitle = $parts[1].Trim()
        $postCategories = Format-Array $parts[2]
        $postTags = Format-Array $parts[3]
        
        if ([string]::IsNullOrWhiteSpace($postDate) -or [string]::IsNullOrWhiteSpace($postTitle)) {
            Write-Host "Skipping empty or invalid line." -ForegroundColor Yellow
            return
        }
        
        Write-Host "Processing line $lineCount`: $postDate | $postTitle" -ForegroundColor Cyan
        
        $slug = Get-Slug -Title $postTitle
        $fileName = Join-Path $draftsFolder "$postDate-$slug.md"
        
        $frontMatter = @"
---
title: "$postTitle"
date: $postDate 12:00:00 -500
categories: [$postCategories]
tags: [$postTags]
published: true
---

"@
        
        if (Test-Path $fileName) {
            Write-Host "File exists: $fileName - Only updating frontmatter" -ForegroundColor Yellow
            
            # Get existing content after frontmatter
            $content = Get-Content $fileName -Raw
            if ($content -match '(?ms)---.*?---\r?\n(.*)') {
                $existingContent = $matches[1].TrimStart()
                $newContent = $frontMatter + $existingContent
            } else {
                $newContent = $frontMatter + "TBD`n"
            }
            
            $newContent | Set-Content $fileName -NoNewline
            $updateCount++
            Write-Host "Updated frontmatter in: $fileName" -ForegroundColor Green
            Write-Host "Debug - Updated $updateCount files so far" -ForegroundColor DarkGray
        } else {
            # Create new file
            $newContent = $frontMatter + "TBD`n"
            $newContent | Set-Content $fileName -NoNewline
            $newCount++
            Write-Host "Created new file: $fileName" -ForegroundColor Green
            Write-Host "Debug - Created $newCount new files so far" -ForegroundColor DarkGray
        }
    }
}

Write-Host "Completed processing $postScheduleFile`: $newCount new posts, $updateCount updated" -ForegroundColor Green