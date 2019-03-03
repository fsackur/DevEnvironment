<#
    When you are roughing out a C# type in powershell, and you don't want to fire up
    Visual Studio, it can get tiresome having to constantly reload your script editor.

    This increments the class name each time you compile it.

    Blogged in https://fsackur.github.io/2018/03/30/Reflecting-on-types/
#>
$TypeDef = @'
using System;
using System.Management.Automation;
using System.Collections;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using System.Runtime.Serialization;


    public class DeviceId
    {
        private static Regex regex = new Regex (@"^\d{4,7}$");

        private string Id;

        private DeviceId () {}

        public DeviceId (string Id) 
        {
            if (!regex.Match(Id).Success)
            {
                throw new ArgumentException (String.Format("Invalid device id: {0}", Id));
            }
            this.Id = Id;
        }

        public override bool Equals (object obj) 
        {
            return Id.Equals(obj.ToString());
        }

        public override int GetHashCode() 
        {
            return Id.GetHashCode();
        }

        [OnSerializing]
        public override string ToString() 
        {
            return Id;
        }
    }

'@



if (-not $i) {$Global:i = 1} else {$i++}

if ($TypeDef -match 'class\s+(\w+)\b')
{
    $ClassName = $Matches.1
}
else 
{
    throw "Couldn't parse class name from source code"
}

$TypeDef = $TypeDef -replace ([Regex]::Escape($ClassName) + '\b'), "$ClassName$i"
$ClassName += $i

$TypesToReference = @(
    #Add any types here from non-default assemblies
    [System.Runtime.Serialization.DataMemberAttribute]
)
$AssembliesToReference = $TypesToReference.Assembly

$Types = Add-Type -TypeDefinition $TypeDef -PassThru -ErrorAction Continue -ReferencedAssemblies $AssembliesToReference

$Type = $Types | ? Name -eq $ClassName

(1234 -as $Type) | ConvertTo-Json