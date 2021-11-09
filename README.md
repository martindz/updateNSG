# update Azure Network Security Group (NSG)

I came to situation I had to update NSG rules, however that rule is hard to manage, cause many people had access from all around the globe. And everyone as working from home need to have their IP address to access to resources
We had multiple environments in multiple resource group and it started to be annying if people ask to add their IP to each of them.
Script is adding IP addresses one be one to each of resource groups and NSG we have created for scpecific environment and isolated VNets

There is hard time to find it that you have to save your modification over other command after you modify the rules. It means you have to run Set-AzNetworkSecurityGroup after you modified the NSG rule with Set-AzNetworkSecurityRuleConfig.

In the script I'm searching for specific rule with name which contains *local* in the name and then I modify dynamicaly only SourceAddressPrefix, rest is hardcoded, but it's easily possible to just it. I'm reading the Priority value as well. Unfortunately Set-AzNetworkSecurityRuleConfig is updating through API and has to has all the values provided. Later on both mentioned commandlets have lenghty output so I decided to narrow it down to names of security groups and rules modified

After everything is written to Azure, script reads back if the IP addresses and rules were updated.

##Setting things
input list of IP addresses into variables and simiralrly names of resource groups you would like to update. Last part is Name patern of the rule you would like to modify

**newipaddress=@("xxx.xxx.xxx.xxx","yyy.yyy.yyy.yyy")**

**resourcegroups=@("resourgroupname2","resourgroupname1")**

**rulenamepatern="\*local\*"**

Script will  read the NSG/s in specific resouce group/s, find the approriate rule within the NSG and update it with IPaddresses already in the rule and add the other IP address to the end. If multiple IP addresses has to be added process will repeat. 

