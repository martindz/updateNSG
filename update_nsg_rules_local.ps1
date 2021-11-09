#modify list of ip addresses you would like to add to NSG
#example $newipaddress =@("xxx.xxx.xxx.xxx","xxx.xxx.xxx.xxx","zzz.zzz.zzz.zzz")
$newipaddress =@("zzz.zzz.zzz.zzz")
#make decision to which environment you would need access
$resourcegroups=@("dev00-noprod-rg","dev01-noprod-rg","qa01-noprod-rg")

foreach( $ip in $newipaddress) {
    foreach ($rg in $resourcegroups) {
    #seelct list of NSGs
    $nsg= Get-AzNetworkSecurityGroup -ResourceGroupName $rg
    #check if mentioned NSG exists
    #$nsg.securityrules.name | where {$_ -like "*local*"}
    #pick appropriate config
    $ruleconfig= $nsg | Get-AzNetworkSecurityRuleConfig | Where-Object {$_.name -like "*local*"}
    #count amount of find
    Write-Host -NoNewLine 'Amount of rules within the NSGs in resource groups: '
    ($ruleconfig| Measure-Object).Count
    foreach ($rulec in $ruleconfig) {
        Write-Host -NoNewLine 'name of nsg rule to modify: '
        $rulec.name;
        $newlistofips = $ruleconfig.SourceAddressPrefix+$ip
        $newlistofips2 = $newlistofips | Select-Object -unique
        Write-Host -NoNewLine 'Name of modified rules in NSG: '
        (Set-AzNetworkSecurityRuleConfig -name $rulec.name `
                                        -NetworkSecurityGroup $($nsg | Where-Object {$_.name -eq $rulec[0].id.split("/",10)[8]}) `
                                        -SourceAddressPrefix $newlistofips2 `
                                        -Protocol * `
                                        -Access Allow `
                                        -Direction Inbound `
                                        -SourcePortRange * `
                                        -DestinationAddressPrefix * `
                                        -DestinationPortRange * `
                                        -Priority $rulec.Priority).Name
    }
    Write-Host -NoNewLine 'Name of modified NSGs to save: '
    (($nsg | Where-Object {$_.name -eq $rulec[0].id.split("/",10)[8]})| Set-AzNetworkSecurityGroup).Name
    # Write-Host -NoNewLine 'Press any key to continue...';
    # $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown');
    Write-Host 'Check for existance of the ip in the NSGs';
    Write-Host "Resource group $rg";
    $nsg= Get-AzNetworkSecurityGroup -ResourceGroupName $rg;
    Write-Host -NoNewLine 'NSG rule name: ';
    $nsg.securityrules.name | Where-Object {$_ -like "*local*"};
    Write-Host 'SHow IP address after change in NSG, if empty throw error';
    if ($null -eq $ruleconfig.SourceAddressPrefix | Where-Object {$_ -eq $ip}) 
        {Write-error "IP not found in NSG"}
        else 
           {
            Write-Host -NoNewLine 'Amount of NSGs name: ';
            ($ruleconfig| Measure-Object).Count
            Write-Host 'Name and list of the IP ';   
            $ruleconfig | Where-Object {$_.SourceAddressPrefix -eq $ip} |Select-Object Name, @{l="added_IP";e={$_.SourceAddressPrefix -eq $ip}} | Format-Table
            }
    }
}
