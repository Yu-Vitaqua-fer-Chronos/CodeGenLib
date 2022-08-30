#!/usr/bin/env -S nim c --run scripts/autotagger

import strformat
import strutils
import sequtils
import json
import osproc

const GIT_URL = "github.com"
const USERNAME = "Mythical-Forest-Collective"
const PROJECT = "nim-commit-test"

const REPO = GIT_URL & "/" & USERNAME & "/" & PROJECT & ".git"

let REPO_URL = "https://" & REPO

proc semver(versionString: string): seq[int] = split(versionString, '.', 3).map(parseInt)

discard execCmdEx("rm -rf .cache")


discard execCmdEx(fmt"git clone {REPO_URL} .cache/head") # Clone the head
var prevCommit = execCmdEx("git rev-parse HEAD^",
    workingDir = ".cache/head").output.replace("\n", "") # Get previous commit hash


discard execCmdEx(fmt"git clone -n {REPO_URL} .cache/prevCommit") # Clone new repo so we can change to prev commit

discard execCmdEx(fmt"git checkout {prevCommit}",
    workingDir = ".cache/prevCommit")


var currPkgVerStr = execCmdEx("nimble dump --json",
    workingDir = ".cache/head").output.parseJson()["version"].getStr
var prevPkgVerStr = execCmdEx("nimble dump --json",
    workingdir = ".cache/prevCommit").output.parseJson()["version"].getStr


var currPkgVer = currPkgVerStr.semver
var prevPkgVer = prevPkgVerStr.semver


echo currPkgVer, ", ", prevPkgVer


if currPkgVerStr == prevPkgVerStr:
  if currPkgVer[0] <= prevPkgVer[0]:
    if currPkgVer[1] <= prevPkgVer[1]:
      if currPkgVer[2] <= prevPkgVer[2]:
        quit("No new version! Not creating a tag for the last version!", 0)


discard execCmdEx(fmt "GIT_COMMITTER_DATE=\"$(git show --format=%aD | head -1)\" git tag -a v{prevPkgVerStr} {prevCommit} -am \"Release v{prevPkgVerStr} as commit hash \\`{prevCommit}\\`\"",
    workingDir = ".cache/head").output

discard execCmdEx(fmt"git push origin v{prevPkgVerStr}",
    workingDir = ".cache/head").output

discard execCmdEx("rm -rf .cache")

quit("Created tag for last version!", 0)