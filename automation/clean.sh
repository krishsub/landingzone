#!/bin/bash

SPOKE1_RG="001-Spoke-Resources"
SPOKE2_RG="002-Spoke-Resources"
SPOKE3_RG="003-Spoke-Resources"

HUB_RG="Hub-Resources"

az group delete --name $SPOKE1_RG --yes --no-wait
az group delete --name $SPOKE2_RG --yes --no-wait
az group delete --name $SPOKE3_RG --yes --no-wait
az group delete --name $HUB_RG --yes --no-wait