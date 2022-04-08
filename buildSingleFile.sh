#!/bin/bash
sol-merger --export-plugin SPDXLicenseRemovePlugin contracts/StoneRouter.sol singlefile
sol-merger --export-plugin SPDXLicenseRemovePlugin contracts/Stone.sol singlefile
sol-merger --export-plugin SPDXLicenseRemovePlugin contracts/StoneFactory.sol singlefile
sol-merger --export-plugin SPDXLicenseRemovePlugin contracts/TokenUriConstructor.sol singlefile
