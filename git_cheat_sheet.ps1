
#My git cheat sheet - git is hard for a bear of little brain

$GithubFSackur = 'https://github.com/fsackur'
$RepoName = Read-Host "What is the name of the repo"
$BranchName = Read-Host "What is the name of the branch"

#Set-Location $GitDev

git clone "$GithubFSackur/$RepoName"     #this also pulls
Set-Location $RepoName


#Add the Windows-Automation master fork as the 'upstream' remote ('upstream' is a convention, not a keyword)
git remote add upstream "$GithubWA/$RepoName.git"


#Checkout a branch
git checkout -b $BranchName
#git push origin $BranchName
git push --set-upstream origin $BranchName   #needed if you created the branch locally



git add *
git status -v
git commit -m ""
git push




#Rolling back to a previous commit
#git log           #enter 'q' to quit if you are using the default pager, which is 'less'. To fix this annoying crap, if you're in Powershell:
#git config --global --replace-all core.pager "Get-Content"
git config --global --replace-all core.pager "Get-Content | Out-Host -Paging"
git log
#git reset --hard 0d1d7fc32e5a947fbd92ee598033d85bfc445a50      #If you haven't published the commits, this will discard stuff from your tracked files back to commit 0d1d7fc32e5a947fbd92ee598033d85bfc445a50, so won't be included in next commit. The files will still be there.
#git clean -f      #discards untracked files



#Log onto your fork and submit a PR.
#Search term for open PRs in github web UI:            is:open is:pr author:mich8638
