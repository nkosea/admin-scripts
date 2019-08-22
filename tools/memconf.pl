#!/usr/bin/env perl
#
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# MODIFY THE LOCATION TO THE FULL PATH TO PERL ABOVE IF NECESSARY
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# @(#) memconf - Identify sizes of memory modules installed on a
# @(#)           Solaris, Linux, FreeBSD or HP-UX workstation or server.
# @(#)           Tom Schmidt 16-Jul-2019 V3.15
#
# Maintained by Tom Schmidt (tom@4schmidts.com)
#
#   Check http://sourceforge.net/projects/memconf/ or my website at
#   http://www.4schmidts.com/unix.html to get the latest version of memconf.
#
#   If memconf does not recognize a system, then please run 'memconf -D' to
#   have it automatically E-mail me the information I need to enhanced to
#   recognize it. If the unrecognized system is a Sun clone, please also send
#   any hardware documentation on the memory layout that you may have.
#
# Usage: memconf [ -v | -D | -h ] [explorer_dir]
#                  -v            verbose mode
#                  -D            E-mail results to memconf maintainer
#                  -h            print help
#                  explorer_dir  Sun/Oracle Explorer output directory
#
# memconf reports the size of each SIMM/DIMM memory module installed in a
# system. It also reports the system type and any empty memory sockets.
# In verbose mode, it also reports the following information if available:
#  - banner name, model and CPU/system frequencies
#  - address range and bank numbers for each module
#
# memconf is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation; either version 2 of the License, or (at your option)
# any later version.
#
# Original version based on SunManagers SUMMARY by Howard Modell
# (h.modell@ieee.org) on 29-Jan-1997.
#
# Tested to work on 32-bit and 64-bit kernels on:
# - Solaris 10 6/06 or later on x86 with /usr/platform/i86pc/sbin/prtdiag
# - Linux on SPARC with sparc-utils and /dev/openprom
# - Linux on x86 and x86_64 with kernel-utils or pmtools for dmidecode
# - FreeBSD on x86 and x86_64 with dmidecode
# - Most HP-UX systems with SysMgmtPlus (cprop) or Support Tools Manager (cstm)
# - Solaris (SunOS 4.X or 5.X) on the following SPARC systems
#   - sun4c Sun SS1, SS2, IPC, IPX, ELC with Open Boot PROM V2.X
#   - sun4m Sun 4/6x0, SS4, SS5, SS10, SS20, LX/ZX, Classic, Voyager, JavaEngine1
#   - sun4d Sun SPARCserver-1000, 1000E, SPARCcenter-2000, 2000E
#   - sun4u Sun Ultra 1, 2, 5, 10, 30, 60, 450
#   - sun4u Sun Ultra 80, Ultra Enterprise 420R, and Netra t1400/1405.
#   - sun4u Sun Ultra Enterprise 220R, 250, 450
#   - sun4u Sun Ultra Enterprise 3000, 3500, 4000/5000, 4500/5500, 6000, 6500
#   - sun4u1 Sun Ultra Enterprise 10000
#   - sun4u Sun StorEdge N8400 and N8600 Filer
#   - sun4u Sun SPARCengine Ultra AX, AXi, AXmp, AXmp+, AXe
#   - sun4u Sun SPARCengine CP 1400, CP 1500, CP2140
#   - sun4u Sun Netra t1 100/105, t1120/1125, ft1800, X1, T1 200, AX1105-500, 120
#   - sun4u Sun Netra 20 (Netra T4)
#   - sun4u Sun Netra ct800
#   - sun4u Sun Blade 100, 150, 1000, 1500, 2000, 2500
#   - sun4u Sun Fire 280R
#   - sun4u Sun Fire 3800, 4800, 4810, 6800
#   - sun4u Sun Fire V100, V120, V210, V240, V250, V440
#   - sun4u Sun Netra 210, 240, 440
#   - sun4u Sun Fire V125, V215, V245, V445
#   - sun4u Sun Fire V480, V490, V880, V880z, V890
#   - sun4u Sun Fire 12000, 15000, E20K, E25K
#   - sun4u Sun Fire V1280, Netra 1280 (Netra T12)
#   - sun4u Sun Fire E2900, E4900, E6900
#   - sun4u Sun Fire B100s Blade Server
#   - sun4u Sun Ultra 25 Workstation
#   - sun4u Sun Ultra 45 Workstation
#   - sun4u Sun/Fujitsu Siemens SPARC Enterprise M3000, M4000, M5000, M8000,
#     and M9000 Server
#   - sun4v Sun Fire T2000, T1000, Netra T2000
#   - sun4v Sun Blade T6300, T6320, T6340
#   - sun4v Sun SPARC Enterprise T2000, T1000 Server
#   - sun4v Sun SPARC Enterprise T5120, T5140, T5220, T5240 Server, Netra T5220
#   - sun4v Sun SPARC Enterprise T5440 Server, Netra T5440
#   - sun4v Oracle SPARC T3-1, T3-1B, T3-2, T4-1, T4-2, T4-4, T5-2, T5-4, T7-4, T8-2
#   - sun4v Oracle SPARC S7-2, S7-2L
#   - sun4v Fujitsu SPARC M10-1, M10-4
#   - sun4m Tatung COMPstation 5, 10, 20AL, 20S and 20SL clones
#   - sun4m transtec SPARCstation 20I clone
#   - sun4m Rave Axil-255 SPARCstation 5 clone
#   - sun4m Rave Axil-245, 311 and 320 clones (no verbose output)
#   - sun4u AXUS Ultra 250
#   - sun4u Tatung COMPstation U2, U60 and U80D clones
#   - Force Computers SPARC clones (no verbose output)
#   - Tadpole SPARCbook 3 and RDI PowerLite-170 (no verbose output)
#   - Tadpole VoyagerIIi
#   - Tadpole (Cycle) 3200 CycleQUAD Ultra 2 upgrade motherboard
#   - Tadpole (Cycle) UP-520-IIi SPARCstation 5/20 upgrade motherboard
#   - Tadpole SPARCle
#   - Auspex 7000/650 (no verbose output)
#   - Fujitsu S-4/10H, S-4/20L and S-4/20H clones (no verbose output)
#   - Fujitsu GP7000, GP7000F
#   - Fujitsu Siemens PrimePower 200, 400, 600, 800, 1000, 2000
#   - Fujitsu Siemens PrimePower 250, 450, 650, 850
#   - Fujitsu Siemens PrimePower 900, 1500, 2500, HPC2500
#   - Twinhead TWINstation 5G, 20G
#   - Detects VSIMMs for SX graphics on SS10SX/SS20 (1st VSIMM only)
#   - Detects Prestoserve NVSIMMs on SS10/SS20/SS1000/SC2000
#
# Untested systems that should work:
# - sun4c Sun SS1+ with Open Boot PROM V2.X
# - sun4m Tatung COMPstation 20A clone
# - sun4u Sun Netra ct400, ct410, ct810
# - sun4u Sun SPARCengine CP2040, CP2060, CP2080, CP2160
# - sun4v Sun Netra CP3260
# - sun4v Oracle SPARC T3-1BA, T3-4, T4-1B, T4-2B, T5-8, T5-1B, T7-1, T7-2
# - sun4v Oracle SPARC M5-32, M6-32, M7-8, M7-16
# - sun4v Oracle Netra SPARC T3 systems
# - sun4v Fujitsu SPARC M10-4S
# - May not work properly on Sun clones
#
# Won't work on:
# - SPARC systems without /dev/openprom
# - sun4c Sun SS1, SS1+, SLC, IPC with Open Boot PROM V1.X (no 'memory' lines
#   in devinfo/prtconf output)
# - sun4 kernel architecture, and sun3 and older systems
# - Perl 5.001 is known to have problems with hex number conversions
# - Does not detect unused VSIMMs (another FB installed) or second VSIMM
#
# To Do list and Revision History can be found on the maintainers web site at
# http://www.4schmidts.com/unix.html

# Uncomment for debugging (perl 5 only)
#use diagnostics;
$^W=1;	# Enables -w warning switch, put here for SunOS4 compatibility.
$starttime=(times)[0];

$version="V3.15";
$version_date="16-Jul-2019";
$URL="http://sourceforge.net/projects/memconf/";

$newpath="/usr/sbin:/sbin:/bin:/usr/bin:/usr/ucb:/usr/local/bin:/var/local/bin";
$ENV{PATH}=(defined($ENV{PATH})) ? "$newpath:$ENV{PATH}" : $newpath;
# Force C locale so that output is in English
$ENV{LC_ALL}="C";
$_=$];
($PERL_VERSION_MAJOR)=/(\d).*/;
if ($PERL_VERSION_MAJOR < 5) {
	($PERL_VERS)=/(\d\.\d)/;
	($PERL_PATCH)=/(\d*)$/;
	$PERL_PATCH="0$PERL_PATCH" if ($PERL_PATCH < 10);
	$PERL_VERSION="$PERL_VERS$PERL_PATCH";
} else {
	($PERL_VERSION)=/(\d\.\d{3}).*/;
}

$uname="/usr/bin/uname";
$uname="/bin/uname" if (-x '/bin/uname');
$running_on="";
if (-x $uname) {
	$os=&mychomp(`$uname`);
	$os="FreeBSD-based $os" if ($os ne "FreeBSD" && -f '/etc/freebsd-update.conf');
	$running_on=$os;
	$hostname=&mychomp(`$uname -n`);
	if ($os eq "AIX") {
		$machine=&mychomp(`$uname -M`);
		# oslevel command can return stderr output, so use uname instead
		$osmajor=&mychomp(`$uname -v`);
		$osminor=&mychomp(`$uname -r`);
		$osrel="$osmajor.$osminor";
		$kernver="";
		$platform=&mychomp(`$uname -p`);
	} else {
		$machine=&mychomp(`$uname -m`);
		$osrel=&mychomp(`$uname -r`);
		$kernver=&mychomp(`$uname -v`);
		$platform=$machine;
	}
} else {
	$hostname="";
	$machine="";
	$os="this unsupported";
	$osrel="";
	$kernver="";
}
$osrelease="";
$prtdiag_cmd="";
$prtdiag_exec="";
$have_prtdiag_data=0;
$prtdiag_checked=0;
$prtdiag_memory=0;
$prtfru_cmd="";
$have_prtfru_data=0;
$have_prtfru_details=0;
$missing_prtfru_details=" ";
$prtpicl_cmd="";
$have_prtpicl_data=0;
$psrinfo_cmd="";
$have_psrinfo_data=0;
$use_psrinfo_data=1;
$psrinfo_checked=0;
$virtinfo_cmd="";
$have_virtinfo_data=0;
$virtinfoLDOMcontrolfound=0;
$cfgadm_cmd="";
$have_cfgadm_data=0;
$ipmitool_cmd="";
$have_ipmitool_data=0;
$ipmi_cpucnt=0;
$ipmi_cputype="";
@ipmi_mem=("");
$ipmi_memory=0;
$smbios_cmd="";
$have_smbios_data=0;
@smbios_mem=("");
$smbios_memory=0;
$kstat_cmd="";
$have_kstat_data=0;
@kstat_brand=();
@kstat_MHz=();
$kstat_cpubanner="";
@kstat_core_id=("");
@kstat_core=("");
@kstat_ncore_per_chip=("");
@kstat_ncpu_per_chip=("");
$kstat_checked=0;
$ldm_cmd="";
$have_ldm_data=0;
$ldm_memory=0;
$free_cmd="";
$free_checked="";
$have_free_data=0;
$meminfo_cmd="";
$have_meminfo_data=0;
$modprobe_eeprom_cmd="";
$decodedimms_cmd="";
$decodedimms_checked="";
$have_decodedimms_data=0;
@reorder_decodedimms=();
$topology_cmd="";
@topology_header=();
@topology_data=();
$topology_mfg="";
$maxmembusspeed="";
$foundspeed=0;
$mixedspeeds=0;
$have_x86_devname=0;
$manufacturer="";
$systemmanufacturer="";
$boardmanufacturer="";
$baseboard="";
$biosvendor="";
if (-d '/usr/platform') {
	$platform=&mychomp(`$uname -i`);
	if (-x "/usr/platform/$platform/sbin/prtdiag") {
		$prtdiag_cmd="/usr/platform/$platform/sbin/prtdiag";
	} elsif (-x "/usr/platform/$machine/sbin/prtdiag") {
		$prtdiag_cmd="/usr/platform/$machine/sbin/prtdiag";
	} elsif (-x '/usr/sbin/prtdiag') {
		$prtdiag_cmd="/usr/sbin/prtdiag";
	}
} elsif (-x '/usr/kvm/prtdiag') {
	$platform=$machine;
	$prtdiag_cmd='/usr/kvm/prtdiag';
} elsif (-x '/usr/sbin/prtdiag') {
	$platform=&mychomp(`$uname -i`);
	$prtdiag_cmd="/usr/sbin/prtdiag";
}
if ($prtdiag_cmd) {
	if (-x $prtdiag_cmd) {
		$prtdiag_exec="$prtdiag_cmd";
	}
}
$buffer="";
$filename="";
$installed_memory=0;
$failed_memory=0;
$spare_memory=0;
$failing_memory=0;
$memory_error_logged=0;
$failed_fru="";
$ultra=0;
$simmbanks=0;
$bankcnt=0;
$slot0=0;
$smallestsimm=16777216;
$largestsimm=0;
$found8mb=0;
$found16mb=0;
$found32mb=0;
$found10bit=0;
$found11bit=0;
$foundbank1or3=0;
$sxmem=0;
$nvmem=0;
$nvmem1=0;
$nvmem2=0;
$memtype="SIMM";
$sockettype="socket";
$verbose=0;
$debug=0;
$recognized=1;
$untested=1;
$untested_type="";
$perlhexbug=0;
$exitstatus=0;
$meg=1048576;
@socketstr=("");
@socketlabelstr=("");
@orderstr=("");
@groupstr=("");
@bankstr=("");
@banksstr=("");
$bankname="banks";
@bytestr=("");
@slotstr=("");
$simmrangex=0;
$simmrange=1;
$showrange=1;
$start1x="";
$stop1x="";
@simmsizes=(0,16777216);
@simmsizesfound=();
@memorylines=("");
$socket="";
$socketlabel="";
$order="";
$group="";
$slotnum="";
$bank="";
$dualbank=0;
$byte="";
$gotmemory="";
$gotmodule="";
$gotmodulenames="";
$gotcpunames="";
$gotcpuboards="";
$slotname0="";
@boards_cpu="";
@boards_mem="";
$empty_banks="";
$banks_used="";
$nvsimm_banks="";
$boardslot_cpu=" ";
$boardslot_cpus=" ";
@boardslot_cpus=();
$boardslot_mem=" ";
$boardslot_mems=" ";
@boardslot_mems=();
$boardfound_cpu=0;
$boardfound_mem=0;
$prtdiag_has_mem=0;
$prtdiag_banktable_has_dimms=0;
$prtdiag_failed=0;
$prtconf_warn="";
$flag_cpu=0;
$flag_mem=0;
$flag_rewrite_prtdiag_mem=0;
$format_cpu=0;
$format_mem=0;
$foundname=0;
$sockets_used="";
$sockets_empty="";
$sortslots=1;
$devtype="";
$interleave=0;
$stacked=0;
$freq=0;
$sysfreq=0;
$cpufreq=0;
$cputype="";
$cputype_prtconf="";
$cputype_psrinfo="";
$cpuinfo_cputype="";
@cpucnt=();
$cpucntfrom="";
$cpucntflag=0;
$cpuinfo_cpucnt=0;
$have_cpuinfo_data=0;
$cpuinfo_coreidcnt=0;
$cpuinfo_cpucores=0;
@cpuinfo_physicalid=();
$cpuinfo_physicalidcnt=0;
$cpuinfo_siblings=0;
$cpuinfo_checked=0;
$xm_info_cmd="";
$have_xm_info_data=0;
$xen_ncpu=0;
$xen_nr_nodes=0;
$xen_sockets_per_node=0;
$xen_cores_per_socket=0;
$foundGenuineIntel=0;
@diagcpucnt=();
$diagthreadcnt=0;
$psrcpucnt=0;
$foundpsrinfocpu=0;
$ncpu=0;	# remains 0 if using prtdiag output only
$ndcpu=0;	# prtdiag cpu count
$npcpu=0;	# physical cpu count
$nvcpu=0;	# virtual cpu count
$necpu=0;	# empty cpu socket count
$threadcnt=0;
$corecnt=1;
$hyperthread=0;
$hyperthreadcapable=0;
$header_shown=0;
$romver="";
$romvernum="";
$SUNWexplo=0;
$banner="";
$bannermore="";
$cpubanner="";
$diagbanner="";
$model="";
$systemmodel="";
$boardmodel="";
$modelmore="";
$model_checked=0;
$BSD=0; # Initially assume SunOS 5.X
$config_cmd="/usr/sbin/prtconf -vp";
$config_command="prtconf";
$config_permission=0;
$permission_error="";
$dmidecode_error="";
$freephys=0;
$isX86=0;
$HPUX=0;
$devname="";	# Sun internal development code name
$familypn="";	# Sun family part number (system code)
$clone=0;
$totmem=0;
$latest_dmidecode_ver="2.12";
$minimum_dmidecode_ver="2.8";
$dmidecode_ver="0";
$dmidecodeURL="http://www.nongnu.org/dmidecode/";
$have_dmidecode=0;
$cpuarr=-1;
$memarr=-1;
$release="";
$waitshown=0;
$totalmemshown=0;
$vmshown=0;
$controlLDOMshown=0;
$helpers_defined=0;
$picl_foundmemory=0;
@picl_mem_pn=();
@picl_mem_bank=();
@picl_mem_dimm=();
if (-x '/usr/bin/id') {
	$uid=&mychomp(`/usr/bin/id`);
	$uid=~s/uid=//;
	$uid=~s/\(.*//;
} else {
	$uid=0; # assume super-user
}
$empty_memory_printed=0;
@filelist=();

#
# Parse options
#
foreach $name (@ARGV) {
	if ($name eq "-v") {
		# verbose mode
		$verbose=1;
	} elsif ($name eq "-d") {
		# more verbose debug mode
		$verbose=2;
	} elsif ($name eq "-debug") {
		# most verbose debug mode
		$debug=1;
	} elsif ($name eq "-debugtime") {
		# most verbose debug mode with timestamps
		$debug=2;
	} elsif ($name eq "-D") {
		# E-mail information of system to maintainer
		$verbose=3;
		open(MAILFILE, ">/tmp/memconf.output") || die "can't open /tmp/memconf.output: $!";
		print MAILFILE "Output from 'memconf -d' on $hostname\n";
		print MAILFILE "----------------------------------------------------\n";
		close(MAILFILE);
		*STDERR = *STDOUT;	# Redirect stderr to stdout
		open(STDOUT, "| tee -a /tmp/memconf.output") || die "can't open /tmp/memconf.output: $!";
		print "Gathering memconf data to E-mail to maintainer. This may take a few minutes.\nPlease wait...\n";
	} elsif (-f "$name/sysconfig/prtconf-vp.out") {
		# Sun/Oracle Explorer output
		$SUNWexplo=1;
		# Special case for regression testing Sun/Oracle Explorer data
		$os="SunOS";
		open(FILE, "<$name/sysconfig/prtconf-vp.out");
		@config=<FILE>;
		close(FILE);
		if (-f "$name/sysconfig/prtdiag-v.out") {
			open(FILE, "<$name/sysconfig/prtdiag-v.out");
			@prtdiag=<FILE>;
			$have_prtdiag_data=1;
			$prtdiag_cmd="/usr/platform/$platform/sbin/prtdiag";
			$prtdiag_exec="$prtdiag_cmd";
			close(FILE);
		}
		if (-f "$name/fru/prtfru_-x.out") {
			open(FILE, "<$name/fru/prtfru_-x.out");
			@prtfru=<FILE>;
			$have_prtfru_data=1;
			$prtfru_cmd='/usr/sbin/prtfru';
			close(FILE);
		}
		if (-f "$name/sysconfig/prtpicl-v.out") {
			open(FILE, "<$name/sysconfig/prtpicl-v.out");
			@prtpicl=<FILE>;
			$have_prtpicl_data=1;
			$prtpicl_cmd='/usr/sbin/prtpicl';
			close(FILE);
		}
		if (-f "$name/sysconfig/psrinfo-v.out") {
			open(FILE, "<$name/sysconfig/psrinfo-v.out");
			@psrinfo=<FILE>;
			$have_psrinfo_data=1;
			$psrinfo_cmd='/usr/sbin/psrinfo';
			close(FILE);
		}
		# Sun/Oracle Explorer does not include "psrinfo -p" or
		# "psrinfo -p -v" data yet.
		# Is virtinfo output available in Oracle Explorer?
		if (-f "$name/sysconfig/cfgadm-alv.out") {
			open(FILE, "<$name/sysconfig/cfgadm-alv.out");
			@cfgadm=<FILE>;
			$have_cfgadm_data=1;
			$cfgadm_cmd='/usr/sbin/cfgadm';
			close(FILE);
		}
		if (-f "$name/sysconfig/uname-a.out") {
			open(FILE, "<$name/sysconfig/uname-a.out");
			$uname=&mychomp(<FILE>);
			close(FILE);
			@unamearr=split(/\s/, $uname);
			$hostname=$unamearr[1];
			$machine=$unamearr[4];
			$osrel=$unamearr[2];
			$platform=$unamearr[6];
			$prtdiag_cmd="/usr/platform/$platform/sbin/prtdiag";
			$prtdiag_exec="$prtdiag_cmd";
		} else {
			if ($config[0] =~ /System Configuration:/) {
				@machinearr=split(/\s+/, $config[0]);
				$machine=$machinearr[4];
			}
			$osrel="";
			$hostname="";
		}
		if (-f "$name/sysconfig/prtconf-V.out") {
			open(FILE, "<$name/sysconfig/prtconf-V.out");
			$romver=&mychomp(<FILE>);
			close(FILE);
		}
		$filename="$name";
	} elsif (-f $name) {
		# Regression test file with prtconf/dmidecode output
		open(FILE, "<$name");
		@config=<FILE>;
		close(FILE);
		# Regression test file may also have prtdiag, etc.
		@prtdiag=@config;
		@prtfru=@config;
		$have_prtfru_data=1;
		@prtpicl=@config;
		$have_prtpicl_data=1;
		@psrinfo=@config;
		$have_psrinfo_data=1;
		@virtinfo=@config;
		$have_virtinfo_data=1;
		@cfgadm=@config;
		$have_cfgadm_data=1;
		@ipmitool=@config;
		$have_ipmitool_data=1;
		@ldm=@config;
		$have_ldm_data=1;
		@cpuinfo=@config;
		$have_cpuinfo_data=1;
		@meminfo=@config;
		$have_meminfo_data=1;
		@free=@config;
		$have_free_data=1;
		@xm_info=@config;
		$have_xm_info_data=1;
		@decodedimms=@config;
		@smbios=@config;
		$have_smbios_data=1;
		@kstat=@config;
		$have_kstat_data=1;
		@machinfo=@config;
		$hostname="";
		$osrel="";
		# Check test file to determine OS and machine
		for ($val=0; $val <= $#config; $val++) {
			if ($config[$val]) {
				if ($config[$val] =~ /System Configuration:/) {
					@machinearr=split(/\s+/, $config[$val]);
					$machine=$machinearr[4];
					$machine="" if (! defined($machine));
					$platform=$machine;
					# Special case for regression testing SunOS prtconf files
					$os="SunOS";
					last;
				} elsif ($config[$val] =~ / dmidecode |DMI .* present/) {
					$have_dmidecode=1;
					if ($config[$val] =~ / dmidecode /) {
						$dmidecode_ver=&mychomp($config[$val]);
						$dmidecode_ver=~s/.* dmidecode //;
					}
					$machine="";
					$platform="";
					# Special case for regression testing Linux dmidecode files
					$os="Linux";
					last;
				}
			}
		}
		$filename="$name";
	} else {
		&show_help;
	}
}
&pdebug("starting");
print "memconf:  $version $version_date $URL\n" if (-t STDOUT || $verbose);
&find_helpers;
if (! $filename && -r '/proc/cpuinfo') {
	open(FILE, "/proc/cpuinfo");
	@cpuinfo=<FILE>;
	close(FILE);
	$have_cpuinfo_data=1;
}
if (! $filename && $xm_info_cmd) {
	@xm_info=&run("$xm_info_cmd");
	$have_xm_info_data=1;
}
# Check cpuinfo now on unsupported machines (arm, mips, etc.)
&check_cpuinfo if (! $filename && $machine !~ /.86|ia64|amd64|sparc/);
&check_free;
&check_dmidecode if ($have_dmidecode);
if (! $filename) {
	if ($os eq "HP-UX") {
		&hpux_check;
		if (-x '/opt/propplus/bin/cprop') {
			&hpux_cprop;
		} elsif (-x '/usr/sbin/cstm') {
			&hpux_cstm;
		} else {
			&show_header;
			&show_supported;
		}
	} elsif ($os =~ /Linux|FreeBSD/) {
		&linux_distro if (! $release);
		if ($machine =~ /arm/i) {
			if (-f '/etc/Alt-F' && -f '/tmp/board') {
				# NAS model
				open(FILE, "</tmp/board");
				$model=&mychomp(<FILE>);
				close(FILE);
			} elsif (-f '/etc/model') {
				# DLink NAS model
				open(FILE, "</etc/model");
				$model=&mychomp(<FILE>);
				close(FILE);
			}
		}
		# Use dmidecode for Linux x86, not for Linux SPARC
		&check_dmidecode if ($config_cmd =~ /dmidecode/ && -x "$config_cmd" && ($machine =~ /.86/ || ! -x '/usr/sbin/prtconf'));
		if ($machine =~ /.86/ || ! -e '/dev/openprom') {
			&show_header;
			&show_supported;
		}
	} elsif ($os ne "SunOS") {
		&show_header;
		&show_supported;
	}
	if (-f '/vmunix') {
		# SunOS 4.X (Solaris 1.X)
		$BSD=1;
		if (! -x '/usr/etc/devinfo') {
			print "ERROR: no 'devinfo' command. Aborting.\n";
			&pdebug("exit 1");
			exit 1;
		}
		$config_cmd="/usr/etc/devinfo -pv";
		$config_command="devinfo";
	} else {
		# Solaris 2.X or later
		$BSD=0;
		if (! -x '/usr/sbin/prtconf') {
			print "ERROR: no 'prtconf' command. Aborting.\n";
			&pdebug("exit 1");
			exit 1;
		}
		$config_cmd="/usr/sbin/prtconf -vp";
		$config_command="prtconf";
	}
} else {
	# Special case for regression testing SunOS4 and SunOS5 files
	if ($filename =~ /\bdevinfo\./) {
		$os="SunOS";
		$BSD=1;
	} elsif ($filename =~ /\bprtconf\./) {
		$os="SunOS";
		$BSD=0;
	}
	# Special case for regression testing Linux files
	$os="Linux" if ($filename =~ /Linux/);
	# Special case for regression testing HP-UX files
	if ($filename =~ /\bcprop[\.+]/) {
		&hpux_check;
		&hpux_cprop;
	} elsif ($filename =~ /\b(cstm|machinfo)[\.+]/) {
		&hpux_check;
		&hpux_cstm;
	}
}
$kernbit="";
$hasprtconfV=0;
$solaris="";
$solaris="1.0" if ($osrel eq "4.1.1");
$solaris="1.0.1" if ($osrel eq "4.1.2");
$solaris="1.1" if ($osrel =~ /4.1.3/);
$solaris="1.1.1" if ($osrel eq "4.1.3_U1");
$solaris="1.1.2" if ($osrel eq "4.1.4");
if ($osrel =~ /^5./) {
	$osminor=$osrel;
	$osminor=~s/^5.//;
	if ($SUNWexplo) {
		if (-f "$filename/etc/release") {
			open(FILE, "<$filename/etc/release");
			$release=<FILE>;
			close(FILE);
		}
	} else {
		if (-f '/etc/release') {
			open(FILE, "</etc/release");
			$release=<FILE>;
			close(FILE);
		}
	}
	if ($release =~ "Solaris") {
		$release=~s/\s+//;
		$release=&mychomp($release);
		$solaris="$release";
	}
	if ($release =~ "OmniOS") {
		$release=~s/\s+//;
		$release=&mychomp($release);
		$solaris="$release";
	}
	if ($osminor =~ /^[7-9]$|^1[0-9]$/) {
		$hasprtconfV=1;
		$solaris=$osminor if (! $solaris);
		$kernbit=32;
		if ($SUNWexplo) {
			$cpuarch="";
			if (-f "$filename/sysconfig/isainfo.out") {
				open(FILE, "<$filename/sysconfig/isainfo.out");
				$cpuarch=<FILE>;
				close(FILE);
			} elsif (-f "$filename/sysconfig/isainfo-kv.out") {
				open(FILE, "<$filename/sysconfig/isainfo-kv.out");
				$cpuarch=<FILE>;
				close(FILE);
			}
			$kernbit=64 if ($cpuarch =~ /sparcv9|ia64|amd64/);
		} elsif (-x '/bin/isainfo') {
			$kernbit=&mychomp(`/bin/isainfo -b`);
		}
	} elsif ($osminor =~ /^[4-6]$/) {
		$hasprtconfV=1;
		$solaris="2.$osminor" if (! $solaris);
	} else {
		$solaris="2.$osminor";
	}
	# x86 Solaris 2.1 through 2.5.1 has different syntax than SPARC
	$config_cmd="/usr/sbin/prtconf -v" if ($machine eq "i86pc" && $osminor =~ /^[1-5]$/);
	# Solaris x86 returns booting system rather than PROM version
	$hasprtconfV=0 if ($machine eq "i86pc");
}
if (! $filename) {
	@config=&run("$config_cmd");
	if ($hasprtconfV) {
		# SPARC Solaris 2.4 or later
		$romver=&mychomp(`/usr/sbin/prtconf -V 2>&1`);
		if ($romver eq "Cannot open openprom device") {
			$prtconf_warn="ERROR: $romver";
			$romver="";
		} else {
			@romverarr=split(/\s/, $romver);
			$romvernum=$romverarr[1];
		}
	} else {
		# SPARC Solaris 2.3 or older, or Solaris x86
		# Try to use sysinfo if installed to determine the OBP version.
		# sysinfo is available from http://www.MagniComp.com/sysinfo/
		close(STDERR) if ($verbose != 3);
		$romver=`sysinfo -show romver 2>/dev/null | tail -1`;
		open(STDERR) if ($verbose != 3);
		if ($romver) {
			$romver=&mychomp($romver);
			@romverarr=split(/\s/, $romver);
			$romver=$romverarr[$#romverarr];
		} else {
			# Assume it is old
			$romver="2.X" if ($machine =~ /sun4/);
		}
		$romvernum=$romver;
	}
}
if ($filename && $have_prtpicl_data && ! $SUNWexplo) {
	foreach $line (@prtpicl) {
		$line=&dos2unix($line);
		$line=&mychomp($line);
		$line=~s/\s+$//;
		# Parse osrel and hostname from prtpicl data
		if ($line =~ /\s+:OS-Release\s/) {
			$osrel=$line;
			$osrel=~s/^.*:OS-Release\s+(.*)$/$1/;
			if ($osrel =~ /^5./) {
				$osminor=$osrel;
				$osminor=~s/^5.//;
				if ($osminor =~ /^[7-9]$|^1[0-9]$/) {
					$solaris=$osminor;
					# Solaris 10 SPARC and later is 64-bit
					$kernbit=64 if ($osminor =~ /^1[0-9]$/ && $machine =~ /sun4/);
				} else {
					# Solaris 2.6 and earlier is 32-bit
					$solaris="2.$osminor";
					$kernbit=32;
				}
				if ($machine =~ /86/) {
					$solaris .= " X86" if ($solaris !~ / X86/);
					# Solaris 9 X86 and earlier is 32-bit
					$kernbit=32 if ($osminor =~ /^[7-9]$/);
				} elsif ($machine =~ /sun4/) {
					$solaris .= " SPARC" if ($solaris !~ / SPARC/);
					$kernbit=32 if ($machine =~ /sun4[cdm\b]/);
				}
			}
		}
		if ($line =~ /\s+:HostName\s/) {
			$hostname=$line;
			$hostname=~s/^.*:HostName\s+(.*)$/$1/;
		}
	}
}

sub please_wait {
	return if ($waitshown);
	$waitshown=1;
	print "Gathering data for memconf. This may take over a minute. Please wait...\n" if (-t STDOUT);
}

sub find_helpers {
	return if ($helpers_defined);
	$helpers_defined=1;
	if ($os eq "HP-UX") {
		$config_cmd="echo 'selclass qualifier cpu;info;wait;selclass qualifier memory;info;wait;infolog'|/usr/sbin/cstm";
	} elsif ($os =~ /Linux|FreeBSD/) {
		if (defined($ENV{DMIDECODE}) && -x $ENV{DMIDECODE}) {
			# this may be a setuid-root version of dmidecode
			$config_cmd=$ENV{DMIDECODE};
		} else {
			foreach $bin ('/usr/local/sbin','/usr/local/bin','/usr/sbin','/usr/bin','/bin') {
				if (-x "$bin/dmidecode") {
					$config_cmd="$bin/dmidecode";
					last;
				}
			}
		}
	} elsif (-x '/usr/sbin/prtconf') {
		# Solaris 2.X or later
		$config_cmd="/usr/sbin/prtconf -vp";
		$prtfru_cmd='/usr/sbin/prtfru' if (-x '/usr/sbin/prtfru');
		$prtpicl_cmd='/usr/sbin/prtpicl' if (-x '/usr/sbin/prtpicl');
		$psrinfo_cmd='/usr/sbin/psrinfo' if (-x '/usr/sbin/psrinfo');
		$virtinfo_cmd='/usr/sbin/virtinfo' if (-x '/usr/sbin/virtinfo');
		$cfgadm_cmd='/usr/sbin/cfgadm' if (-x '/usr/sbin/cfgadm');
		$smbios_cmd='/usr/sbin/smbios' if (-x '/usr/sbin/smbios');
		$kstat_cmd='/usr/bin/kstat -m cpu_info' if (-x '/usr/bin/kstat');
		$ldm_cmd='/opt/SUNWldm/bin/ldm' if (-x '/opt/SUNWldm/bin/ldm');
	}
	if ($os =~ /Linux|FreeBSD/) {
		$free_cmd='/usr/bin/free -m' if (-x '/usr/bin/free');
		$meminfo_cmd='cat /proc/meminfo' if (-r '/proc/meminfo' || $running_on !~ /Linux|FreeBSD/);
		$topology_cmd='/usr/bin/topology --summary --nodes --cpus --io --routers' if (-x '/usr/bin/topology' || $running_on !~ /Linux|FreeBSD/);
		if (&is_xen_hv) {
			$xm_info_cmd='/usr/sbin/xm info';
			$xm_info_cmd='/usr/bin/xm info' if (-x '/usr/bin/xm');
		}
		if (-x '/usr/bin/decode-dimms.pl' || $running_on !~ /Linux|FreeBSD/) {
			$modprobe_eeprom_cmd='/sbin/modprobe eeprom';
			$decodedimms_cmd='/usr/bin/decode-dimms.pl';
		}
	}
	if ($os =~ /SunOS|Linux|FreeBSD/) {
		if (defined($ENV{IPMITOOL}) && -x $ENV{IPMITOOL}) {
			# this may be a setuid-root version of ipmitool
			$ipmitool_cmd=$ENV{IPMITOOL};
		} else {
			foreach $bin ('/usr/sfw/bin','/usr/local/sbin','/usr/local/bin','/usr/sbin','/usr/bin','/bin') {
				if (-x "$bin/ipmitool") {
					$ipmitool_cmd="$bin/ipmitool";
					last;
				}
			}
		}
	}
}

sub show_helpers {
	$s=shift;
	# Prefer prtconf for Linux SPARC
	if ($machine =~ /sun|sparc/i || $filename =~ /LinuxSPARC/) {
		print "$s/usr/sbin/prtconf -vp\n";
		print "$s$config_cmd\n" if ($config_cmd =~ /dmidecode/ && -x "$config_cmd");
	} else {
		print "$s$config_cmd\n" if ($config_cmd);
	}
	if ($os eq "SunOS") {
		print "$s$prtdiag_cmd -v\n" if ($prtdiag_exec);
		print "$s$prtfru_cmd -x\n" if ($prtfru_cmd);
		print "$s$prtpicl_cmd -v\n" if ($prtpicl_cmd);
		if ($psrinfo_cmd) {
			print "$s$psrinfo_cmd -v\n";
			$tmp=&mychomp(`$psrinfo_cmd -p 2>/dev/null`);
			if ($tmp ne "") {
				print "$s$psrinfo_cmd -p\n";
				print "$s$psrinfo_cmd -p -v\n";
			}
		}
		print "$s$virtinfo_cmd -pa\n" if ($virtinfo_cmd);
		print "$s$cfgadm_cmd -al\n" if ($cfgadm_cmd);
		print "$s$smbios_cmd\n" if ($smbios_cmd);
		print "$s$kstat_cmd\n" if ($kstat_cmd);
		print "$s$ldm_cmd list-devices -a -p\n" if ($ldm_cmd);
	}
	if ($os =~ /Linux|FreeBSD/) {
		print "${s}cat /proc/cpuinfo\n" if (-r '/proc/cpuinfo' || $running_on !~ /Linux|FreeBSD/);
		print "${s}cat /proc/meminfo\n" if (-r '/proc/meminfo' || $running_on !~ /Linux|FreeBSD/);
		print "$s$free_cmd\n" if ($free_cmd);
		print "${s}/usr/bin/topology\n" if (-x '/usr/bin/topology' || $running_on !~ /Linux|FreeBSD/);
		print "$s$xm_info_cmd\n" if ($xm_info_cmd);
		print "${s}/usr/bin/xenstore-ls /local/domain/DOMID\n" if (-x '/usr/bin/xenstore-ls' || $running_on !~ /Linux|FreeBSD/);
		print "$s$modprobe_eeprom_cmd; $decodedimms_cmd\n" if ($decodedimms_cmd);
	}
	if ($os =~ /SunOS|Linux|FreeBSD/) {
		print "$s$ipmitool_cmd fru\n" if ($ipmitool_cmd && $running_on eq $os);
	}
	if ($os eq "HP-UX") {
		print "$s/usr/contrib/bin/machinfo\n" if (-x '/usr/contrib/bin/machinfo');
	}
}

sub show_help {
	&find_helpers;
	if ($os =~ /Linux|FreeBSD/ && $config_cmd =~ /prtconf/) {
		if ($machine =~ /.86|ia64|amd64|sparc/) {
			$config_cmd="dmidecode";
		} else {
			$config_cmd="";
		}
	}
	print "Usage: memconf [ -v | -D | -h ] [explorer_dir]\n";
	print "                 -v            verbose mode\n";
	print "                 -D            E-mail results to memconf maintainer\n";
	print "                 -h            print help\n";
	print "                 explorer_dir  Sun/Oracle Explorer output directory\n";
	print "\nThis is memconf, $version $version_date\n\nCheck my website ";
	print "at $URL to get the latest\nversion of memconf.\n\n";
	&show_supported if ($os !~ /SunOS|HP-UX|Linux|FreeBSD/);
	print "Please send bug reports and enhancement requests along with ";
	print "the output of the\nfollowing commands to tom\@4schmidts.com ";
	print "as E-mail attachments so that memconf\nmay be enhanced. ";
	print "You can do this using the 'memconf -D' command if this system\n";
	print "can E-mail to the Internet.\n";
	&show_helpers("    ");
	&pdebug("exit");
	exit;
}

sub check_hyperthread {
	&pdebug("in check_hyperthread: corecnt=$corecnt");
	if ($cputype =~ /Intel.*\sXeon.*\s(E5540|E5620|L5520|X5560|X5570)\b/ && (($corecnt == 8 && ! &is_xen_hv) || &is_xen_hv)) {
		&pdebug("hyperthread=1: hack in cpubanner, cputype=$cputype") if (! $hyperthread);
		$hyperthread=1;
		$corecnt=4;
		$cputype=~s/Eight.Core //ig;
		$cputype=&multicore_cputype($cputype,$corecnt);
	}
	if ($cputype =~ /Intel.*\sXeon.*\s(L5640|X5670|X5675)\b/ && (($corecnt == 12 && ! &is_xen_hv) || &is_xen_hv)) {
		&pdebug("hyperthread=1: hack in cpubanner, cputype=$cputype") if (! $hyperthread);
		$hyperthread=1;
		$corecnt=6;
		$cputype=~s/Twelve.Core //ig;
		$cputype=&multicore_cputype($cputype,$corecnt);
	}
}

sub show_hyperthreadcapable {
	if ($hyperthreadcapable && ! $hyperthread) {
		print "NOTICE: CPU";
		if ($npcpu > 1) {
			print "s are";
		} else {
			print " is";
		}
		print " capable of Hyper-Threading, but it is not enabled in the BIOS.\n";
	}
}

sub cpubanner {
	# Hard-code some CPU models for hyper-threading on regression tests.
	# Hyper-Thread detection in Solaris x86 is done earlier by check_kstat
	# This hard-code method assumes Hyper-Threading is enabled if the
	# core count matches. This is not used when kstat data is available.
	if ($kstat_cpubanner && $modelmore !~ /MHz\)/) {
		&pdebug("in cpubanner, using kstat_cpubanner for cpubanner");
		$cpubanner=$kstat_cpubanner;
		return;
	}
	&checkX86;
	if ($filename && $os eq "SunOS" && $isX86 && ! $hyperthread && ! $kstat_checked) {
		&check_hyperthread;
	} elsif ($filename && &is_xen_hv) {
		# Xen Hypervisor hides Hyper-Threading from /proc/cpuinfo, so
		# also hard-core some CPU models for it.
		&check_hyperthread;
	}
	&pdebug("in cpubanner, corecnt=$corecnt, npcpu=$npcpu, nvcpu=$nvcpu, cputype=$cputype");
	if ($modelmore =~ /\(Solaris x86 machine\)/ && ! $cpubanner && $cputype ne "x86") {
		$modelmore="";
		while (($cf,$cnt)=each(%cpucnt)) {
			$cf=~/^(.*) (\d+)$/;
			$cputype=$1;
			$cpufreq=$2;
		}
		&x86multicorecnt($cputype);
		$ncpu=$cpucnt{"$cputype $cpufreq"};
		if ($cpucntflag == 0 && $npcpu == 0) {
			for $tmp (2,3,4,6,8,10,12,16) {
				$ncpu /= $tmp if ($corecnt == $tmp && $ncpu % $tmp == 0);
			}
		}
		$ncpu=$npcpu if ($npcpu);
		$cpubanner="$ncpu X " if ($ncpu > 1);
		$tmp=&multicore_cputype($cputype,$corecnt);
		$cpubanner .= "$tmp";
		$cpubanner .= " x86" if ($cputype eq "AMD");
		$cpubanner .= " ${cpufreq}MHz" if ($cpufreq && $cpufreq ne "0" && $cputype !~ /Hz$/);
	}
}

sub show_header {
	return if ($header_shown);
	&pdebug("cpucntfrom=$cpucntfrom");
	&cpubanner;
	$header_shown=1;
	undef %saw;
	@saw{@simmsizesfound}=();
	@simmsizesfound=sort numerically keys %saw;
	print "hostname: $hostname\n" if ($hostname);
	if ($filename) {
		print (($SUNWexplo) ? "Sun/Oracle Explorer directory" : "filename");
		print ": $filename\n";
	}
	if ($manufacturer) {
		$manufacturer="Sun Microsystems, Inc." if ($manufacturer =~ /Sun Microsystems/i);
	}
	if ($diagthreadcnt && $cpucntfrom eq "prtdiag") {
		# Replace @cpucnt with @diagcpucnt
		while (($cf,$tmp)=each(%cpucnt)) {
			delete $cpucnt{"$cf"};
			$cpucnt{"$cf"}=$diagcpucnt{"$cf"};
		}
	}
	if ($banner) {
		# See if banner includes CPU information
		if ($banner !~ /\(.*SPARC/ && $banner !~ /MHz/ && ! $kstat_cpubanner) {
			@cputypecnt=keys(%cpucnt);
			$x=0;
			while (($cf,$cnt)=each(%cpucnt)) {
				$x++;
				$cf=~/^(.*) (\d*)$/;
				$ctype=$1;
				$cfreq=$2;
				&multicore_cpu_cnt("");
				$cpubanner .= "$cnt X " if ($cnt > 1);
				if ($ctype =~ /390Z5/) {
					$cpubanner .= "SuperSPARC";
					$cpubanner .= "-II" if ($cfreq > 70);
				} elsif ($ctype =~ /MB86907/) {
					$cpubanner .= "TurboSPARC-II";
				} elsif ($ctype =~ /MB86904|390S10/) {
					$cpubanner .= "microSPARC";
					$cpubanner .= "-II" if ($cfreq > 70);
				} elsif ($ctype =~ /L2A0925/) {
					$cpubanner .= "microSPARC-IIep";
				} elsif ($ctype =~ /,RT62[56]/) {
					$cpubanner .= "hyperSPARC";
				} else {
					$cpubanner .= "$ctype";
				}
				$cpubanner .= " ${cfreq}MHz" if ($cfreq && $cpubanner !~ /Hz$/);
				$cpubanner .= ", " if ($x < scalar(@cputypecnt));
			}
		} elsif ($banner =~ /\(/ && $banner !~ /MHz/) {
			# CPU listed without speed
			while (($cf,$cnt)=each(%cpucnt)) {
				$cf=~/^(.*) (\d*)$/;
				$cfreq=$2;
				$banner=~s/\)/ ${cfreq}MHz\)/g if ($cfreq);
			}
		}
	}
	$modelmore="" if ($modelmore =~ /\(Solaris x86 machine\)/ && $model ne "i86pc" && $model ne "i86xpv" && $model ne "i86xen");
	if ($verbose) {
		if ($banner) {
			print "banner:   $banner";
			print " $bannermore" if ($bannermore);
			print " ($cpubanner)" if ($cpubanner);
			print "\n";
		}
		if ($manufacturer) {
			print "manufacturer: $manufacturer\n";
		}
		if ($model) {
			print "model:    $model";
			print " $modelmore" if ($modelmore);
			print " $realmodel" if ($realmodel);
			print " ($cpubanner)" if ($cpubanner && ! $banner);
			print "\n";
		}
		if ($baseboard) {
			print "base board: $baseboard\n";
		}
		if (! $clone) {
			$tmp="Sun";
			if ($manufacturer) {
				$tmp="Sun/Oracle" if ($manufacturer =~ /^Oracle\b/);
			}
			$tmp="Oracle" if ($platform =~ /^ORCL,/);
			print "$tmp development codename: $devname\n" if ($devname);
			print "$tmp Family Part Number: $familypn\n" if ($familypn);
		}
		if (! $filename || $SUNWexplo) {
			if ($solaris) {
				print "Solaris " if ($solaris !~ /(Solaris|OmniOS)/);
				print "$solaris";
				if ($machine =~ /86/) {
					print " X86" if ($solaris !~ / X86/);
				} elsif ($machine =~ /sun4/) {
					print " SPARC" if ($solaris !~ / SPARC/);
				}
				print ", ${kernbit}-bit kernel, " if ($kernbit);
			}
			if ($os =~ /Linux|FreeBSD/ && $release) {
				if (-x '/bin/busybox') {
					@busybox=`/bin/busybox cat --help 2>&1`;
					$busyboxver="";
					for (@busybox) {
						next if (! /^BusyBox/);
						$busyboxver=&mychomp($_);
						$busyboxver=~s/\).*$/\)/;
					}
					if ($busyboxver) {
						print "$busyboxver, ";
					} else {
						print "BusyBox, ";
					}
				}
				print "$release\n";
			} else {
				print "$os";
				print " $osrel" if ($osrel);
				print " ($osrelease)" if ($osrelease);
				print ", ${kernbit}-bit kernel" if ($kernbit && $HPUX);
				print "\n";
			}
		} elsif ($HPUX) {
			print "$os";
			print " $osrel" if ($osrel);
			print " ($osrelease)" if ($osrelease);
			print ", ${kernbit}-bit kernel" if ($kernbit);
			print "\n";
		} elsif ($os =~ /Linux|FreeBSD/) {
			print "BusyBox " if ($filename =~ /BusyBox/);	# for regression tests
			if ($release) {
				print "$release";
			} elsif ($machine =~ /sun|sparc/i || $filename =~ /LinuxSPARC/) {
				print "Linux SPARC";
			} elsif ($machine =~ /arm/i) {
				print "Linux ARM";
			} elsif ($machine =~ /mips/i) {
				print "Linux MIPS";
			} elsif ($have_dmidecode) {
				print "Linux x86";
			}
			print ", ${kernbit}-bit kernel" if ($kernbit);
			print "\n";
		} elsif ($BSD) {
			print "Solaris 1.X SPARC, 32-bit kernel, SunOS 4.X\n";
		} elsif ($osrel && $solaris) {
			print "Oracle " if ($solaris !~ /Oracle/ && $platform =~ /^ORCL,/);
			print "Solaris " if ($solaris !~ /(Solaris|OmniOS)/);
			print "$solaris, ";
			print "${kernbit}-bit kernel, " if ($kernbit);
			print "SunOS $osrel\n";
		} else {
			print "Solaris 2.X";
			if ($machine =~ /86/) {
				print " X86";
			} elsif ($machine =~ /sun4/) {
				print " SPARC";
			}
			print ", SunOS 5.X\n";
		}
		$ncpu=1 if ($ncpu == 0);	# It has at least 1 CPU
		if ($kstat_cpubanner) {
			$tmp=$kstat_cpubanner;
			$tmp=~s/(\d) X /$1 /g;
			print "1 " if ($tmp eq $kstat_cpubanner);
			print "$tmp cpu";
			print "s" if ($tmp ne $kstat_cpubanner);
			print (($sysfreq) ? ", " : "\n");
		} elsif ($cpuarr == -1 && ! &is_xen_vm) {
			@cputypecnt=keys(%cpucnt);
			$x=0;
			$ctype="";
			while (($cf,$cnt)=each(%cpucnt)) {
				if ($cpucntflag == 0 && $npcpu == 0 && $cpucntfrom ne "prtdiag") {
					for $tmp (2,3,4,6,8,10,12,16) {
						$cnt /= $tmp if ($corecnt == $tmp && $cnt % $tmp == 0);
					}
					$cpucntflag=1;
				}
				if ($npcpu) {
					$cnt=$npcpu;
				} else {
					$cnt=$ndcpu if ($ndcpu);
					$cnt=$ncpu if ($cpucntfrom =~ /cpuinfo/);
				}
				$x++;
				$cf=~/^(.*) (\d*)$/;
				$ctype=$1;
				$ctype=$cf if (! $ctype);
				$cfreq=$2;
				&checkX86;
				$ctype=&multicore_cputype($ctype,$corecnt) if ($isX86);
				&multicore_cpu_cnt("");
				$ctype="" if ($ctype =~ /^\S*-Core $/);
				if ($ctype) {
					print "$cnt $ctype";
					if ($cfreq) {
						print " ${cfreq}MHz" if ($cfreq && $ctype !~ /Hz$/);
					}
					print " cpu";
					print "s" if ($cnt > 1);
					print ", " if ($x < scalar(@cputypecnt));
				}
			}
			print (($sysfreq) ? ", " : "\n") if ($x && $ctype);
		}
		print "system freq: ${sysfreq}MHz\n" if ($sysfreq);
	} else {
		$modelbuf="";
		if ($manufacturer) {
			$modelbuf .= "$manufacturer " if ($banner !~ /^$manufacturer/ && $model !~ /^$manufacturer/ && ($banner || $model));
		}
		if ($banner && $bannermore) {
			$modelbuf .= "$banner $bannermore";
		} elsif ($modelmore) {
			$modelbuf .= "$model $modelmore";
		} elsif ($banner) {
			$modelbuf .= "$banner";
		} elsif ($diagbanner) {
			$modelbuf .= "$diagbanner";
		} elsif ($model) {
			$modelbuf .= "$model";
		}
		if ($cpubanner) {
			if ($modelbuf) {
				$modelbuf .= " ($cpubanner)";
			} else {
				$modelbuf = "$cpubanner";
			}
		}
		$modelbuf .= " $realmodel" if ($realmodel);
		print "$modelbuf\n" if ($modelbuf);
	}
	# debug output
	if ($verbose > 1) {
		print "banner = $banner\n" if ($banner);
		print "diagbanner = $diagbanner\n" if ($diagbanner);
		print "cpubanner = $cpubanner\n" if ($cpubanner);
		print "bannermore = $bannermore\n" if ($bannermore);
		print "model = $model\n" if ($model);
		print "modelmore = $modelmore\n" if ($modelmore);
		print "machine = $machine\n" if ($machine);
		print "platform = $platform\n" if ($platform);
		print "ultra = $ultra\n" if ($ultra);
		if ($ultra eq "AXi") {
			print "found10bit = $found10bit\n";
			print "found11bit = $found11bit\n";
		}
		print "systemmanufacturer = $systemmanufacturer\n" if ($systemmanufacturer);
		print "systemmodel = $systemmodel\n" if ($systemmodel);
		print "boardmanufacturer = $boardmanufacturer\n" if ($boardmanufacturer);
		print "boardmodel = $boardmodel\n" if ($boardmodel);
		print "motherboard = $motherboard\n" if ($motherboard);
		print "romver = $romver\n" if ($romver);
		print "freephys = $freephys\n" if ($freephys);
		print "perl version: " . &mychomp($]) . "\n";
		print "memory line: $gotmemory\n" if ($gotmemory);
		print "module info: $gotmodule\n" if ($gotmodule);
		print "dmidecode version: $dmidecode_ver\n" if ($dmidecode_ver);

		# Fujitsu GP7000F and PrimePower systems
		print "cpu name info: $gotcpunames\n" if ($gotcpunames);
		print "cpu board info: $gotcpuboards\n" if ($gotcpuboards);
		print "module name info: $gotmodulenames\n" if ($gotmodulenames);

		print "simmsizes = @simmsizes\n" if ($simmsizes[0]);
		print "simmsizesfound = @simmsizesfound\n" if ($simmsizesfound[0]);
	}
	if ($verbose && $boardfound_cpu) {
		if ($format_cpu == 1) {
			print "CPU Units: Frequency Cache-Size Version\n" if ($model =~ /-Enterprise/ || $ultra eq "e");
		} else {
			print "CPU Units:\n";
		}
		if ($model ne "SPARCserver-1000" && $model ne "SPARCcenter-2000") {
			print @boards_cpu;
			print "Memory Units:\n" if (! &is_virtualmachine);
		}
	}
	if ($interleave && ! &is_virtualmachine) {
		print "Memory Interleave Factor: $interleave";
		print "-way" if ($interleave =~/^\d+$/);
		print "\n";
	}
	print "Maximum Memory Bus Speed: $maxmembusspeed\n" if ($maxmembusspeed);
}

sub show_unrecognized {
	if ($perlhexbug) {
		print "       This is most likely because Perl V$PERL_VERSION";
		print " is buggy in hex number\n       conversions. Please";
		print " upgrade your perl release to Perl V5.002 or later\n";
		print "       for best results.\n";
	} else {
		print "       This is most likely because memconf $version";
		print " does not completely\n       recognize this $os";
		print " $osrel" if ($osrel);
		print " $platform system.\n";
		&show_request if ($untested == 0);
	}
}

sub show_untested {
	$osname="$os $osrel";
	$osname="$os" if ($osrel eq "");
	if ($untested_type eq "OS") {
		print "WARNING: This is an untested $osname operating";
	} elsif ($untested_type eq "OBP") {
		print "ERROR: This is an untested $osname OBP $romvernum";
	} elsif ($untested_type eq "CPU") {
		print "ERROR: This is an untested CPU type on this $osname";
	} else {
		print "ERROR: This is an untested $osname";
	}
	print " system by memconf $version\n";
	print "       Please let the author know how it works.\n";
	$exitstatus=1;
	&show_request;
}

sub show_request {
	print "       Check my website at $URL\n";
	print "       for a newer version of memconf that may recognize this system better.\n";
	print "       Please run 'memconf -D' to create a tar file of the output from the\n";
	print "       following commands to send to Tom Schmidt (tom\@4schmidts.com) so\n";
	print "       memconf $version may be enhanced to properly recognize this system:\n";
	print "            memconf -d\n";
	&show_helpers("            ");
	if ($untested) {
		print "       If this system is a Sun clone, please also send any hardware\n";
		print "       documentation on the memory layout that you may have.\n";
	}
}

sub show_supported {
	&show_total_memory;
	print "ERROR: memconf $version is not supported on this $os";
	print" $osrel $machine system.\n       memconf is supported on:\n";
	print "           Solaris (SunOS 4.X or 5.X) on SPARC\n";
	print "           Solaris 10 6/06 or later on x86 with /usr/platform/i86pc/sbin/prtdiag\n";
	print "           Linux on SPARC with sparc-utils and /dev/openprom\n";
	print "           Linux on x86 and x86_64 with kernel-utils or pmtools for dmidecode\n";
	print "           FreeBSD on x86 and x86_64 with dmidecode\n";
	print "           Most HP-UX systems with SysMgmtPlus (cprop) or Support Tools Manager (cstm)\n";
	if ($os =~ /Linux|FreeBSD/) {
		if ($machine =~ /.86|ia64|amd64|sparc/) {
			if ($config_cmd =~ /dmidecode/) {
				print "ERROR: dmidecode command was not found. Please install ";
				print "dmidecode from\n       $dmidecodeURL ";
				print "to fix this issue.\n";
			}
			print "NOTICE: This may be corrected by installing the ";
			print (($machine =~ /sparc/) ? "sparc-utils" : "kernel-utils or pmtools");
			print "\n       package if available for this $machine system.\n";
		} else {
			$config_cmd="";
		}
	}
	print "       memconf may be able to process Sun/Oracle Explorer data on this machine.\n";
	print "       Check my website at $URL\n";
	print "       for a newer version of memconf that may recognize this system better.\n";
	$exitstatus=1;
	&mailmaintainer if ($verbose == 3);
	&pdebug("exit $exitstatus");
	exit $exitstatus;
}

sub show_memory {
	$mem=shift;
	print "${mem}MB";
	if ($mem >= $meg) {
		print " (", $mem / $meg, "TB)";
	} elsif ($mem >= 1024) {
		print " (", $mem / 1024, "GB)";
	}
	print "\n";
}

sub show_memory_label {
	$mem=shift;
	return if (! defined($mem));
	return "$mem" if ($mem =~ /[MG]B/);
	return $mem / 1024 . "GB" if ($mem >= 1024);
	return "${mem}MB";
}

sub show_errors {
	if ($failing_memory) {
		print "ERROR: Some of the installed memory has failed.\n";
		print "       You should consider replacing the failed memory.\n";
		$exitstatus=1;
	}
	if ($unknown_JEDEC_ID) {
		print "ERROR: An unknown memory manufacturer was detected by memconf.\n";
		&show_request;
		$exitstatus=1;
	}
}

sub check_model {
	&pdebug("in check_model, model=$model, platform=$platform, banner=$banner, diagbanner=$diagbanner");
	$modelbanner=$banner;
	$modelbanner=$diagbanner if ($banner eq "" && $diagbanner ne "");
	&find_helpers;
	# Workaround for broken "uname -i" on Oracle SPARC T3 systems
	$platform=$model if ($platform eq "sun4v");
	if ($filename) {
		$platform=$model;
		$platform="SUNW,Ultra-5_10" if ($diagbanner =~ /Sun Ultra 5\/10/);
		$platform="SUNW,Sun-Fire" if ($diagbanner =~ /Sun Fire ([346]8[01]0|E[246]900)\b/);
		$platform="SUNW,Sun-Fire-15000" if ($diagbanner =~ /Sun Fire E2[05]K\b/);
		$platform=~s/-S$// if ($model =~ /Sun-Blade-[12]500-S\b/);
		if ($prtdiag_cmd =~ /platform/) {
			$prtdiag_cmd="/usr/platform/$platform/sbin/prtdiag";
			$prtdiag_cmd="/usr/platform/sun4v/sbin/prtdiag" if ($platform =~ /ORCL,/);
		}
	}
	$model=~s/.*SUNW,//g;
	$model=~s/.*ORCL,//g;
	$model=~s/TWS,//g;
	$model=~s/CYCLE,//g;
	$model=~s/Tadpole_//g;
	$model=~s/ASPX,//g;
	$model=~s/PFU,//g;
	$model=~s/FJSV,//g;
	$model=~s/CompuAdd //g;
	$model=~s/RDI,//g;
	$model=~s/\s+$//;
	$ultra="ultra" if ($ultra eq 0 && ($model =~ /Ultra|Blade|Fire/ || ($machine eq "sun4v" && ! $filename)));
	if ($model =~ /Fire[- ](X|B[12]00x)/i) {
		# Sun Fire X??00 Servers, i86pc
		# Sun B100x or B200x Blade Servers, i86pc
		$ultra="";
		$machine="x86" if ($machine ne "i86pc");
		$untested=1;
		&x86_devname;
	}
	$ultra="sparc64" if ($model =~ /SPARC64/);
	$ultra="e" if ($model =~ /-Enterprise/ && $model !~ /SPARC-Enterprise/);
	$ultra=1 if ($model =~ /Ultra-1\b/);
	$ultra=2 if ($model =~ /Ultra-2\b/);
	$ultra=5 if ($model =~ /Ultra-5\b/);
	$ultra="5_10" if ($model =~ /Ultra-5_10\b/);
	$ultra=30 if ($model =~ /Ultra-30\b/);
	$ultra=60 if ($model =~ /Ultra-60\b/);
	$ultra=80 if ($model =~ /Ultra-80\b/);
	$ultra=250 if ($model =~ /Ultra-250\b/);
	$ultra=450 if ($model =~ /Ultra-4\b/);
	$ultra="Netra t1" if ($banner =~ /Netra t1\b/);
	if ($model =~ /Ultra-4FT\b/) {
		$ultra="Netra ft1800";
		$bannermore="(Netra ft1800)";
		$modelmore="(Netra ft1800)";
	}
	$ultra="Sun Blade 1000" if ($model =~ /Ultra-100\b/); # prototype
	$ultra="Sun Blade 1000" if ($model =~ /Sun-Blade-1000\b/);
	$ultra="Sun Blade 2000" if ($model =~ /Sun-Blade-2000\b/);
	$ultra="Netra 20" if ($model =~ /Netra-20\b/);
	$ultra="Netra 20" if ($model =~ /Netra-T4\b/);
	# E2900/E4900 also use Netra-T12
	$ultra="Netra T12" if ($model =~ /Netra-T12\b/ && $ultra !~ /Sun Fire/);
	$ultra="Sun Blade 100" if ($model =~ /Grover\b/); # prototype
	$ultra="Sun Blade 100" if ($model =~ /Sun-Blade-100\b/);
	$ultra="Sun Fire 280R" if ($model =~ /Enterprise-820R\b/); # prototype
	$ultra="Sun Fire 280R" if ($model =~ /Sun-Fire-280R\b/);
	$ultra="Sun Fire" if ($model =~ /Serengeti\b/); # prototype
	$ultra="Sun Fire" if ($model eq "Sun-Fire" || $model =~ /Sun-Fire-[346]8[01]0\b/);
	$ultra="Sun Fire V480" if ($model =~ /Sun-Fire-480R\b/);
	$ultra="Sun Fire V490" if ($model =~ /Sun-Fire-V490\b/);
	$ultra="Sun Fire V880" if ($model =~ /Sun-Fire-880\b/);
	$ultra="Sun Fire V890" if ($model =~ /Sun-Fire-V890\b/);
	# Sun Fire 12K, E25K, etc. systems identifies itself as Sun Fire 15K
	$ultra="Sun Fire 15K" if ($model =~ /Sun-Fire-15000\b/ && $ultra !~ /Sun Fire /);
	$ultra="Sun Fire 12K" if ($model =~ /Sun-Fire-12000\b/);
	$ultra="Serverblade1" if ($model =~ /Serverblade1\b/);
	# UltraSPARC-IIIi (Jalapeno) systems
	$ultra="Enchilada" if ($model =~ /Enchilada\b/); # prototype
	$ultra="Enchilada" if ($model =~ /Sun-Fire-V210\b/);
	$ultra="Enchilada" if ($model =~ /Netra-210\b/);
	$ultra="Enchilada" if ($model =~ /Sun-Fire-V240\b/);
	$ultra="Enchilada" if ($model =~ /Netra-240\b/);
	$ultra="Sun Fire V440" if ($model =~ /Sun-Fire-V440\b/);
	$ultra="Netra 440" if ($model =~ /Netra-440\b/);
	$ultra="Sun Fire V250" if ($model =~ /Sun-Fire-V250\b/);
	$ultra="Sun Blade 1500" if ($model =~ /Sun-Blade-1500\b/);
	$ultra="Sun Blade 2500" if ($model =~ /Sun-Blade-2500\b/);
	if ($model =~ /Sun-Blade-[12]500-S\b/) {
		$model=~s/-S$//;
		$modelmore="(Silver)" if ($banner !~ /\(Silver\)/);
	}
	$ultra="Sun Ultra 45 Workstation" if ($model =~ /Sun-Ultra-45-Workstation\b/ || $model eq "A70");
	$ultra="Sun Ultra 25 Workstation" if ($model =~ /Sun-Ultra-25-Workstation\b/ || $model eq "Ultra-25");
	$ultra="Sun Ultra 45 or Ultra 25 Workstation" if ($model =~ /Sun-Ultra-45-or-Ultra-25-Workstation\b/);
	$ultra="Sun Fire V125" if ($model =~ /Sun-Fire-V125\b/);
	$ultra="Seattle" if ($model =~ /Sun-Fire-V215\b/);
	$ultra="Seattle" if ($model =~ /Sun-Fire-V245\b/);
	$ultra="Boston" if ($model =~ /Sun-Fire-V445\b/);
	# UltraSPARC-IV (Jaguar) or UltraSPARC-IV+ (Panther) systems
	$ultra="Sun Fire E2900" if ($model =~ /Sun-Fire-E2900\b/);
	$ultra="Sun Fire E4900" if ($model =~ /Sun-Fire-E4900\b/);
	$ultra="Sun Fire E6900" if ($model =~ /Sun-Fire-E6900\b/);
	$ultra="Sun Fire E20K" if ($model =~ /Sun-Fire-(E|Enterprise-)20K\b/);
	$ultra="Sun Fire E25K" if ($model =~ /Sun-Fire-(E|Enterprise-)25K\b/);
	# SPARC64-VI or SPARC64-VII systems
	$ultra=$banner if ($banner =~ /SPARC Enterprise M[34589]000 Server/);
	# UltraSPARC-T1 (Niagara) systems
	if ($model =~ /Sun-Fire-T200\b/) {
		$ultra="T2000";
		$modelmore="(Sun Fire T2000)";
	}
	$ultra="T2000" if ($model =~ /Sun-Fire-T2000\b|SPARC-Enterprise-T2000\b|Netra-T2000\b/ || $modelbanner =~ /SPARC Enterprise T2000\b|Netra T2000\b/);
	$ultra="T1000" if ($model =~ /Sun-Fire-T1000\b|SPARC-Enterprise-T1000\b/ || $modelbanner =~ /SPARC Enterprise T1000/);
	$ultra="T6300" if ($model =~ /Sun-Blade-T6300\b/ || $modelbanner =~ /\bT6300\b/);
	# UltraSPARC-T2 (Niagara-II) systems
	$ultra="T5120" if ($model =~ /SPARC-Enterprise-T5120\b/ || $modelbanner =~ /\bT5120\b/);
	$ultra="T5220" if ($model =~ /(SPARC-Enterprise|Netra)-T5220\b/ || $modelbanner =~ /\bT5220\b/);
	$ultra="T6320" if ($model =~ /Sun-Blade-T6320\b/ || $modelbanner =~ /\bT6320\b/);
	$ultra="CP3260" if ($model =~ /Netra-CP3260\b/ || $modelbanner =~ /\bNetra CP3260\b/);
	# UltraSPARC-T2+ (Victoria Falls) systems
	$ultra="T5140" if ($model =~ /\bT5140\b/ || $modelbanner =~ /\bT5140\b/);
	$ultra="T5240" if ($model =~ /\bT5240\b|-USBRDT-5240\b/ || $modelbanner =~ /\bT5240\b/);
	$ultra="T5440" if ($model =~ /\bT5440\b|-USBRDT-5440\b/ || $modelbanner =~ /\bT5440\b/);
	$ultra="T6340" if ($model =~ /Sun-Blade-T6340\b/ || $modelbanner =~ /\bT6340\b/);
	# SPARC-T3 (Rainbow Falls) systems
	$ultra="T3-1" if ($model =~ /SPARC-T3-1\b/ || $modelbanner =~ /SPARC T3-1\b/);
	$ultra="T3-1B" if ($model =~ /SPARC-T3-1B\b/ || $modelbanner =~ /SPARC T3-1B\b/);
	$ultra="T3-1BA" if ($model =~ /SPARC-T3-1BA\b/ || $modelbanner =~ /SPARC T3-1BA\b/);
	$ultra="T3-2" if ($model =~ /SPARC-T3-2\b/ || $modelbanner =~ /SPARC T3-2\b/);
	$ultra="T3-4" if ($model =~ /SPARC-T3-4\b/ || $modelbanner =~ /SPARC T3-4\b/);
	# SPARC-T4 systems
	$ultra="T4-1" if ($model =~ /SPARC-T4-1\b/ || $modelbanner =~ /SPARC T4-1\b/);
	$ultra="T4-1B" if ($model =~ /SPARC-T4-1B\b/ || $modelbanner =~ /SPARC T4-1B\b/);
	$ultra="T4-2" if ($model =~ /SPARC-T4-2\b/ || $modelbanner =~ /SPARC T4-2\b/);
	$ultra="T4-2B" if ($model =~ /SPARC-T4-2B\b/ || $modelbanner =~ /SPARC T4-2B\b/);
	$ultra="T4-4" if ($model =~ /SPARC-T4-4\b/ || $modelbanner =~ /SPARC T4-4\b/);
	# SPARC-T5 systems
	$ultra="T5-2" if ($model =~ /SPARC-T5-2\b/ || $modelbanner =~ /SPARC T5-2\b/);
	$ultra="T5-4" if ($model =~ /SPARC-T5-4\b/ || $modelbanner =~ /SPARC T5-4\b/);
	$ultra="T5-8" if ($model =~ /SPARC-T5-8\b/ || $modelbanner =~ /SPARC T5-8\b/);
	$ultra="T5-1B" if ($model =~ /SPARC-T5-1B\b/ || $modelbanner =~ /SPARC T5-1B\b/);
	# SPARC M5 and M6 systems
	$ultra="M5-32" if ($model =~ /SPARC-M5-32\b/ || $modelbanner =~ /SPARC M5-32\b/);
	$ultra="M6-32" if ($model =~ /SPARC-M6-32\b/ || $modelbanner =~ /SPARC M6-32\b/);
	# Fujitsu SPARC M10 systems
	$ultra="M10-1" if ($model =~ /SPARC-M10-1\b/ || $modelbanner =~ /SPARC M10-1\b/);
	$ultra="M10-4" if ($model =~ /SPARC-M10-4\b/ || $modelbanner =~ /SPARC M10-4\b/);
	$ultra="M10-4S" if ($model =~ /SPARC-M10-4S\b/ || $modelbanner =~ /SPARC M10-4S\b/);
	# SPARC S7 and M7 systems
	$ultra="S7-2" if ($model =~ /SPARC-S7-2\b/ || $modelbanner =~ /SPARC S7-2\b/);
	$ultra="S7-2L" if ($model =~ /SPARC-S7-2L\b/ || $modelbanner =~ /SPARC S7-2L\b/);
	$ultra="T7-1" if ($model =~ /SPARC-T7-1\b/ || $modelbanner =~ /SPARC T7-1\b/);
	$ultra="T7-2" if ($model =~ /SPARC-T7-2\b/ || $modelbanner =~ /SPARC T7-2\b/);
	$ultra="T7-4" if ($model =~ /SPARC-T7-4\b/ || $modelbanner =~ /SPARC T7-4\b/);
	$ultra="M7-8" if ($model =~ /SPARC-M7-8\b/ || $modelbanner =~ /SPARC M7-8\b/);
	$ultra="M7-16" if ($model =~ /SPARC-M7-16\b/ || $modelbanner =~ /SPARC M7-16\b/);
	$ultra="T8-2" if ($model =~ /SPARC-T8-2\b/ || $modelbanner =~ /SPARC T8-2\b/);

	# Older SPARCstations
	$modelmore="SPARCstation SLC" if ($model eq "Sun 4/20");
	$modelmore="SPARCstation ELC" if ($model eq "Sun 4/25");
	$modelmore="SPARCstation IPC" if ($model eq "Sun 4/40");
	$modelmore="SPARCstation IPX" if ($model eq "Sun 4/50");
	$modelmore="SPARCstation 1" if ($model eq "Sun 4/60");
	$modelmore="SPARCstation 1+" if ($model eq "Sun 4/65");
	$modelmore="SPARCstation 2" if ($model eq "Sun 4/75");
	$modelmore="(SPARCsystem 600)" if ($model =~ /Sun.4.600/ && $banner !~ /SPARCsystem/);
	$modelmore="Sun 4/30" if ($model =~ /SPARCstation-LX/);
	$modelmore="Sun 4/15" if ($model =~ /SPARCclassic/);
	$modelmore="Sun 4/10" if ($model =~ /SPARCclassic-X/);
	$modelmore="(SPARCstation 10SX)" if ($model =~ /Premier-24/);
	if ($model eq "S240") {
		$manufacturer="Sun Microsystems, Inc.";
		$modelmore="SPARCstation Voyager";
	}
	# x86
	&checkX86;
	if ($isX86) {
		$modelmore="(Solaris x86 machine)";
		$cputype="x86";
		$machine=$model;
		$ultra=0;
		$cpucntfrom="prtconf" if (! $cpucntfrom);
		return if ($model_checked);
		&check_prtdiag if ($use_psrinfo_data == 2);
		&check_psrinfo;
		&cpubanner;
		$cpucnt{"$cputype $cpufreq"}++;
	}
	# Clones
	if ($banner =~ /\bMP-250[(\b]/) {
		$ultra="axus250";
		$bannermore="Ultra-250";
		$modelmore="(Ultra-250)";
	}
	$manufacturer="AXUS" if ($ultra =~ /axus/);
	$manufacturer="Force Computers" if ($model =~ /SPARC CP/);
	if ($model eq "S3GX") {
		$bannermore="(SPARCbook 3GX)";
		$modelmore="(SPARCbook 3GX)";
	}
	if ($model eq "S3XP") {
		$bannermore="(SPARCbook 3XP)";
		$modelmore="(SPARCbook 3XP)";
	}
	$manufacturer="Sun Microsystems, Inc." if ($banner !~ /Axil/ && (
		$model =~ /^SPARCstation|^SPARCsystem|^SPARCclassic/ ||
		$model =~ /^SPARCserver|^SPARCcenter|Enterprise|Premier 24/ ||
		$model =~ /Netra|Sun.Fire|Sun.Blade|Serverblade1/));
	# Oracle purchased Sun in 2010, so newer systems bear the Oracle name.
	$manufacturer="Oracle Corporation" if ($platform =~ /^ORCL,/ && $manufacturer eq "Sun Microsystems, Inc.");
	if ($model =~ /Auspex/) {
		$manufacturer="Auspex";
		$model=~s/Auspex //g;
		$bannermore="Netserver";
		$modelmore="Netserver";
	}
	$manufacturer="Fujitsu" if ($banner =~ /Fujitsu/);
	$manufacturer="Fujitsu Siemens" if ($banner =~ /Fujitsu Siemens/);
	$manufacturer="Fujitsu Siemens Computers" if ($banner =~ /Fujitsu Siemens Computers/);
	if ($model =~ /S-4|^GPU[SZU]/ || $model eq "GP") {
		$manufacturer="Fujitsu" if ($manufacturer !~ /^Fujitsu/);
		$model=~s,_,/,g;
		$untested=1 if ($model =~ /^GPUSC-L/);
		$untested=1 if ($model =~ /^GPUU/);
	}
	if ($model =~ /PowerLite-/) {
		$bannermore=$model;
		$bannermore=~s/PowerLite-//g;
	}
	$model_checked=1;
}

sub check_banner {
	&pdebug("in check_banner, banner=$banner, ultra=$ultra");
	$ultra="ultra" if ($ultra eq 0 && ($banner =~ /Ultra|Blade|Fire/));
	$ultra="sparc64" if ($banner =~ /SPARC64/);
	$ultra=5 if ($banner =~ /Ultra 5\b/);
	$ultra="5_10" if ($banner =~ /Ultra 5\/10\b/);
	$ultra=10 if ($banner =~ /Ultra 10\b/);
	$ultra="220R" if ($banner =~ /Enterprise 220R\b/);
	$ultra=80 if ($banner =~ /Ultra 80\b/);
	# E410 is prototype name of E420R, but may still be in the
	# banner as "Sun Ultra 80/Enterprise 410 UPA/PCI"
	$ultra="420R" if ($banner =~ /Enterprise 410\b/);
	$ultra="420R" if ($banner =~ /Enterprise 420R\b/);
	$ultra="Netra t140x" if ($banner =~ /Netra t 1400\/1405\b/);
	$ultra="CP1400" if ($banner =~ /Ultra CP 1400\b/);
	$ultra="CP1500" if ($banner =~ /Ultra CP 1500\b/);
	$ultra="CP2000" if ($banner =~ /\bCP2000\b/);
	$ultra="CP2040" if ($banner =~ /\bCP2000 model 40\b/);
	$ultra="CP2060" if ($banner =~ /\bCP2000 model 60\b/);
	$ultra="CP2080" if ($banner =~ /\bCP2000 model 80\b/);
	$ultra="CP2140" if ($banner =~ /\bCP2000 model 140\b/);
	$ultra="CP2160" if ($banner =~ /\bCP2000 model 160\b/);
	$ultra="Sun Blade 1000" if ($banner =~ /Sun Excalibur\b/); # prototype
	$ultra="Sun Blade 2000" if ($banner =~ /Sun Blade 2000\b/);
	$ultra="Netra ct400" if ($banner =~ /Netra ct400\b/);
	$ultra="Netra ct410" if ($banner =~ /Netra ct410\b/);
	$ultra="Netra ct800" if ($banner =~ /Netra ct800\b/);
	$ultra="Netra ct810" if ($banner =~ /Netra ct810\b/);
	$ultra="Sun Blade 150" if ($banner =~ /Sun Blade 150\b/);
	# Sun Fire 12K, E25K, etc. systems identifies itself as Sun Fire 15K
	$ultra="Sun Fire 12K" if ($banner =~ /Sun Fire (12000|12K)\b/);
	if ($banner =~ /Ultra 4FT\b/) {
		$ultra="Netra ft1800";
		$bannermore="(Netra ft1800)";
		$modelmore="(Netra ft1800)";
	}
	# UltraSPARC-IIIi (Jalapeno) systems
	$ultra="Sun Ultra 45 Workstation" if ($banner =~ /Sun Ultra 45 Workstation\b/);
	$ultra="Sun Ultra 25 Workstation" if ($banner =~ /Sun Ultra 25 Workstation\b/);
	# UltraSPARC-IV (Jaguar) or UltraSPARC-IV+ (Panther) systems
	$ultra="Sun Fire E2900" if ($banner =~ /Sun Fire E2900\b/);
	$ultra="Sun Fire E4900" if ($banner =~ /Sun Fire E4900\b/);
	$ultra="Sun Fire E6900" if ($banner =~ /Sun Fire E6900\b/);
	$ultra="Sun Fire E20K" if ($banner =~ /Sun Fire E20K\b/);
	$ultra="Sun Fire E25K" if ($banner =~ /Sun Fire E25K\b/);
	# SPARC64-VI or SPARC64-VII systems
	$ultra=$banner if ($banner =~ /SPARC Enterprise M[34589]000 Server/);
	# Clones
	if ($banner =~ /\bMP-250[(\b]/) {
		$ultra="axus250";
		$bannermore="Ultra-250";
		$modelmore="(Ultra-250)";
	}
	$manufacturer="Sun Microsystems, Inc." if ($banner =~ /Sun |Netra /);
	$manufacturer="AXUS" if ($ultra =~ /\baxus\b/);
	$manufacturer="Rave" if ($banner =~ /Axil/);
	$manufacturer="Tadpole/Cycle" if ($banner =~ /Cycle|\bUP-20\b|\b520IIi\b/);
	$manufacturer="Tadpole" if ($banner =~ /Tadpole|\bRDI\b|\bVoyagerIIi\b|\bSPARCLE\b/);
	$manufacturer="Tatung" if ($banner =~ /COMPstation/);
	$manufacturer="Twinhead" if ($banner =~ /TWINstation/);
	$manufacturer="Fujitsu" if ($banner =~ /Fujitsu/);
	$manufacturer="Fujitsu Siemens" if ($banner =~ /Fujitsu Siemens/);
	$manufacturer="Fujitsu Siemens Computers" if ($banner =~ /Fujitsu Siemens Computers/);
}

sub check_for_prtdiag {
	return if (! $prtdiag_exec && ! $filename);
	return if ($have_prtdiag_data);
	&find_helpers;
	# Check for LDOMs
	if ($ldm_cmd && ! $have_ldm_data) {
		# Warn that ldm and prtdiag may take a while to run
		&please_wait;
		@ldm=&run("$ldm_cmd list-devices -a -p");
		$have_ldm_data=1;
		foreach $line (@ldm) {
			$line=&dos2unix($line);
			$line=&mychomp($line);
			&check_LDOM;
		}
	}
	@prtdiag=&run("$prtdiag_exec") if (! $filename);
	$have_prtdiag_data=1;
	foreach $line (@prtdiag) {
		$line=&dos2unix($line);
		# Some Solaris prtdiag outputs have malformed header, so
		# handle them also.
		if ($line =~ /^System Configuration: +|.BIOS Configuration: |Sun Microsystems .*Fire *X|Sun Microsystems *X|Sun Microsystems .*Blade *X|Sun Microsystems .*Memory size: |^Oracle Corporation/i || ($line =~ /Sun Microsystems .*Ultra / && $machine eq "i86pc")) {
			$line=&mychomp($line);
			$tmp=$line;
			$line=~s/System Configuration: +//g;
			$line=~s/BIOS Configuration: .*//g;
			if ($line =~ /^Sun Microsystems/i) {
				$manufacturer="Sun Microsystems, Inc." if ($line !~ / i86pc$/);
				if ($tmp =~ /System Configuration: *W[12]00z/ && ! $model && $machine eq "i86pc") {
					$diagbanner=$line;
					$diagbanner=~s/^.* Inc\. *(.*)/$1/;
				}
			} elsif ($line =~ /^Oracle /i) {
				$manufacturer="Oracle Corporation" if ($line !~ / i86pc$/);
			} elsif ($line =~ /Inc\./i) {
				$manufacturer=$line;
				$manufacturer=~s/^(.* Inc\.).*/$1/i;
				if ($tmp !~ /BIOS Configuration: / && ! $model && $machine eq "i86pc") {
					$diagbanner=$line;
					$diagbanner=~s/^.* Inc\. *(.*)/$1/;
				}
			} elsif ($line =~ /Corporation/i) {
				$manufacturer=$line;
				$manufacturer=~s/^(.* Corporation).*/$1/i;
				if ($tmp !~ /BIOS Configuration: / && ! $model && $machine eq "i86pc") {
					$diagbanner=$line;
					$diagbanner=~s/^.* Corporation *(.*)/$1/;
				}
			} elsif ($line !~ /(To Be Filled|System Manufacturer)/i) {
				$manufacturer=$line;
				$manufacturer=~s/^(\w+)[ \/].*/$1/;
			}
			foreach $tmp ("Sun Microsystems, Inc.","Sun Microsystems","Oracle Corporation") {
				if ($line =~ /^$tmp +sun\w+ +/) {
					$diagbanner=$line;
					$diagbanner=~s/$tmp +sun\w+ +//g;
					$diagbanner=~s/Memory size: .*$//g;
				} elsif ($line =~ /^$tmp *Sun +/i) {
					$diagbanner=$line;
					$diagbanner=~s/$tmp *Sun/Sun/ig;
					$diagbanner=~s/Memory size: .*$//g;
					$diagbanner=~s/ BLADE / Blade /g;
					$diagbanner=~s/ FIRE / Fire /g;
					$diagbanner=~s/ SERVER\b/ Server /g;
					$diagbanner=~s/ MODULE*\b/ Module /g;
					$diagbanner=~s/  */ /g;
				} elsif ($line =~ /^$tmp.*Ultra/i) {
					$diagbanner=$line;
					$diagbanner=~s/$tmp.*Ultra/Ultra/ig;
					$diagbanner=~s/Memory size: .*$//g;
				} elsif ($line =~ /^$tmp *W[12]100z/i) {
					$diagbanner=$line;
					$diagbanner=~s/$tmp *//ig;
				}
				$diagbanner=~s/\s+$//;
			}
		}
		$prtdiag_failed=1 if ($line =~ /Prtdiag Failed/i);
		# prtdiag only works on the global zone, so find out
		# if we are in a Solaris zone. solaris8 brand container shows
		# kernel version of "Generic_Virtual"
		$prtdiag_failed=2 if ($line =~ /prtdiag can only be run in the global /i || $kernver eq "Generic_Virtual");
	}
	if ($psrinfo_cmd && ! $have_psrinfo_data) {
		@psrinfo=&run("$psrinfo_cmd -v");
		$tmp=&mychomp(`$psrinfo_cmd -p 2>/dev/null`);	# physical CPUs
		if ($tmp) {
			push(@psrinfo, "#psrinfo -p\n$tmp\n");
			$tmp=&mychomp(`$psrinfo_cmd -p -v 2>/dev/null`);
			push(@psrinfo, "#psrinfo -p -v\n$tmp\n");
		}
		$have_psrinfo_data=1;
	}
	if ($ipmitool_cmd && ! $have_ipmitool_data) {
		@ipmitool=&run("$ipmitool_cmd fru");
		$have_ipmitool_data=1;
	}
	if ($smbios_cmd && ! $have_smbios_data) {
		@smbios=&run("$smbios_cmd");
		$have_smbios_data=1;
	}
	if ($kstat_cmd && ! $have_kstat_data) {
		@kstat=&run("$kstat_cmd");
		$have_kstat_data=1;
	}
	if (! $filename && $verbose == 3) {
		# Only run the following commands if E-mailing maintainer since
		# this data is used by memconf only for some systems
		if ($prtpicl_cmd && ! $have_prtpicl_data) {
			@prtpicl=&run("$prtpicl_cmd -v");
			$have_prtpicl_data=1;
		}
		if ($virtinfo_cmd && ! $have_virtinfo_data) {
			@virtinfo=&run("$virtinfo_cmd -pa");
			$have_virtinfo_data=1;
		}
		if ($cfgadm_cmd && ! $have_cfgadm_data) {
			@cfgadm=&run("$cfgadm_cmd -al");
			$have_cfgadm_data=1;
		}
		if ($ldm_cmd && ! $have_ldm_data) {
			@ldm=&run("$ldm_cmd list-devices -a -p");
			$have_ldm_data=1;
		}
	}
}

sub add_to_sockets_used {
	$_=shift;
	# strip leading slash for matching
	$_=~s/^\///;
	if ($sockets_used !~ /$_/) {
		$sockets_used .= "," if ($sockets_used && /\s/);
		$sockets_used .= " $_";
#		&pdebug("in add_to_sockets_used, added $_");
	}
}

sub add_to_sockets_empty {
	$_=shift;
	$sockets_empty .= "," if ($sockets_empty && /\s/);
	$sockets_empty .= " $_";
}

sub check_prtdiag {
	return if ($prtdiag_checked);
	&pdebug("in check_prtdiag");
	$prtdiag_checked=1;
	return if (! $prtdiag_exec && ! $filename);
	&check_for_prtdiag;
	if ($diagbanner =~ /W1100z\b/i) {
		$model=$diagbanner if ($model eq "i86pc");
	}
	$flag_cpu=0;
	$flag_mem=0;
	$build_socketstr=0;
	foreach $line (@prtdiag) {
		$line=&dos2unix($line);
		if ($line =~ /====|\/ \(picl,|<?xml/) {
			$flag_cpu=0;	# End of CPU section
			$flag_mem=0;	# End of memory section
		}
		if ($line =~ /Memory Units: Group Size/) {
			# Start of CPU and memory section on SS1000/SC2000
			$flag_cpu=1;
			$flag_mem=1;
		}
		$line="Memory $line" if ($line =~ /^Segment Table:/);
		# Ignore FLASH (System ROM)
		if ($flag_mem && $line !~ /^(\s*\n$|FLASH\b)/i) {
			$boardfound_mem=1;
			$boardfound_mem=0 if ($line =~ /Cannot find/);
			$memfrom="prtdiag" if ($boardfound_mem);
			@linearr=split(' ', $line);
			if ($linearr[0] =~ /^0x/ && $ultra =~ /Sun Blade 1[05]0\b/ && ($linearr[$#linearr] eq "chassis/system-board" || $linearr[$#linearr] eq "-")) {
				# Sometimes socket is unlabeled on prtdiag
				# output on Sun Blade 100/150
				$socket=$socketstr[0] if ($linearr[0] =~ /^0x0/);
				if ($simmrangex eq "00000400") {
					$socket=$socketstr[1] if ($linearr[0] =~ /^0x4/);
					$socket=$socketstr[2] if ($linearr[0] =~ /^0x8/);
					$socket=$socketstr[3] if ($linearr[0] =~ /^0xc/);
				} else {
					$socket=$socketstr[1] if ($linearr[0] =~ /^0x2/);
					$socket=$socketstr[2] if ($linearr[0] =~ /^0x4/);
					$socket=$socketstr[3] if ($linearr[0] =~ /^0x6/);
				}
				if ($linearr[$#linearr] eq "-") {
					$line=~s/-$/$socket/g;
					$linearr[$#linearr]=$socket;
				} else {
					$line=~s/-board/-board\/$socket/g;
					$linearr[$#linearr]="chassis/system-board/$socket";
				}
			}

			if ($model =~ /W1100z\b/i && $model !~ /2100z\b/i && $line =~ /DIMM[5-8]/) {
				# DIMM5-DIMM8 don't exist on W1100z
			} else {
				push(@boards_mem, "$line");
			}
			$flag_rewrite_prtdiag_mem=1 if ($line =~ /^MB\/CMP[0-3]\/BR[0-3]\/CH[01]\/D[01]/);
			if ($#linearr >= 2) {
				if ($linearr[2] =~ /\bU\d\d\d\d\b/) {
					# Sun Ultra-250 format
					$sockets_used .= " $linearr[2]";
				} elsif ($linearr[2] =~ /\b\d\d\d\d\b/) {
					# Sun Ultra-4 format
					$sockets_used .= " U$linearr[2]";
				}
			}
			if ($#linearr >= 3) {
				if ($linearr[3] ne "BankIDs" && $linearr[3] ne "GroupID" && $line !~ /^0x\d[\d ]+\d.+ +\d +-$/) {
					if ($linearr[1] =~ /\b\d+MB\b/) {
						# Sun Blade 100/1000 format
						$simmsize=$linearr[1];
						$simmsize=~s/MB//g;
						push(@simmsizesfound, "$simmsize");
					} elsif ($linearr[1] =~ /\b\d+GB\b/) {
						# Sun Blade 1000 format
						$simmsize=$linearr[1];
						$simmsize=~s/GB//g;
						$simmsize *= 1024;
						push(@simmsizesfound, "$simmsize");
					}
				}
				if ($model eq "Ultra-250" || $ultra eq 250 || $model eq "Ultra-4" || $ultra eq 450 || $model eq "Ultra-4FT" || $ultra eq "Netra ft1800") {
					if ($linearr[3] =~ /\b\d+\b/) {
						$simmsize=$linearr[3];
						push(@simmsizesfound, "$simmsize");
					}
				}
			}
			if ($#linearr >= 2) {
				if ($linearr[$#linearr] =~ /\bDIMM\d/ && $linearr[$#linearr - 1] =~ /\bCPU\d/) {
					$socket="$linearr[$#linearr - 1]_$linearr[$#linearr]";
					&add_to_sockets_used("$socket") if ($linearr[1] ne "empty");
					$build_socketstr=1 if ($#socketstr == 0);
					push(@socketstr, ("$socket")) if ($build_socketstr);
				} elsif ($linearr[$#linearr - 2] =~ /\bDIMM\d|_DIMM\d/ && $linearr[$#linearr - 1] =~ /\bBank\b/i) {
					# Ultra40 and JavaWorkstation
					$socket="$linearr[$#linearr - 2] $linearr[$#linearr - 1] $linearr[$#linearr]";
					&add_to_sockets_used("$socket") if ($linearr[1] ne "empty");
					$build_socketstr=1 if ($#socketstr == 0);
					push(@socketstr, ("$socket")) if ($build_socketstr);
				} elsif ($linearr[$#linearr] =~ /\b(DIMM\d|[UJ]\d\d\d\d[\b,])/ || ($linearr[$#linearr - 1] eq "Label" && $linearr[$#linearr] eq "-")) {
					$sockets_used .= " $linearr[$#linearr]";
					# May be multiple sockets separated by ","
					$sockets_used=~s/,/ /g;
				} elsif ($linearr[2] =~ /MB\/P[01]\/B[01]\/D[01]|C[0-3]\/P[01]\/B[01]\/D[01]/) {
					$sockets_used .= " $linearr[2]";
					# May be multiple sockets separated by ","
					$sockets_used=~s/,/ /g;
				}
			}
			if ($linearr[0] !~ /^0x/ && ($linearr[$#linearr] eq "-" || $linearr[$#linearr] =~ /^-,/)) {
				# unlabeled sockets
				$sockets_used .= " $linearr[$#linearr]";
				# May be multiple sockets separated by ","
				$sockets_used=~s/,/ /g;
			}
			if ($linearr[$#linearr] =~ /\/J\d\d\d\d$/) {
				$linearr[$#linearr]=~s/.+\///g;
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($ultra eq "Sun Fire 280R") {
				if ($line =~ / CA +0 +[0-3] .+4-way/) {
					$sockets_used="J0100 J0202 J0304 J0406 J0101 J0203 J0305 J0407";
				} elsif ($line =~ / CA +0 +[02] /) {
					$sockets_used .= " J0100 J0202 J0304 J0406" if ($sockets_used !~ / J0100 /);
				} elsif ($line =~ / CA +[01] +[13] /) {
					$sockets_used .= " J0101 J0203 J0305 J0407" if ($sockets_used !~ / J0101 /);
				}
			}
			# Memory on Sun Fire systems
			if ($line =~ /^\/N\d\/SB\d\/P\d\/B\d\b/) {
				$boardslot_mem=substr($line,0,13);
				push(@boardslot_mems, "$boardslot_mem");
				$boardslot_mems .= $boardslot_mem . " ";
			} elsif ($line =~ /^\/N\d\/SB\d\d\/P\d\/B\d\b/) {
				$boardslot_mem=substr($line,0,14);
				push(@boardslot_mems, "$boardslot_mem");
				$boardslot_mems .= $boardslot_mem . " ";
			} elsif ($line =~ /^\/SB\d\d\/P\d\/B\d\b/) {
				$boardslot_mem=substr($line,0,11);
				push(@boardslot_mems, "$boardslot_mem");
				$boardslot_mems .= $boardslot_mem . " ";
			} elsif ($line =~ /\bSB\d\/P\d\/B\d\/D\d\b,/) {
				$boardslot_mem=substr($line,24,51);
				push(@boardslot_mems, "$boardslot_mem");
				$boardslot_mems .= $boardslot_mem . " ";
			} elsif ($line =~ /\bSB\d\/P\d\/B\d\/D\d\b/) {
				$boardslot_mem=substr($line,24,12);
				push(@boardslot_mems, "$boardslot_mem");
				$boardslot_mems .= $boardslot_mem . " ";
			}
			if ($ultra =~ /Sun Fire/ && $#linearr >= 5) {
				if ($linearr[5] =~ /\d+MB/) {
					$simmsize=$linearr[5];
					$simmsize=~s/MB//g;
					push(@simmsizesfound, "$simmsize");
				}
			}
			if ($ultra =~ /Sun Fire V[48][89]0\b/) {
				# Fire V480, V490, V880, V890
				$bankname="groups";
				if ($banks_used ne "A0 A1 B0 B1") {
					$banks_used="A0 B0" if ($line =~ /^  ?[ABCD] .+ 4-way /);
					$banks_used="A0 A1 B0 B1" if ($line =~ /^  ?[ABCD] .+ 8-way /);
				}
			}
			if ($linearr[$#linearr] =~ /MB\/CMP0\/CH[0-3]\/R[01]\/D[01]/) {
				# UltraSPARC-T1 systems
				if ($#linearr >= 5) {
					if ($linearr[5] eq "MB") {
						$simmsize=$linearr[4];
						$simmsize=~s/MB//g;
						$simmsize /= 2;
						push(@simmsizesfound, "$simmsize");
					} elsif ($linearr[5] eq "GB") {
						$simmsize=$linearr[4];
						$simmsize=~s/GB//g;
						$simmsize *= 512;
						push(@simmsizesfound, "$simmsize");
					}
					if ($linearr[2] eq "MB") {
						$prtdiag_memory += $linearr[1];
					} elsif ($linearr[2] eq "GB") {
						$prtdiag_memory += $linearr[1] * 1024;
					}
				$installed_memory=$prtdiag_memory if ($prtdiag_memory);
				}
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /MB\/CMP[0-3]\/BR[0-3]\/CH[01]\/D[01]|MB\/CMP[0-3]\/MR[01]\/BR[01]\/CH[01]\/D[23]/) {
				# UltraSPARC-T2 systems: T5120, T5220, T6320
				# UltraSPARC-T2+ systems: T5140, T5240, T5440
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /MB\/CPU[0-3]\/CMP[0-3]\/BR[01]\/CH[01]\/D[01]|MB\/MEM[0-3]\/CMP[0-3]\/BR[01]\/CH[01]\/D[01]/) {
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /MB\/CMP[01]\/BOB[0-3]\/CH[01]\/D[01]/) {
				# SPARC T3-1, T3-1B, T4-1 or T4-1B
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /MB\/CMP[01]\/MR[01]\/BOB[01]\/CH[01]\/D[01]/) {
				# SPARC T3-2, T4-2
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /PM[01]\/CMP[01]\/BOB[0-3]\/CH[01]\/D[01]/) {
				# SPARC T3-4, T4-4
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /SYS\/MB\/CM[01]\/CMP\/MR[0-3]\/BOB[01]\/CH[01]\/D[01]/) {
				# SPARC T5-2
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /SYS\/PM[0-3]\/CM[01]\/CMP\/BOB[0-7]\/CH[01]\/D[01]/) {
				# SPARC T5-4, T5-8
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /SYS\/MB\/CM0\/CMP\/BOB[0-7]\/CH[01]\/D[01]/) {
				# SPARC T5-1B
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /SYS\/CMU\d+\/CMP\d+\/D\d+/) {
				# SPARC M5-32, M6-32
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /SYS\/MBU\/CMP0\/MEM[01][0-3][AB]/) {
				# Fujitsu SPARC M10-1
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /BB\d+\/CMU[LU]\/CMP[01]\/MEM[01][0-7][AB]/) {
				# Fujitsu SPARC M10-4, M10-4S (guess)
				$sockets_used .= " $linearr[$#linearr]";
			}
			if ($linearr[$#linearr] =~ /SYS\/MB\/CMP\d+\/MCU\d+\/CH\d+\/D\d+/) {
				# SPARC S7-2, S7-2L
				$sockets_used .= " $linearr[$#linearr]";
			}
		}
		if ($line =~ /CPU Units:/) {
			$flag_cpu=1;	# Start of CPU section
			$flag_mem=0;	# End of memory section
			$format_cpu=1;
		}
		if ($line =~ /==== (CPU|Processor Sockets |Virtual CPU)/) {
			$flag_cpu=1;	# Start of CPU section
			$flag_mem=0;	# End of memory section
			$format_cpu=2;
		}
		if ($line =~ /Memory Units:|==== Memory |==== Physical Memory |Used Memory:/) {
			$flag_cpu=0;	# End of CPU section
			$flag_mem=1;	# Start of memory section
		}
		if ($line =~ /CPU Units:/ && $line =~ /Memory Units:/) {
			$flag_cpu=1;	# Start of CPU section
			$flag_mem=1;	# Start of memory section
		}
		if ($flag_cpu && $line !~ /^\s*\n$/) {
			if ($model eq "Ultra-5_10" || $ultra eq "5_10" || $ultra eq 5 || $ultra eq 10) {
				$newline=$line;
				$newline=~s/^       //g if ($line !~ /Run   Ecache   CPU    CPU/);
				push(@boards_cpu, "$newline");
			} else {
				push(@boards_cpu, "$line");
			}
			$boardfound_cpu=1;
			&checkX86;
			if ($flag_cpu == 2 && $isX86) {
				# Solaris x86 CPU type found in prtdiag
				$cputype2=&mychomp($line);
				# Remove multiple spaces before some Xeon models
				$cputype2=~s/\s\s+([ELWX][3-9])/ $1/;
				$cputype2=~s/\s\s+.*//;
				$cputype2=~s/(^.* Processor \d+) .*/$1/;
				$cputype2=&cleanup_cputype($cputype2);
				&x86multicorecnt($cputype2);
				# rewrite %cpucnt $cputype2
				$cfreq=0;
				while (($cf,$cnt)=each(%cpucnt)) {
					$cf=~/^(.*) (\d+)$/;
					if (defined($2)) {
						$cfreq=$2;
						delete $cpucnt{"$1 $2"};
					} else {
						delete $cpucnt{"$cf"};
					}
				}
				$ndcpu++;
				if ($cpucntfrom ne "psrinfo") {
					$cpucntfrom="prtdiag";
					$cpucntflag=1;
					$ncpu++ if ($filename);
				}
				$cputype=$cputype2 if ($cputype2);
				$cputype=$cputype_prtconf if (($cputype eq "AMD" || $cputype eq "Opteron") && $cputype_prtconf);
				$cputype=$cputype_psrinfo if ($cputype_psrinfo);
				$cpucnt{"$cputype $cfreq"}=$ncpu;
			}
			# CPUs on Sun Fire systems
			if ($line =~ /^\/N\d\/SB\d\/P\d\b/) {
				$boardslot_cpu=substr($line,0,10);
				push(@boardslot_cpus, "$boardslot_cpu");
				$boardslot_cpus .= $boardslot_cpu . " ";
			} elsif ($line =~ /^\/N\d\/SB\d\d\/P\d\b/) {
				$boardslot_cpu=substr($line,0,11);
				push(@boardslot_cpus, "$boardslot_cpu");
				$boardslot_cpus .= $boardslot_cpu . " ";
			} elsif ($line =~ /^\/SB\d\d\/P\d\b/) {
				$boardslot_cpu=substr($line,0,8);
				push(@boardslot_cpus, "$boardslot_cpu");
				$boardslot_cpus .= $boardslot_cpu . " ";
				&prtdiag_threadcount(1);
			} elsif ($line =~ /^    SB\d\/P\d\b/) {
				$boardslot_cpu=substr($line,4,6);
				push(@boardslot_cpus, "$boardslot_cpu");
				$boardslot_cpus .= $boardslot_cpu . " ";
				# prtdiag does not show cpuid or cputype
			} elsif ($line =~ /    SB\d\/P\d$/) {
				$boardslot_cpu=substr($line,length($line)-7,6);
				push(@boardslot_cpus, "$boardslot_cpu");
				$boardslot_cpus .= $boardslot_cpu . " ";
				&prtdiag_threadcount(0);
			}
		}
		if ($flag_cpu && $line =~ /------/) {
			# Next lines are the CPUs on each system board
			$flag_cpu=2;
		}
		if ($flag_mem && $line =~ /------/) {
			# Next lines are the memory on each system board
			$flag_mem=2;
		}
		if ($filename && $use_psrinfo_data) {
			# May have "psrinfo -v" output in regression test file
			if ($line =~ /.+ operates at \d+ MHz/) {
				$cpufreq=&mychomp($line);
				$cpufreq=~s/.+ operates at //;
				$cpufreq=~s/ MHz.+//;
				$cpucntfrom="psrinfo" if ($cpucntfrom ne "ldm");
				$cpucntflag="0";	# reset flag
				$psrcpucnt++;
				# rewrite %cpucnt $cputype with frequency
				while (($cf,$cnt)=each(%cpucnt)) {
					$cf=~/^(.*) (\d+)$/;
					$tmp=$1;
					if (defined($tmp)) {
						delete $cpucnt{"$1 $2"} if ($2 == 0);
					}
				}
				if (defined($tmp)) {
					$cpucnt{"$tmp $cpufreq"}=$psrcpucnt;
					$ncpu=$psrcpucnt;
				}
			}
			# May have "psrinfo -p -v" output in regression test
			# file that has more detailed information about the
			# CPUs. Assumes all CPUs are same.
			$foundpsrinfocpu=1 if ($line =~ /.+ \d+ virtual processor/);
			if ($foundpsrinfocpu && (($line =~ /.+Hz$/ && $line !~ /Speed: / && $line !~ / PCI/) || $line =~ /\bAMD .* Processor /) && $line !~ / x86 /) {
				$cputype=&mychomp($line);
				$cputype=&cleanup_cputype($cputype);
				$cputype=~s/^Version:\s+//;
				$cputype=~s/^brand\s+//;
				$cputype=~s/^:brand-string\s+//;
				# rewrite %cpucnt $cputype with cputype
				while (($cf,$cnt)=each(%cpucnt)) {
					$cf=~/^(.*) (\d+)$/;
					$cpufreq=$2;
					delete $cpucnt{"$1 $2"};
				}
				$cpucnt{"$cputype $cpufreq"}=$psrcpucnt;
			}
		}
		if ($filename && $filename !~ /Sun/ && $line =~ /^ *Manufacturer:/ && $manufacturer =~ /^Sun\b/ && $diagbanner !~ /^Sun\b|^Ultra/) {
			# Regression test file with smbios output
			$manufacturer=&mychomp($line);
			$manufacturer=~s/^.*Manufacturer: *//;
			$manufacturer=~s/\s*$//g;
			&pdebug("in check_prtdiag, smbios manufacturer=$manufacturer");
		}
	}

	# Rewrite prtdiag output to include DIMM information on SB1X00, SB2X00,
	# Enchilada, Chalupa (Sun Fire V440), Netra T12, Seattle and Boston
	# systems
	@new_boards_mem="";
	$grpcnt=0;
	$intcnt=0;
	if ($ultra =~ /Sun Blade [12][05]00\b/ || $ultra eq "Sun Fire 280R" || $ultra eq "Netra 20" || $ultra eq "Sun Fire V250" || $ultra eq "Netra T12") {
		foreach $line (@boards_mem) {
			$line=&mychomp($line);
			$newline=$line;
			if ($line eq "-----------------------------------------------------------" && ! $prtdiag_banktable_has_dimms) {
				$newline=$line . "------";
			} elsif ($line eq "--------------------------------------------------") {
				$newline=$line . "-----------";
			} elsif ($line =~ /ControllerID  GroupID   Size/ && ! $prtdiag_banktable_has_dimms) {
				$newline="ID       ControllerID  GroupID   Size    DIMMs    Interleave Way";
			} elsif ($line =~ /ControllerID   GroupID  Labels         Status/) {
				$newline=$line . "       DIMMs";
			} elsif ($line =~ /ControllerID   GroupID  Labels/) {
				$newline=$line . "                      DIMMs";
			} elsif ($line =~ /ControllerID   GroupID  Size       Labels/) {
				$newline=$line . "          DIMMs";
			} elsif ($line =~ /^\d[\d ]       \d[\d ]            \d /) {
				&read_prtdiag_bank_table;
			} elsif ($line =~ /^0x\d[\d ]+\d.+ +\d +-$|  GroupID \d[\d ]$/) {
				&read_prtdiag_memory_segment_table;
			} elsif ($line =~ /J0100,/) {
				$sz=$grpsize{0,0};
				if (defined($sz)) {
					$sz=~s/ //g;
					$newline=$line . "     4x$sz";
				}
			} elsif ($line =~ /J0101,/) {
				$sz=$grpsize{0,1};
				if (defined($sz)) {
					$sz=~s/ //g;
					$newline=$line . "     4x$sz";
				}
			} elsif ($line =~ /\/J0[1-4]0[0246]\b/) {
				$sz=$grpsize{0,0};
				if (defined($sz)) {
					$sz=~s/ //g;
					$newline=$line . "  $sz";
				}
			} elsif ($line =~ /\/J0[1-4]0[1357]\b/) {
				$sz=$grpsize{0,1};
				if (defined($sz)) {
					$sz=~s/ //g;
					$newline=$line . "  $sz";
				}
			} elsif ($line =~ /\bSB\d\/P\d\/B\d\/D\d,/) {
				$tmp=substr($line,0,2);
				$tmp=~s/ //g;
				$sz=$grpsize{$tmp,substr($line,15,1)};
				$sz=$grpsize{0,substr($line,15,1)} if (! defined($sz));
				if (defined($sz)) {
					$sz=~s/ //g;
					$newline=$line . "         4x$sz";
				}
			} elsif ($line =~ /\bSB\d\/P\d\/B\d\/D\d\b/) {
				$tmp=substr($line,0,2);
				$tmp=~s/ //g;
				$sz=$grpsize{$tmp,substr($line,15,1)};
				$sz=$grpsize{0,substr($line,15,1)} if (! defined($sz));
				if (defined($sz)) {
					$sz=~s/ //g;
					$newline=$line . "         $sz";
				}
			} elsif ($line =~ / MB\/DIMM\d,/) {
				$sz=$grpsize{0,substr($line,15,1)};
				$newline=$line . "           2x$sz" if (defined($sz));
			} elsif ($line =~ /DIMM\d,DIMM\d/) {
				@linearr=split(' ', $line);
				if ($linearr[2] =~ /\d+[MG]B/) {
					$sz=$linearr[2];
					if ($sz =~ /\dGB/) {
						$sz=~s/GB//g;
						$sz *= 512;
					} else {
						$sz=~s/MB//g;
						$sz /= 2;
					}
					$sz=&show_memory_label($sz);
				}
				$newline=$line . "     2x$sz" if (defined($sz));
				if ($line =~ /DIMM[13],DIMM[24]/ && $ultra eq "Sun Blade 1500") {
					# prototype has sockets DIMM1-DIMM4
					@socketstr=("DIMM1".."DIMM4");
				}
				if ($line =~ /DIMM[1357],DIMM[2468]/ && $ultra eq "Sun Blade 2500") {
					# prototype has sockets DIMM1-DIMM8
					if ($line =~ /DIMM[13],DIMM[24]/) {
						@socketstr=("DIMM1".."DIMM4");
					} elsif ($line =~ /DIMM[57],DIMM[68]/) {
						push(@socketstr, "DIMM5".."DIMM8");
					}
				}
			}
			push(@new_boards_mem, "$newline\n") if ($newline);
		}
		@boards_mem=@new_boards_mem;
		$memfrom="prtdiag";
	} elsif ($ultra eq "Enchilada" || $ultra eq "Sun Fire V440" || $ultra eq "Netra 440" || $ultra =~ /Sun Ultra [24]5 .*Workstation/ || $ultra eq "Sun Fire V125" || $ultra eq "Seattle" || $ultra eq "Boston" || $banner =~ /Sun Fire E[24]900\b/ || $diagbanner =~ /Sun Fire E[24]900/) {
		foreach $line (@boards_mem) {
			$line=&mychomp($line);
			$newline=$line;
			if ($line eq "-----------------------------------------------------------" && ! $prtdiag_banktable_has_dimms) {
				$newline=$line . "------";
			} elsif ($line eq "--------------------------------------------------") {
				$newline=$line . "-----------";
			} elsif ($line =~ /ControllerID  GroupID   Size/ && ! $prtdiag_banktable_has_dimms) {
				$newline="ID       ControllerID  GroupID   Size    DIMMs    Interleave Way";
			} elsif ($line =~ /ControllerID   GroupID  Labels         Status/) {
				$newline=$line . "           DIMMs";
			} elsif ($line =~ /ControllerID   GroupID  Labels/) {
				$newline=$line . "                      DIMMs";
			} elsif ($line =~ /^\d[\d ]       \d[\d ]            \d /) {
				&read_prtdiag_bank_table;
			} elsif ($line =~ /^0x\d[\d ]+\d.+ +\d +-$|  GroupID \d[\d ]$/) {
				&read_prtdiag_memory_segment_table;
			} elsif ($line =~ / MB\/P[01]\/B[01]\/D[01],|C[0-3]\/P[01]\/B[01]\/D[01],/) {
				$sz=$grpsize{substr($line,0,1),substr($line,15,1)};
				$sz=$grpsize{0,substr($line,15,1)} if (! defined($sz));
				if (defined($sz)) {
					$newline=$line . "     2x$sz";
				} else {
					$newline=$line . "     Failing";
					$failing_memory=1;
				}
			} elsif ($line =~ / MB\/P[01]\/B[01]\/D[01]\b|C[0-3]\/P[01]\/B[01]\/D[01]\b/) {
				$sz=$grpsize{substr($line,0,1),substr($line,15,1)};
				$sz=$grpsize{0,substr($line,15,1)} if (! defined($sz));
				if (defined($sz)) {
					$sz=~s/ //g;
					$sz=&show_memory_label($sz);
				}
				$space="    ";
				$space="" if ($line =~ / okay/);
				if ($line =~ / failed/) {
					if (defined($sz)) {
						$failed_memory += $sz;
					} else {
						$failing_memory=1;
					}
				}
				if (defined($sz)) {
					# If interleave factor is 16, then print 4x$sz
					if (defined($grpinterleave{substr($line,28,1),0})) {
						if ($grpinterleave{substr($line,28,1),0} eq "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15" && ! $prtdiag_banktable_has_dimms) {
							$newline=$line . "$space           4x$sz";
						} else {
							$newline=$line . "$space             $sz";
						}
					} else {
						$newline=$line . "$space             $sz";
					}
				}
			} elsif ($line =~ / MB\/DIMM[0-7]\b/) {
				$sz=$grpsize{substr($line,0,1),substr($line,15,1)};
				$sz=$grpsize{0,substr($line,15,1)} if (! defined($sz));
				$newline=$line . "                 $sz" if (defined($sz));
			} elsif ($line =~ /\bSB\d\/P\d\/B\d\/D\d,/) {
				$tmp=substr($line,0,2);
				$tmp=~s/ //g;
				$sz=$grpsize{$tmp,substr($line,15,1)};
				$sz=$grpsize{0,substr($line,15,1)} if (! defined($sz));
				if (defined($sz)) {
					$sz=~s/ //g;
					$newline=$line . "             4x$sz";
				}
			} elsif ($line =~ /\bSB\d\/P\d\/B\d\/D\d\b/) {
				$tmp=substr($line,0,2);
				$tmp=~s/ //g;
				$sz=$grpsize{$tmp,substr($line,15,1)};
				$sz=$grpsize{0,substr($line,15,1)} if (! defined($sz));
				if (defined($sz)) {
					$sz=~s/ //g;
					$newline=$line . "             $sz";
				}
			}
			push(@new_boards_mem, "$newline\n") if ($newline);
		}
		@boards_mem=@new_boards_mem;
		$memfrom="prtdiag";
	}
	# Rewrite prtdiag output to exclude redundant labels
	@new_boards_mem="";
	$flag_group=0;
	foreach $line (@boards_mem) {
		$line=&mychomp($line);
		$newline=$line;
		$flag_group++ if ($line =~ /Memory Module Groups:/);
		if ($flag_group ge 2) {
			$newline="" if ($line =~ /Memory Module Groups:|--------------------------------------------------|ControllerID   GroupID/);
		}
		push(@new_boards_mem, "$newline\n") if ($newline);
	}
	if ($machine eq "sun4v" && $cputype !~ /UltraSPARC-T1$/) {
		if ($prtpicl_cmd && ! $have_prtpicl_data) {
			# Warn that prtpicl may take a while to run
			&please_wait;
			@prtpicl=&run("$prtpicl_cmd -v");
			$have_prtpicl_data=1;
		}
		&check_prtpicl if ($have_prtpicl_data);
		if ($picl_foundmemory) {
			@new_boards_mem="";
			$memfrom="prtpicl";
			$picl_bank_cnt=scalar(keys %picl_mem_bank);
			if (scalar(keys %picl_mem_dimm) == 1 || $picl_bank_cnt > 1) {
				while (($socket,$simmsize)=each(%picl_mem_bank)) {
					if (scalar(keys %picl_mem_pn) == $picl_bank_cnt * 2 || $interleave == 8) {
						# CH1 was not listed
						$simmsize /= 2;
						$picl_mem_dimm{"$socket"}=$simmsize;
						$socket=~s/CH0/CH1/g;
						$picl_mem_dimm{"$socket"}=$simmsize;
						&add_to_sockets_used($socket);
					} else {
						$picl_mem_dimm{"$socket"}=$simmsize;
					}
				}
			}
			while (($socket,$simmsize)=each(%picl_mem_dimm)) {
				$pn=$picl_mem_pn{"$socket"};
				$sz=&show_memory_label($simmsize);
				$newline="socket $socket has a ";
				$newline .= $pn . " " if (defined($pn));
				$newline .= $sz . " " if (defined($sz));
				$newline .= "$memtype";
				push(@new_boards_mem, "$newline\n");
				push(@simmsizesfound, $simmsize) if (defined($sz));
			}
			@new_boards_mem=sort alphanumerically @new_boards_mem;
		} elsif ($flag_rewrite_prtdiag_mem) {
			# Hack: Rewrite prtdiag output better than original
			if ($sockets_used =~ /MB\/CMP[0-3]\/BR[0-3]\/CH[01]\/D1/) {
				# All 16 DIMMs are installed
				@new_boards_mem="";
				if ($sockets_used !~ /MB\/CMP[0-3]\/BR[0-3]\/CH1\/D[01]/) {
					foreach $line (@boards_mem) {
						$line=&mychomp($line);
						$newline=$line;
						if ($line =~ /MB\/CMP[0-3]\/BR[0-3]\/CH0\/D[01]/) {
							$line=~s/\s+$//;
							$tmp=$line;
							$tmp=~s/^.*(MB\/CMP.*)/$1/;
							$tmp=~s/CH0/CH1/g;
							$space="";
							$space="                                       " if ($line =~ /^MB\/CMP/);
							$newline="$space$line,$tmp";
						}
						push(@new_boards_mem, "$newline\n") if ($newline);
					}
				}
				$sockets_used="";
				for ($cnt=0; $cnt <= $#socketstr; $cnt++) {
					$sockets_used .= " $socketstr[$cnt]";
				}
				$simmsize=$installed_memory / 16;
			} else {
				# 8-DIMMs or 4-DIMMs are installed.
				# Hack: assume 4-DIMM configuration since
				# 8-DIMM has prtpicl output.
				@new_boards_mem="";
				foreach $line (@boards_mem) {
					$line=&mychomp($line);
					$newline=$line;
					if ($line =~ /MB\/CMP[0-3]\/BR[0-3]\/CH0\/D[01]/) {
						$line=~s/\s+$//;
						$space="";
						$space="                                       " if ($line =~ /^MB\/CMP/);
						$newline="$space$line";
					}
					push(@new_boards_mem, "$newline\n") if ($newline);
				}
				$simmsize=$installed_memory / 4;
			}
			# Round up DIMM value
			$simmsize=&roundup_memory($simmsize);
			push(@simmsizesfound, $simmsize);
		} else {
			$tmp=0;
			foreach $socket (sort split(' ', $sockets_used)) {
				$tmp++;
			}
			if ($tmp) {
				# Round up DIMM value
				$simmsize=&roundup_memory($installed_memory / $tmp);
				push(@simmsizesfound, $simmsize);
			}
		}
	}
	@boards_mem=@new_boards_mem;
#	&pdebug("sockets_used=$sockets_used");
}

sub prtdiag_threadcount {
	$arg=shift;	# column with thread count
	$diagthreadcnt++;
	$tmp=$line;
	$tmp=~s/,\s+/,/;
	@linearr=split(' ', $tmp);
	$cputype=$linearr[4];
	$cputype=~s/SUNW,U/U/;
	$cpufreq=$linearr[1+$arg];
	if ($line =~ /\bUS-/) {
		$cputype=~s/US-/UltraSPARC-/;
		$cpufreq=$linearr[2];
	}
	$cputype=~s/UltraSPARC-IV/Dual-Core UltraSPARC-IV/;
	$diagcpucnt{"$cputype $cpufreq"}++;
	if ($linearr[$arg] =~ /,/) {
		$tmp=$linearr[$arg];
		@linearr=split(',', $tmp);
		$diagthreadcnt += $#linearr;
	}
	$cpucntfrom="prtdiag";
}

sub check_prtpicl {
	&pdebug("in check_prtpicl");
	$flag_mem_seg=0;
	$flag_mem_bank=0;
	$flag_mem_chan=0;
	$flag_mem_mod=0;
	$flag_physical_platform=0;
	$processorbrd="";
	$cpumembrd="";
	$mem_riser="";
	$mem_cu="";
	$picl_dimm_per_bank=0;
	$max_picl_dimm_per_bank=0;
	$has_picl_mem_mod=0;
	foreach $line (@prtpicl) {
		$line=&dos2unix($line);
		$line=&mychomp($line);
		$line=~s/\s+$//;
		if ($line =~ /^\s+:Label\s+PM[01]/) {
			# SPARC T3-4, T4-4
			$processorbrd=$line;
			$processorbrd=~s/^.*:Label\s+(.*)$/$1/;
		}
		if ($line =~ /^\s+:Label\s+CM[0-3]/) {
			# SPARC T5-2, T5-4, T5-8, T5-1B
			$cpumembrd=$line;
			$cpumembrd=~s/^.*:Label\s+(.*)$/$1/;
		}
		if ($line =~ /^\s+:Label\s+(CPU[0-3]|MEM[0-3])/) {
			$cpumembrd=$line;
			$cpumembrd=~s/^.*:Label\s+(.*)$/$1\//;
		}
		if ($line =~ /^\s+:Label\s+CMP[0-3]/) {
			$cmp=$line;
			$cmp=~s/^.*:Label\s+(.*)$/$1/;
		}
		if ($line =~ /\s+:name\s+memory-module/) {
			$flag_mem_mod=0;	# End of memory module section
			&add_to_sockets_used($mem_dimm);
		}
		if (($line =~ /^\s+\w.*/ && $line !~ /^\s+memory-/ && $has_picl_mem_mod) || ($line =~ /\s+:name\s/ && ! $has_picl_mem_mod)) {
			$flag_mem_seg=0;
			$max_picl_dimm_per_bank=$picl_dimm_per_bank if ($picl_dimm_per_bank);
			if ($flag_mem_mod && $mem_dimm !~ /\//) {
				if ($ultra eq "S7-2" || $ultra eq "S7-2L") {
					# SPARC S7-2, S7-2L (guess)
					$socket="/SYS/MB/$cpumembrd$cmp/$mem_cu/$mem_channel/$mem_dimm";
				} elsif ($ultra =~ /T5-(2|1B)/) {
					# SPARC T5-2, T5-1B (guess)
					$socket="/SYS/MB/$cpumembrd/CMP/$mem_branch/$mem_channel/$mem_dimm";
				} elsif ($ultra =~ /T5-(4|8)/) {
					# SPARC T5-4, T5-8 (guess)
					$socket="/SYS/$processorbrd/$cpumembrd/CMP/$mem_branch/$mem_channel/$mem_dimm";
				} elsif ($processorbrd) {
					# SPARC T3-4, T4-4
					$socket="/SYS/$processorbrd/$cpumembrd$cmp/$mem_branch/$mem_channel/$mem_dimm";
				} else {
					$socket="MB/$cpumembrd$cmp/$mem_branch/$mem_channel/$mem_dimm";
				}
				$flag_mem_mod=0;	# End of memory module section
				&add_to_sockets_used($socket);
				if (defined($mem_model) && defined($mem_mfg)) {
					$picl_mem_pn{"$socket"}="$mem_mfg $mem_model";
				} elsif (defined($mem_mfg)) {
					$picl_mem_pn{"$socket"}="$mem_mfg";
				}
				if ($max_picl_dimm_per_bank) {
					$picl_mem_dimm{"$socket"}=$picl_bank_size / $max_picl_dimm_per_bank;
					push(@simmsizesfound, "$picl_mem_dimm{\"$socket\"}");
				} elsif ($sockets_used =~ /\/CH1\//) {
					$picl_mem_dimm{"$socket"}+=$picl_bank_size / 2;
				} else {
					$picl_mem_dimm{"$socket"}+=$picl_bank_size;
				}
			} elsif ($flag_mem_bank) {
				$socket="$bank_nac" if ($bank_nac);
				$flag_mem_bank=0;	# End of memory bank section
				$bank_nac="";
				if ($socket) {
					&add_to_sockets_used($socket);
					$picl_mem_bank{"$socket"}=$picl_bank_size;
				}
			}
		}
		if ($line =~ /^\s+memory-segment\s/) {
			$flag_mem_seg=1;	# Start of memory segment section
		}
		if ($flag_mem_seg) {
			if ($line =~ /^\s+:InterleaveFactor\s/) {
				$interleave=$line;
				$interleave=~s/^.*:InterleaveFactor\s+(.*)$/$1/;
				$interleave=hex($interleave) if ($interleave =~ /^0x\d/);
			}
			if ($line =~ /^\s+:Size\s/) {
				$segment_size=$line;
				$segment_size=~s/^.*:Size\s+(.*)$/$1/;
				if ($segment_size =~ /^0x\d/) {
					$segment_size=~s/^(.*)00000$/$1/;
					$segment_size=hex($segment_size);
				} else {
					$segment_size /= $meg;
				}
			}
		}
		if ($line =~ /^\s+memory-bank\s/) {
			$flag_mem_bank=1;	# Start of memory bank section
			$picl_dimm_per_bank=0;
		}
		if ($flag_mem_bank) {
			if ($line =~ /^\s+:Label\s/) {
				$bank_label=$line;
				$bank_label=~s/^.*:Label\s+(.*)$/$1/;
			}
			if ($line =~ /^\s+:nac\s/) {
				$bank_nac=$line;
				$bank_nac=~s/^.*:nac\s+(.*)\s*$/$1/;
			}
			if ($line =~ /^\s+:Size\s/) {
				$picl_bank_size=$line;
				$picl_bank_size=~s/^.*:Size\s+(.*)$/$1/;
				if ($picl_bank_size =~ /^0x\d/) {
					$picl_bank_size=~s/^(.*)00000$/$1/;
					$picl_bank_size=hex($picl_bank_size);
				} else {
					$picl_bank_size=$segment_size / $meg;
				}
			}
		}
		if ($line =~ /^\s+memory-module\s/) {
			$flag_mem_mod=1;	# Start of memory module section
			$has_picl_mem_mod=1;
		}
		if ($flag_mem_mod) {
			if ($line =~ /^\s+:nac\s/) {
				$mem_dimm=$line;
				$mem_dimm=~s/^.*:nac\s+(.*)\s*$/$1/;
				$picl_dimm_per_bank++;
			}
		}
		if ($line =~ /^\s+MR\d\s/) {
			$mem_riser=$line;
			$mem_riser=~s/^.*(MR\d).*/$1/;
		}
		if ($line =~ /^\s+MCU\d\s/) {
			$mem_cu=$line;
			$mem_cu=~s/^.*(MCU\d).*/$1/;
		}
		if ($line =~ /^\s+(BR|BOB)\d\s/) {
			$flag_mem_chan=0;
			$mem_branch=$line;
			$mem_branch=~s/^.*(BR\d).*/$1/;
			$mem_branch=~s/^.*(BOB\d).*/$1/;
			# SPARC T3-2, T4-2
			$mem_branch=$mem_riser . "/" . $mem_branch if ($mem_riser);
		}
		if ($line =~ /^\s+CH\d\s/) {
			$flag_mem_chan=1;	# Start of memory channel section
			$mem_channel=$line;
			$mem_channel=~s/^.*(CH\d).*/$1/;
		}
		if ($flag_mem_chan && $line =~ /^\s+D\d\s/) {
			$flag_mem_mod=1;	# Start of memory module section
			$picl_foundmemory=1;
			$mem_dimm=$line;
			$mem_dimm=~s/^.*(D\d).*/$1/;
		}
		if ($flag_mem_mod) {
			if ($line =~ /\s+:ModelName\s/) {
				$mem_model=$line;
				$mem_model=~s/^.*:ModelName\s+(.*)$/$1/;
			}
			if ($line =~ /\s+:MfgName\s/) {
				$mem_mfg=$line;
				$mem_mfg=~s/^.*:MfgName\s+(.*)$/$1/;
			}
		}
		if ($line =~ /\s+:name\s+physical-platform/) {
			$flag_physical_platform=1;
		} elsif ($line =~ /\s+:name\s+SYS/) {
			$flag_physical_platform=0;
		}
		if ($flag_physical_platform) {
			if ($line =~ /\s+:MfgName\s/) {
				$manufacturer=$line;
				$manufacturer=~s/^.*:MfgName\s+(.*)$/$1/;
			}
		}
	}
}

sub check_prtfru {
	&pdebug("in check_prtfru");
	if ($prtfru_cmd && ! $have_prtfru_data) {
		# Warn that prtfru may take a while to run
		&please_wait;
		@prtfru=&run("$prtfru_cmd -x");
		$have_prtfru_data=1;
	}
	$flag_mem_mod=0;
	$cpu_mem_slot="";
	$mem_slot="";
	$mem_desc="";
	$mem_mfg="";
	$mem_mfg_loc="";
	$mem_pn="";
	$sun_pn="";
	$fru_details="";
	$fru_sb="";
	$fru_cpu="";
	$fru_bank="";
	$fru_dimm="";
	$prevline="";
	foreach $line (@prtfru) {
		$line=&dos2unix($line);
		$line=&mychomp($line);
		$line=~s/\s+$//;
		if ($line =~ /<Container name=\"(system-board|SB\d+)\"/ && $prevline !~ /<\/Fru>/) {
			$fru_sb=$prevline;
			$fru_sb=~s/^.*Label=(.*)\s*\".*/$1/;
			&pdebug("in check_prtfru, found fru_sb=$fru_sb");
		}
		if ($line =~ /<Fru name=\"(cpu|P\d+)\"/) {
			$fru_cpu=$prevline;
			$fru_cpu=~s/^.*Label=(.*)\s*\".*/$1/;
			&pdebug("in check_prtfru, found fru_cpu=$fru_cpu");
		}
		if ($line =~ /<Fru name=\"(bank|B\d+)\"/) {
			$fru_bank=$prevline;
			$fru_bank=~s/^.*Label=(.*)\s*\".*/$1/;
			&pdebug("in check_prtfru, found fru_bank=$fru_bank");
		}
		if ($line =~ /<Container name=\"(mem-module|D\d+)\"/) {
			$fru_dimm=$prevline;
			$fru_dimm=~s/^.*Label=(.*)\s*\".*/$1/;
			&pdebug("in check_prtfru, found fru_dimm=$fru_dimm");
			if (! $mem_slot && $fru_cpu && $fru_bank && $fru_dimm) {
				$flag_mem_mod=1;	# Start of memory module section
				$mem_slot="$fru_cpu/$fru_bank/$fru_dimm";
				$mem_slot="$fru_sb/$mem_slot" if ($fru_sb);
			}
		}
		if ($line =~ /<Location name=\"cpu-mem-slot\?Label=/) {
			$cpu_mem_slot=$line;
			$cpu_mem_slot=~s/^.*Label=(.*)\s*\".*/$1/;
			&pdebug("in check_prtfru, found cpu_mem_slot=$cpu_mem_slot");
		}
		if ($line =~ /<Location name=\"(mem|dimm)-slot\?Label=/) {
			$flag_mem_mod=1;	# Start of memory module section
			$mem_slot=$line;
			$mem_slot=~s/^.*Label=(.*)\s*\".*/$1/;
			&pdebug("in check_prtfru, found mem_slot=$mem_slot");
		}
		if ($line =~ /<\/Location\>/) {
			$flag_mem_mod=0;	# End of memory module section
			if ($mem_slot) {
				if ($mem_desc) {
					$have_prtfru_details=1;
					$fru_details .= "$cpu_mem_slot " if ($cpu_mem_slot);
					$fru_details .= "$mem_slot: $mem_desc";
					$fru_details .= ", Sun $sun_pn" if ($sun_pn);
					if ($mem_mfg && $mem_pn) {
						$fru_details .= ", $mem_mfg $mem_pn";
					} else {
						$fru_details .= ", $mem_mfg" if ($mem_mfg);
						$fru_details .= ", $mem_pn" if ($mem_pn);
					}
					$fru_details .= "\n";
				} else {
					$missing_prtfru_details .= "${cpu_mem_slot}_" if ($cpu_mem_slot);
					$missing_prtfru_details .= "$mem_slot ";
				}
			}
			$mem_slot="";
			$mem_desc="";
			$mem_mfg="";
			$mem_mfg_loc="";
			$mem_pn="";
			$sun_pn="";
			$fru_dimm="";
		}
		if ($flag_mem_mod) {
			if ($line =~ /(DIMM_Capacity|Fru_Description) value=/) {
				$mem_desc=$line;
				$mem_desc=~s/^.*\"(.*)\s*\".*$/$1/;
			}
			if ($line =~ /(Fundamental_Memory_Type|DIMM_Config_Type) value=/) {
				$tmp=$line;
				$tmp=~s/^.*\"(.*)\s*\".*$/$1/;
				if ($mem_desc) {
					$mem_desc .= " $tmp";
				} else {
					$mem_desc="$tmp";
				}
			}
			if ($line =~ /Manufacture_Loc value=/ && ! $mem_mfg_loc) {
				$mem_mfg_loc=$line;
				if ($mem_mfg_loc =~ /\".*\"/) {
					$mem_mfg_loc=~s/^.*\"(.*)\s*\".*$/$1/;
				} else {
					$mem_mfg_loc=~s/^.*\"(.*)\s*$/$1/;
				}
			}
			if ($line =~ /Vendor_Name value=/ && ! $mem_mfg) {
				$mem_mfg=$line;
				if ($mem_mfg =~ /\".*\"/) {
					$mem_mfg=~s/^.*\"(.*)\s*\".*$/$1/;
				} else {
					$mem_mfg=~s/^.*\"(.*)\s*$/$1/;
				}
				$mem_mfg=&get_mfg($mem_mfg);
				# Fix some unrecognized manufacturers
				if ($mem_mfg =~ /(unrecognized value|UNKNOWN Invalid Value)/i) {
					if ($mem_mfg =~ /[0\b]4400\b/ || $mem_mfg_loc =~ /Boise.*Idaho/i) {
						$mem_mfg="Micron Technology";
					} elsif ($mem_mfg =~ /[0\b]7800\b/ || $mem_mfg_loc =~ /Onyang.*Korea/i) {
						$mem_mfg="Samsung";
					} elsif ($mem_mfg =~ /[0\b]0551\b/ || $mem_mfg_loc =~ /\bQMY\b/) {
						$mem_mfg="Qimonda";
					} else {
						# unrecognized manufacturer
						$recognized=-3;
						$exitstatus=1;
					}
				}
			}
			if ($line =~ /Manufacturer_Part_No value=/ && ! $mem_pn) {
				$mem_pn=$line;
				$mem_pn=~s/^.*\"(.*)\s*\".*$/$1/;
			}
			if ($line =~ /Sun_Part_No value=/ && ! $sun_pn) {
				$sun_pn=$line;
				$sun_pn=~s/^.*\"(.*)\s*\".*$/$1/;
				$sun_pn=~s/^(\d\d\d)(\d\d\d\d)$/$1-$2/;
			}
			# This data is not always accurate, so ignore it
#			if ($line =~ /Fru_Type value=/ && ! $mem_desc) {
#				$mem_desc=$line;
#				$mem_desc=~s/^.*\"(.*)\s*\".*$/$1/;
#			}
		}
		$prevline=$line;
	}
}

sub multicore_cputype {
	$s=shift;
	$tmp=shift;
	return if (! defined($s) || ! defined($tmp));
	$s="Hyper-Threaded $s" if ($hyperthread && $s !~ /Hyper.Thread/i);
	if ($tmp == 2) {
		$s="Dual-Core $s" if ($s !~ /(Dual|Two).Core/i);
	} elsif ($tmp == 3) {
		$s="Triple-Core $s" if ($s !~ /(Triple|Three).Core/i);
	} elsif ($tmp == 4) {
		$s="Quad-Core $s" if ($s !~ /(Quad|Four).Core/i);
	} elsif ($tmp == 6) {
		$s="Six-Core $s" if ($s !~ /(Hex|Six).Core/i);
	} elsif ($tmp == 8) {
		$s="Eight-Core $s" if ($s !~ /(Octal|Eight).Core/i);
	} elsif ($tmp == 10) {
		$s="Ten-Core $s" if ($s !~ /Ten.Core/i);
	} elsif ($tmp == 12) {
		$s="Twelve-Core $s" if ($s !~ /Twelve.Core/i);
	} elsif ($tmp > 1) {
		$s="${tmp}-Core $s" if ($s !~ /${tmp}.Core/i);
	}
	$s=~s/ Core/-Core/ if ($s =~ /(Dual|Two|Triple|Three|Quad|Four|Hex|Six|Octal|Eight|Ten|Twelve|[0-9]) Core/i);
	return($s);
}

sub cleanup_cputype {
	$_=shift;
	return "" if (! defined($_));
	s/ CPU//;
	s/ [Pp]rocessor//;
	s/ +MHz/MHz/;
	s/ (\d[\d\.]*GHz) \d*MHz/ $1/;
	s/\s+/ /g;
	s/^\s+//;
	s/\s+$//;
	s/\(r\)/\(R\)/g;
	s/\(tm\)/\(TM\)/g;
	s/ Core/-Core/ if (/(Dual|Two|Triple|Three|Quad|Four|Hex|Six|Octal|Eight|Ten|Twelve|[0-9]) Core/i);
	return($_);
}

sub multicore_cpu_cnt {
	$arg=shift;
	&check_psrinfo;
	&pdebug("in multicore_cpu_cnt, cputype=$cputype, threadcnt=$threadcnt");
	if ($cputype =~ /UltraSPARC-T1$/) {
		$cputype="UltraSPARC-T1";
		# Count 4-Thread (4, 6, or 8 Core) Niagara CPUs as 1 CPU
		if ($npcpu && $ldm_cmd && ! $have_ldm_data) {
			$ncpu=$npcpu;
		} else {
			# Each CPU has 8 Cores max (32 threads)
			$ncpu=int(($threadcnt - 1) / 32) + 1;
		}
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		if ($threadcnt) {
			$cputype=$threadcnt / 4 / $ncpu . "-Core Quad-Thread $cputype";
			$cpucnt{"$cputype $cpufreq"}=$ncpu;
		}
	} elsif ($cputype =~ /UltraSPARC-T2\+/) {
		$cputype="UltraSPARC-T2+";
		# Count 8-Thread (4, 6, or 8 Core) Victoria Falls CPUs as 1 CPU
		if ($npcpu && $ldm_cmd && ! $have_ldm_data) {
			$ncpu=$npcpu;
		} else {
			# Assume there are no single-cpu systems with the US-T2+
			$ncpu=2;
			# Valid configurations:
			#  T5140,T5240: 2 x 4-Core (64 threads), 2 x 6-Core
			#    (96 threads), 2 x 8-Core (128 threads)
			#  T5440: 4 x 4-Core (128 threads), 4 x 8-Core
			#    (256 threads)
			#  Netra-T5440: 2 x 8-Core (128 threads)
			if ($ultra eq "T5140" || $ultra eq "T5240") {
				$ncpu=2;
			} elsif ($ultra eq "T5440") {
				$ncpu=4;
				$ncpu=2 if ($model =~ /Netra-T5440/);
			}
		}
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		if ($threadcnt) {
			$cputype=$threadcnt / 8 / $ncpu . "-Core 8-Thread $cputype";
			$cpucnt{"$cputype $cpufreq"}=$ncpu;
		}
	} elsif ($cputype =~ /UltraSPARC-T2$/) {
		$cputype="UltraSPARC-T2";
		# Count 8-Thread (4 or 8 Core) Niagara-II CPUs as 1 CPU
		if ($npcpu && $ldm_cmd && ! $have_ldm_data) {
			$ncpu=$npcpu;
		} else {
			# Each CPU has 8 Cores max (64 threads)
			$ncpu=int(($threadcnt - 1) / 64) + 1;
		}
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		if ($threadcnt) {
			$cputype=$threadcnt / 8 / $ncpu . "-Core 8-Thread $cputype";
			$cpucnt{"$cputype $cpufreq"}=$ncpu;
		}
	} elsif ($cputype =~ /SPARC-T3$/) {
		$cputype="SPARC-T3";
		# Count 8-Thread (8 or 16 Core) Rainbow Falls CPUs as 1 CPU
		if ($npcpu && $ldm_cmd && ! $have_ldm_data) {
			$ncpu=$npcpu;
		} else {
			# Each CPU has 16 Cores max (128 threads)
			$ncpu=int(($threadcnt - 1) / 128) + 1;
		}
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		if ($threadcnt) {
			$cputype=$threadcnt / 8 / $ncpu . "-Core 8-Thread $cputype";
			$cpucnt{"$cputype $cpufreq"}=$ncpu;
		}
	} elsif ($cputype =~ /SPARC-T4$/) {
		$cputype="SPARC-T4";
		# Count 8-Thread 8-Core SPARC-T4 CPUs as 1 CPU
		if ($npcpu && $ldm_cmd && ! $have_ldm_data) {
			$ncpu=$npcpu;
		} else {
			# Each CPU has 8 Cores max (64 threads)
			$ncpu=int(($threadcnt - 1) / 64) + 1;
		}
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		if ($threadcnt) {
			$cputype=$threadcnt / 8 / $ncpu . "-Core 8-Thread $cputype";
			$cpucnt{"$cputype $cpufreq"}=$ncpu;
		}
	} elsif ($cputype =~ /SPARC-T5$/) {
		$cputype="SPARC-T5";
		# Count 8-Thread 16-Core SPARC-T5 CPUs as 1 CPU
		if ($npcpu && $ldm_cmd && ! $have_ldm_data) {
			$ncpu=$npcpu;
		} else {
			# Each CPU has 16 Cores max (128 threads)
			$ncpu=int(($threadcnt - 1) / 128) + 1;
		}
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		if ($threadcnt) {
			$cputype=$threadcnt / 8 / $ncpu . "-Core 8-Thread $cputype";
			$cpucnt{"$cputype $cpufreq"}=$ncpu;
		}
	} elsif ($cputype =~ /SPARC.M5$/) {
		$cputype="SPARC-M5";
		# Count 8-Thread 6-Core SPARC-M5 CPUs as 1 CPU
		if ($npcpu && $ldm_cmd && ! $have_ldm_data) {
			$ncpu=$npcpu;
		} else {
			# Each CPU has 6 Cores max (48 threads)
			$ncpu=int(($threadcnt - 1) / 48) + 1;
		}
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		if ($threadcnt) {
			$cputype=$threadcnt / 8 / $ncpu . "-Core 8-Thread $cputype";
			$cpucnt{"$cputype $cpufreq"}=$ncpu;
		}
	} elsif ($cputype =~ /SPARC.M6$/) {
		$cputype="SPARC-M6";
		# Count 8-Thread 12-Core SPARC-M6 CPUs as 1 CPU
		if ($npcpu && $ldm_cmd && ! $have_ldm_data) {
			$ncpu=$npcpu;
		} else {
			# Each CPU has 12 Cores max (96 threads)
			$ncpu=int(($threadcnt - 1) / 96) + 1;
		}
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		if ($threadcnt) {
			$cputype=$threadcnt / 8 / $ncpu . "-Core 8-Thread $cputype";
			$cpucnt{"$cputype $cpufreq"}=$ncpu;
		}
	} elsif ($cputype =~ /SPARC.S7$/) {
		$cputype="SPARC-S7";
		# Count 8-Thread 8-Core SPARC-S7 CPUs as 1 CPU
		if ($npcpu && $ldm_cmd && ! $have_ldm_data) {
			$ncpu=$npcpu;
		} else {
			# Each CPU has 8 Cores max (64 threads)
			$ncpu=int(($threadcnt - 1) / 64) + 1;
		}
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		if ($threadcnt) {
			$cputype=$threadcnt / 8 / $ncpu . "-Core 8-Thread $cputype";
			$cpucnt{"$cputype $cpufreq"}=$ncpu;
		}
	} elsif ($cputype =~ /SPARC.M7$/) {
		$cputype="SPARC-M7";
		# Count 8-Thread 32-Core SPARC-M7 CPUs as 1 CPU
		if ($npcpu && $ldm_cmd && ! $have_ldm_data) {
			$ncpu=$npcpu;
		} else {
			# Each CPU has 32 Cores max (256 threads)
			$ncpu=int(($threadcnt - 1) / 256) + 1;
		}
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		if ($threadcnt) {
			$cputype=$threadcnt / 8 / $ncpu . "-Core 8-Thread $cputype";
			$cpucnt{"$cputype $cpufreq"}=$ncpu;
		}
	} elsif ($cputype =~ /SPARC.M8$/) {
		$cputype="SPARC-M8";
		# Count 8-Thread 32-Core SPARC-M8 CPUs as 1 CPU
		if ($npcpu && $ldm_cmd && ! $have_ldm_data) {
			$ncpu=$npcpu;
		} else {
			# Each CPU has 32 Cores max (256 threads)
			$ncpu=int(($threadcnt - 1) / 256) + 1;
		}
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		if ($threadcnt) {
			$cputype=$threadcnt / 8 / $ncpu . "-Core 8-Thread $cputype";
# TLS ToDo 20170126
# Why am I getting cpufreq 4295MHz and 5067MHz here? 5067MHz is correct
			$cpucnt{"$cputype $cpufreq"}=$ncpu;
		}
	} elsif ($cputype =~ /SPARC64-VI$/) {
		# Count Dual-Core Dual-Thread Olympus-C SPARC64-VI CPUs as 1 CPU
		$ncpu=$threadcnt / 4;
		$cputype="Dual-Core Dual-Thread SPARC64-VI";
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		$cpucnt{"$cputype $cpufreq"}=$ncpu;
	} elsif ($cputype =~ /SPARC64-VII\+\+$/) {
		# Count Quad-Core Dual-Thread Jupiter++ SPARC64-VII++ CPUs as 1 CPU
		$ncpu=$threadcnt / 8;
		$cputype="Quad-Core Dual-Thread SPARC64-VII++";
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		$cpucnt{"$cputype $cpufreq"}=$ncpu;
	} elsif ($cputype =~ /SPARC64-VII\+$/) {
		# Count Quad-Core Dual-Thread Jupiter+ SPARC64-VII+ CPUs as 1 CPU
		$ncpu=$threadcnt / 8;
		$cputype="Quad-Core Dual-Thread SPARC64-VII+";
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		$cpucnt{"$cputype $cpufreq"}=$ncpu;
	} elsif ($cputype =~ /SPARC64-VII$/) {
		# Count Quad-Core Dual-Thread Jupiter SPARC64-VII CPUs as 1 CPU
		$ncpu=$threadcnt / 8;
		$cputype="Quad-Core Dual-Thread SPARC64-VII";
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		$cpucnt{"$cputype $cpufreq"}=$ncpu;
	} elsif ($cputype =~ /SPARC64-VIII$/) {
		# Guess on the Venus SPARC64-VIII name ???
		# Count 8-Core Dual-Thread Venus SPARC64-VIII CPUs as 1 CPU
		$ncpu=$threadcnt / 16;
		$cputype="8-Core Dual-Thread SPARC64-VIII";
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		$cpucnt{"$cputype $cpufreq"}=$ncpu;
	} elsif ($cputype =~ /SPARC64-X$/) {
		# Count 16-Core Dual-Thread SPARC64-X CPUs as 1 CPU
		$ncpu=$threadcnt / 32;
		$cputype="16-Core Dual-Thread SPARC64-X";
		if (defined($arg)) {
			$cnt=$ncpu;
			return;
		}
		$cpucnt{"$cputype $cpufreq"}=$ncpu;
	}
}

sub x86multicorecnt {
	$_=shift;
	return if (! defined($_));
	$corecnt=2 if (/\b(Dual|Two).Core/i);
	$corecnt=3 if (/\b(Triple|Three).Core/i);
	$corecnt=4 if (/\b(Quad|Four).Core/i);
	$corecnt=6 if (/\b(Hex|Six).Core/i);
	$corecnt=8 if (/\b(Octal|Eight).Core/i);
	$corecnt=10 if (/\bTen.Core/i);
	$corecnt=12 if (/\bTwelve.Core/i);
}

sub checkX86 {
	$isX86=1 if ($model eq "i86pc" || $machine eq "i86pc" || $model eq "i86xpv" || $machine eq "i86xpv" || $model eq "i86xen" || $machine eq "i86xen");
	# Use CPU count from prtdiag (ndcpu) and thread count from psrinfo to
	# get core count per cpu for i86xpv/i86xen
	$use_psrinfo_data=2 if ($model eq "i86xpv" || $machine eq "i86xpv" || $model eq "i86xen" || $machine eq "i86xen");
}

sub check_psrinfo {
	return if ($psrinfo_checked);
	&pdebug("in check_psrinfo, ndcpu=$ndcpu, npcpu=$npcpu, nvcpu=$nvcpu");
	$psrinfo_checked=1;
	return if ($nvcpu || ! $use_psrinfo_data);
	if ($filename) {
		$npcpu=0;
		$j=0;
		$have_npcpu=0;
		foreach $line (@psrinfo) {
			$line=&dos2unix($line);
			# May have "psrinfo -p" output in regression test file
			# that has number of physical CPUs.
			if ($line =~ /^#.*psrinfo -p$/ && $psrinfo[$j + 1] =~ /^\d+$/) {
				$npcpu=&mychomp($psrinfo[$j + 1]);
				$have_npcpu=1;
				&pdebug("in check_psrinfo, found npcpu=$npcpu");
			}
			# May have "psrinfo -p -v" output in regression test
			# file that has number of virtual CPUs. Assumes all
			# CPUs are same.
			if ($line =~ /^The .+ \d+ virtual processor/) {
				&check_psrinfo_pv;
				if ($use_psrinfo_data == 2 && $ndcpu > 1) {
					$corecnt /= $ndcpu;
					$npcpu=$ndcpu if (! $have_npcpu);
				} else {
					$npcpu++ if (! $have_npcpu);
				}
				$cpucntfrom="psrinfo" if ($cpucntfrom ne "ldm");
				$cpucntflag="0";	# reset flag
				&pdebug("in check_psrinfo, found nvcpu=$nvcpu, corecnt=$corecnt, npcpu=$npcpu, hyperthread=$hyperthread");
			}
			$j++;
		}
	} elsif ($psrinfo_cmd) {
		$ncpu=&mychomp(`$psrinfo_cmd | wc -l`);	# physical & virtual CPUs
		$ncpu=~s/\s+//;
		$npcpu=&mychomp(`$psrinfo_cmd -p 2>/dev/null`);	# physical CPUs
		if ($npcpu) {
			# Find number of virtual CPUs
			@tmp=`$psrinfo_cmd -p -v`;
			foreach $line (@tmp) {
				$line=&dos2unix($line);
				if ($line =~ /^The .+ \d+ virtual processor/) {
					&check_psrinfo_pv;
					if ($use_psrinfo_data == 2 && $ndcpu > 1) {
						$corecnt /= $ndcpu;
						$npcpu=$ndcpu;
					}
				}
			}
			if ($cputype eq "x86") {
				if ($tmp[2] =~ /.+Hz|\bAMD .* Processor /) {
					$cputype_psrinfo=&cleanup_cputype(&mychomp($tmp[2]));
				}
			}
		} else {
			$npcpu=$ncpu;
			$nvcpu=1;
		}
		@tmp=`$psrinfo_cmd -v`;
		if ($tmp[2] =~ /MHz/) {
			$cpufreq=&mychomp($tmp[2]);
			$cpufreq=~s/.+ operates at //;
			$cpufreq=~s/ MHz.+//;
		}
		$cpucntfrom="psrinfo" if ($cpucntfrom ne "ldm");
		$have_psrinfo_data=1;
	}
}

sub check_psrinfo_pv {
	$nvcpu=&mychomp($line);
	$nvcpu=~s/.+ processor has //;
	$nvcpu=~s/ virtual processor.+//;
	if ($nvcpu =~ / cores and /) {
		$nvcpu=~s/cores and //;
		$corecnt=$nvcpu;
		$corecnt=~s/ \d+$//;
		$nvcpu=~s/^\d+ //;
		if ($nvcpu == 2 * $corecnt && $isX86) {
			$hyperthread=1;
			&pdebug("hyperthread=1: from psrinfo -p -v");
		}
	} else {
		$corecnt=$nvcpu if ($nvcpu >= 2);
		$corecnt /= 2 if ($hyperthread);
	}
}

sub get_mfg {
	$_=shift;
	return "" if (! defined($_));
	s/Manufacturer: *//ig;
	$has_JEDEC_ID=0;
	if (/JEDEC ID:/) {
		s/JEDEC ID://g;
		s/ //g;
		$has_JEDEC_ID=1;
	}
	s/^\s+//;
	s/\s+$//;
	s/^0x//;
	&pdebug("in get_mfg, JEDEC_ID=$_");
	return "" if (/(^$|^\r$|^FFFFFFFFFFFF|^000000000000|^Undefined|Manufacturer\d)/i);
	s/^(00|80)// if (! /^007F/);
	# Based on JEDEC JEP106AT
	return "Micron Technology" if (/(^2C|Micron\b)/i);
	return "Micron CMS" if (/(^7F45|Micron CMS)/i);
	return "Crucial Technology" if (/(^1315$|^859B|^9B|^7F7F7F7F7F9B|Crucial\b)/i);
	# Inotera was a Joint Venture between Micron and Nanya
	# Micron fully acquired Inotera in 2016
	return "Inotera Memories" if (/Inotera/i);
	# Micron acquired Elpida in August 2013
	return "Elpida" if (/(^0500|^FE|^7F7FFE|^02FE|Elpida)/i);
	# Micron acquired Numonyx in February 2010
	return "Numonyx (Intel)" if (/(^89|Intel)/i);
	return "Numonyx" if (/Numonyx/i);
	return "Fujitsu" if (/(^04|Fujitsu)/i);
	return "Hitachi" if (/(^07|Hitachi)/i);
	return "Inmos" if (/(^08|Inmos)/i);
	return "Intersil" if (/(^0B|Intersil)/i);
	return "Mostek" if (/(^0D|Mostek)/i);
	return "Freescale (Motorola)" if (/(^0E|Motorola)/i);
	return "Freescale" if (/Freescale/i);
	return "NEC" if (/^10/);
	return "Conexant (Rockwell)" if (/(^13|Rockwell)/i);
	return "Conexant" if (/Conexant/i);
	return "NXP (Philips Semi, Signetics)" if (/(^15|Philips Semi|Signetics)/i);
	return "Synertek" if (/(^16|Synertek)/i);
	return "Xicor" if (/(^19|Xicor)/i);
	return "Zilog" if (/(^1A|Zilog)/i);
	return "Mitsubishi" if (/(^1C|Mitsubishi)/i);
	return "ProMOS/Mosel Vitelic" if (/(^40|ProMOS|Mosel Vitelic)/i);
	return "Qimonda" if (/(^51|^8551|Qimonda)/i);
	return "Wintec Industries" if (/(^61|Wintec\b)/i);
	return "Goldenram" if (/(^6A|Goldenram)/i);
	return "Fairchild" if (/(^83|Fairchild)/i);
	return "GTE" if (/(^85|GTE)/i);
	return "DATARAM" if (/^91|^7F91/);
	return "Smart Modular" if (/^94|^0194|Smart Modular/i);
	return "Toshiba" if (/(^98|Toshiba)/i);
	return "Corsair" if (/(^9E|Corsair)/i);
	return "IBM" if (/^A4/i);
	return "Hynix Semiconductor (Hyundai Electronics)" if (/(^AD|Hyundai)/i);
	return "Hynix Semiconductor" if (/(HYN|Hynix)/i);
	return "Infineon (Siemens)" if (/(^C1|^7F7F7F7F7F51|Siemens)/i);
	return "Infineon" if (/Infineon/i);
	return "Samsung" if (/(^CE|Samsung)/i);
	return "Winbond Electronics" if (/(^DE|Winbond)/i);
	return "LG Semiconductor (Goldstar)" if (/(^E0|Goldstar)/i);
	return "LG Semiconductor" if (/LG Semi/i);
	return "Kingston" if (/(^7F98|^0198|Kingston)/i);
	return "SpecTek Incorporated" if (/(^7F7FB5|SpecTek)/i);
	return "Nanya Technology" if (/(^7F7F7F0B|^830B|Nanya)/i);
	return "Kingmax Semiconductor" if (/(^7F7F7F25|KINGMAX)/i);
	return "Ramaxel Technology" if (/(^7F7F7F7F43|Ramaxel)/i);
	return "A-DATA Technology" if (/(^7F7F7F7FCB|ADATA|A-DATA)/i);
	return "Team Group Inc." if (/^(7F7F7F7FEF|Team\b)/i);
	return "AMD" if (/^01/);
	return "AMI" if (/^02/);
	if ($has_JEDEC_ID || /^7F|^80|^FF/i) {
		$unknown_JEDEC_ID=1;
		&pdebug("in get_mfg, found unknown JEDEC ID $_");
	}
	return &mychomp($_);
}

# See if CPUs and memory modules are listed in "ipmitool fru" output
sub check_ipmitool {
	&pdebug("in check_ipmitool");
	return if (! $ipmitool_cmd && ! $filename);
	$cputype2="";
	$mem_mfg="";
	$mem_model="";
	$mem_pn="";
	$flag_cpu=0;
	$flag_mem=0;
	$flag_mfg=0;
	$socket="";
	foreach $line (@ipmitool) {
		$line=&dos2unix($line);
		$line=&mychomp($line);
		if ($line =~ /^ *$/) {
			# store cpu and memory modules in hash
			if ($flag_cpu) {
				if ($cputype2) {
					$cputype2=~s/DUAL.CORE/Dual-Core/;
					$cputype2=~s/TRIPLE.CORE/Triple-Core/;
					$cputype2=~s/QUAD.CORE/Quad-Core/;
					$cputype2=~s/SIX.CORE/Six-Core/;
					$cputype2=~s/EIGHT.CORE/Eight-Core/;
					$cputype2=~s/TEN.CORE/Ten-Core/;
					$cputype2=~s/TWELVE.CORE/Twelve-Core/;
					$cputype2=~s/ Core/-Core/;
					$cputype2=~s/OPTERON\(TM\) PROCESSOR/Opteron\(TM\)/;
					$ipmi_cputype="$cputype2";
					$ipmi_cpucnt++;
				}
			}
			if ($flag_mem && $socket) {
				$ipmi_mem{"$socket"}=("$mem_mfg$mem_model$mem_pn") ? "$mem_mfg $mem_model$mem_pn" : "";
			}
			$flag_cpu=0;	# End of CPU section
			$flag_mem=0;	# End of memory section
			$flag_mfg=0;	# End of mfg section
			$cputype2="";
			$mem_mfg="";
			$mem_model="";
			$mem_pn="";
		}
		if ($line =~ / (cpu\d+\.vpd|p\d+\.fru )/) {
			$flag_cpu=1;	# Start of CPU section
			$socket=$line;
			$socket=~s/^.*: +(.*\S)\.[vf][pr][du].*$/$1/;
		}
		if ($flag_cpu && $line =~ / Product Name /) {
			$cputype2=$line;
			$cputype2=~s/^.*: +(.*\S) *$/$1/;
			&x86multicorecnt($cputype2);
		}
		if ($line =~ / (cpu\d+\.mem\d+\.vpd|p\d+\.d\d+\.fru) /) {
			$flag_mem=1;	# Start of memory module section
			$socket=$line;
			$socket=~s/^.*: +(.*\S)\.[vf][pr][du].*$/$1/;
		} elsif ($line =~ / P\d+C\d+\/B\d+\/C\d+\/D\d+ / && $ultra =~ /^T7-/) {
			# Need what M7-8 and M7-16 format looks like
			$flag_mem=1;	# Start of memory module section
			$socket=$line;
			$socket=~s/^.*: +(.*\S)\s*.*$/$1/;
		} elsif ($line =~ / P\d+\/M\d+\/B\d+\/C\d+\/D\d+ / && $ultra =~ /^T8-/) {
			$flag_mem=1;	# Start of memory module section
			$socket=$line;
			$socket=~s/^.*: +(.*\S)\s*.*$/$1/;
		}
		if ($flag_mem && $line =~ / Device not present /) {
			# Ignore missing Processor Modules
			$flag_mem=0 if ($ultra eq "T7-4" && $corecnt == 2 && $socket =~ /P1C\d+\/B\d+\/C\d+\/D\d+/);
			# Need what M7-8 and M7-16 format looks like
		}
		if ($flag_mem && $line =~ / Product Manufacturer /) {
			$mem_mfg=$line;
			$mem_mfg=~s/^.*: +(.*\S) *$/$1/;
			$mem_mfg=&get_mfg($mem_mfg);
		}
		if ($flag_mem && $line =~ / Product Name /) {
			$mem_model=$line;
			$mem_model=~s/^.*: +(.*\S) *$/$1/;
			$mem_model=~s/ ADDRESS\/COMMAND//;
			$mem_model=~s/PARITY/Parity/;
		}
		if ($flag_mem && $line =~ / Product Part Number /) {
			$mem_pn=$line;
			$mem_pn=~s/^.*: +(.*\S) *$/, $1/;
			$mem_pn=~s/^, .*,(.*\S)$/, $1/;
		}
		if ($line =~ /FRU Device Description *: *\/*SYS /) {
			$flag_mfg=1;	# Start of mfg section
		}
		if ($flag_mfg && $line =~ / Product Manufacturer /) {
			$manufacturer="Sun Microsystems, Inc." if ($line =~ /Sun /i);
			$manufacturer="Oracle Corporation" if ($line =~ /Oracle/i);
		}
	}
	# Is ipmitool CPU count better?
#	&pdebug("ipmi_cpucnt=$ipmi_cpucnt");
	if ($ncpu != $ipmi_cpucnt && $npcpu == 0 && $ipmi_cpucnt != 0) {
		$ncpu=$ipmi_cpucnt;
		$npcpu=$ipmi_cpucnt;
		$cpucntfrom="ipmitool";
		$cpucnt{"$cputype $cpufreq"}=$ipmi_cpucnt;
	}
	# Did ipmitool find a better cputype?
	if (&lc($cputype) ne &lc($ipmi_cputype) && $ipmi_cputype) {
		# rewrite %cpucnt $cputype with cputype
		while (($cf,$cnt)=each(%cpucnt)) {
			$cf=~/^(.*) (\d+)$/;
			$cpufreq=$2;
			delete $cpucnt{"$1 $2"};
		}
		$cpucnt{"$ipmi_cputype $cpufreq"}=$ipmi_cpucnt;
	}
}

# Check for logical domains
sub check_for_LDOM {
	&pdebug("in check_for_LDOM");
	$kernbit=64 if (! $kernbit && $machine eq "sun4v");
	# Handle control LDOM on UltraSPARC-T1 and later systems
	if ($ldm_cmd && ! $have_ldm_data) {
		@ldm=&run("$ldm_cmd list-devices -a -p");
		$have_ldm_data=1;
	}
	$ldmthreadcnt=0;
	if ($have_ldm_data) {
		foreach $line (@ldm) {
			$line=&dos2unix($line);
			$line=&mychomp($line);
			&check_LDOM;
			# Count virtual CPUs
			$ldmthreadcnt++ if ($line =~ /^\|pid=\d/);
			if ($line =~ /^\|pa=\d.*\|size=\d/) {
				# Add up total memory found in ldm output
				$sz=$line;
				$sz=~s/^.*size=(\d*).*/$1/;
				$ldm_memory += $sz;
			}
		}
		# Was ldm data found?
		$have_ldm_data=0 if (! $ldmthreadcnt && ! $ldm_memory);
		if ($ldmthreadcnt) {
			# VCPUs found in ldm output
			delete $cpucnt{"$cputype $cpufreq"};
			&pdebug("ldm: ncpu=$ncpu, npcpu=$npcpu");
			$cpucntfrom="ldm";
			$threadcnt=$ldmthreadcnt;
			&multicore_cpu_cnt;
		}
		$installed_memory=$ldm_memory / $meg if ($ldm_memory);
	}
	# Handle guest domains on UltraSPARC-T1 and later systems
	if ($virtinfo_cmd && ! $have_virtinfo_data) {
		@virtinfo=&run("$virtinfo_cmd -pa");
		$have_virtinfo_data=1;
	}
	if ($cfgadm_cmd && ! $have_cfgadm_data) {
		@cfgadm=&run("$cfgadm_cmd -al");
		$have_cfgadm_data=1;
	}
	if ($have_virtinfo_data) {
		foreach $line (@virtinfo) {
			$line=&dos2unix($line);
			if ($line =~ /Domain role: LDoms guest|DOMAINROLE\|impl=LDoms\|control=false/i) {
				&found_guest_LDOM;
				&pdebug("exit 1");
				exit 1;
			}
			$virtinfoLDOMcontrolfound=1 if ($line =~ /DOMAINROLE\|impl=LDoms\|control=true/i);
		}
	}
	if ($have_cfgadm_data) {
		foreach $line (@cfgadm) {
			$line=&dos2unix($line);
			if ($line =~ /Configuration administration not supported/ && $ldmthreadcnt == 0 && $virtinfoLDOMcontrolfound == 0) {
				# Hack: Assume cfgadm fails on guest domains.
				&found_guest_LDOM;
				&pdebug("exit 1");
				exit 1;
			}
		}
	}
}

sub check_LDOM {
	if ($line =~ /Authorization failed|Connection refused/i) {
		if ($uid eq "0") {
			# No LDOMs configured
			$ldm_cmd="";
			$have_ldm_data=0;
		} else {
			&found_guest_LDOM("");
			print "ERROR: ldm: $line\n";
			print "    This user does not have permission to run '/opt/SUNWldm/bin/ldm'.\n";
			print "    Run memconf as a privileged user like root on the control LDOM.\n";
			&pdebug("exit 1");
			exit 1;
		}
	}
}

sub found_guest_LDOM {
	# Rewrite cputype and cpucnt hash since I don't
	# know how many cores the guest domain host has
	if ($cputype =~ /UltraSPARC-T1$/) {
		delete $cpucnt{"$cputype $cpufreq"};
		$cputype="UltraSPARC-T1";
		$cpucnt{"$cputype $cpufreq"}=1;
	} elsif ($cputype =~ /UltraSPARC-T2\+/) {
		delete $cpucnt{"$cputype $cpufreq"};
		$cputype="UltraSPARC-T2+";
		$cpucnt{"$cputype $cpufreq"}=1;
	} elsif ($cputype =~ /UltraSPARC-T2$/) {
		delete $cpucnt{"$cputype $cpufreq"};
		$cputype="UltraSPARC-T2";
		$cpucnt{"$cputype $cpufreq"}=1;
	} elsif ($cputype =~ /SPARC-T3$/) {
		delete $cpucnt{"$cputype $cpufreq"};
		$cputype="SPARC-T3";
		$cpucnt{"$cputype $cpufreq"}=1;
	} elsif ($cputype =~ /SPARC-T4$/) {
		delete $cpucnt{"$cputype $cpufreq"};
		$cputype="SPARC-T4";
		$cpucnt{"$cputype $cpufreq"}=1;
	} elsif ($cputype =~ /SPARC-T5$/) {
		delete $cpucnt{"$cputype $cpufreq"};
		$cputype="SPARC-T5";
		$cpucnt{"$cputype $cpufreq"}=1;
	} elsif ($cputype =~ /SPARC-M5$/) {
		delete $cpucnt{"$cputype $cpufreq"};
		$cputype="SPARC-M5";
		$cpucnt{"$cputype $cpufreq"}=1;
	} elsif ($cputype =~ /SPARC-M6$/) {
		delete $cpucnt{"$cputype $cpufreq"};
		$cputype="SPARC-M6";
		$cpucnt{"$cputype $cpufreq"}=1;
	} elsif ($cputype =~ /SPARC-S7$/) {
		delete $cpucnt{"$cputype $cpufreq"};
		$cputype="SPARC-S7";
		$cpucnt{"$cputype $cpufreq"}=1;
	}
	&show_header;
	$arg=shift;
	return if (defined($arg));
	$domaincontrol="";
	if ($have_virtinfo_data) {
		foreach $line (@virtinfo) {
			$line=&dos2unix($line);
			if ($line =~ /DOMAINCONTROL\|name=/i) {
				$domaincontrol=&mychomp($line);
				$domaincontrol=~s/^.*name=//;
			}
		}
	}
	print "ERROR: Guest Logical Domain (LDOM) detected.\n";
	print "    Run memconf on the control LDOM";
	print " host \"$domaincontrol\"" if ($domaincontrol ne "");
	print ".\n    It cannot show system memory details on guest LDOMs.\n";
}

sub found_nonglobal_zone {
	# non-global zone (container)
	print "WARNING: More details can be reported if memconf is run in the global zone";
	if ($filename) {
		print ".\n";
	} else {
		$globalzone=&mychomp(`/usr/sbin/arp -a | awk '/SP/ {print \$2}' | head -1`);
		print "\n         on hostname '$globalzone'.\n";
	}
}

sub check_smbios {
	&pdebug("in check_smbios");
	$flag_smb_cpudevice=0;
	$flag_smb_memdevice=0;
	$cpu_membank=-1;
	$cpu_cnt=-1;
	$physmemarray="";
	foreach $line (@smbios) {
		$line=&dos2unix($line);
		$line=&mychomp($line);
		next if ($line =~ /( *Unknown|: Other|: \.\.|: Not Specified)/i);
		if ($model eq "i86pc" || $model eq "i86xpv" || $model eq "i86xen") {
			if ($line =~ /^ *Manufacturer:/ && $line !~ /(To Be Filled|System Manufacturer)/i && $manufacturer eq "") {
				$manufacturer=$line;
				$manufacturer=~s/^ *Manufacturer: *//g;
				$manufacturer=~s/\s*$//g;
				&pdebug("in check_smbios, manufacturer=$manufacturer");
			}
			if ($line =~ /^ *Product:/ && $line !~ /(To Be Filled|System .*Name|XXXX)/i) {
				$model=$line;
				$model=~s/^ *Product: *//g;
				$model=~s/\s*$//g;
				&pdebug("in check_smbios, model=$model");
				&x86_devname;
			}
		}
		if ($line =~ /SMB_TYPE_PROCESSOR\b/) {
			$flag_smb_cpudevice=1;
			$cpu_cnt++;
		}
		if ($flag_smb_cpudevice && $line =~ /Location Tag:/) {
			$CPUSocketDesignation[$cpu_cnt]=$line;
			$CPUSocketDesignation[$cpu_cnt]=~s/^ *Location Tag: *//g;
			$flag_smb_cpudevice=0;
		}
		if ($line =~ /SMB_TYPE_MEMDEVICE\b/) {
			$mem_mfg="";
			$socket="";
			$pn="";
			$simmsize=0;
			$memtype="";
			$formfactor="";
			$smb_mdf="";
			$maxmembusspeed="";
			$flag_smb_cpudevice=0;
			$flag_smb_memdevice=1;
		}
		if ($flag_smb_memdevice) {
			if ($line =~ /Manufacturer:/) {
				$mem_mfg=$line;
				$mem_mfg=~s/^ *Manufacturer: *//g;
				$mem_mfg=&get_mfg($mem_mfg);
				$mem_mfg=", $mem_mfg" if ($mem_mfg);
			}
			if ($line =~ /Location Tag:/) {
				# Ignore System ROM FLASH
				if ($line =~ /SYSTEM ROM/i) {
					$flag_smb_memdevice=0;
				} else {
					$socket=$line;
					$socket=~s/^ *Location Tag: *//g;
					$socket=~s/\s*$//g;
				}
			}
			if ($line =~ /Part Number:/) {
				$pn=$line;
				$pn=~s/^ *Part Number: *//g;
				$pn=~s/\s*$//g;
				$pn="" if ($pn =~ /^0xFF|PartNum/i);
				$pn=&hex2ascii($pn);
				if ($pn) {
					# Hack: Ballistic modules may have mfg Undefined
					$mem_mfg=", Crucial Technology" if (! $mem_mfg && $pn =~ /^BL/);
					if ($mem_mfg) {
						$pn=" $pn";
					} else {
						$pn=", $pn";
					}
				}
			}
			if ($line =~ /Physical Memory Array:/) {
				$tmp=&mychomp($line);
				$tmp=~s/^ *Physical Memory Array: *//g;
				$cpu_membank++ if ($physmemarray ne $tmp);
				$physmemarray=$tmp;
			}
			if ($line =~ /Size:/) {
				$simmsize=$line;
				$simmsize=~s/^ *Size: //g;
				$simmsize=~s/ bytes//g;
				$simmsize=0 if ($simmsize =~ /Not Populated/);
				$simmsize /= $meg;
			}
			if ($line =~ /Memory Type:/) {
				# Ignore FLASH (System ROM)
				if ($line =~ /FLASH/i) {
					$flag_smb_memdevice=0;
				} else {
					$memtype=$line;
					$memtype=~s/^ *Memory Type:.*\((.*)\).*/$1/g;
					$memtype .= " " if ($formfactor);
					$memtype="" if ($memtype =~ /Memory Type:|^other/);
				}
			}
			if ($line =~ /Form Factor:/) {
				$formfactor=$line;
				$formfactor=~s/^ *Form Factor:.*\((.*)\).*/$1/g;
				$formfactor="" if ($formfactor =~ /Form Factor:/);
			}
			$smb_mdf="Fast-Page " if ($line =~ /SMB_MDF_FASTPG/);
			$smb_mdf="Synchronous " if ($line =~ /SMB_MDF_SYNC/);
			$smb_mdf="EDO " if ($line =~ /SMB_MDF_EDO/);
			if ($line =~ /^ *Speed: *\d+ *MHz/) {
				$maxmembusspeed=$line;
				$maxmembusspeed=~s/^ *Speed: *(\d+) *MHz/${1}MHz/g;
			}
			if ($line =~ /Bank Locator:|^ *ID *SIZE *TYPE/ && $socket) {
				$bank_label=$line;
				$bank_label=~s/^ *(Bank Locator:|ID *SIZE *TYPE) *//g;
				$bank_label=~s/ *SLOT$//ig;
				$bank_label="BANK $bank_label" if ($bank_label =~ /^.$/);
				$bank_label="" if ($bank_label eq $socket || $bank_label eq "BANK");
				if ($socket =~ /^CPU/ && $socket !~ /$bank_label/) {
					$socket .= "_$bank_label";
					$bank_label="";
				}
				$bank_label=" $bank_label" if ($bank_label);
				$flag_smb_memdevice=0;
				# Don't overwrite duplicate socket names
				if (! defined($smbios_mem{"$socket"})) {
					# Add CPU to X4170/X4270/X4275/X6270/X6275
					if ($model =~ /Sun .*X(4[12]7[05]|627[05])\b/i && $socket !~ /CPU/) {
						$bank_label="" if ($bank_label =~ /\/P\d+$/);
						$cpu_number=$CPUSocketDesignation[$cpu_membank];
						$cpu_number=~s/\s*//g;
						$socket="${cpu_number}_$socket";
					}
					if ($model =~ /W1100z\b/i && $model !~ /2100z\b/i && $socket =~ /DIMM[5-8]/) {
						# DIMM5-DIMM8 don't exist on W1100z
					} else {
						$smbios_mem{"$socket$bank_label"}=($simmsize) ? "${simmsize}MB $smb_mdf$memtype$formfactor$mem_mfg$pn" : "";
						$sockets_used="";
					}
				}
			}
		}
	}
	$tmp=scalar(keys %smbios_mem);
	if (defined($tmp)) {
		if ($tmp) {
			&pdebug("Memory found with smbios");
			&show_header;
			if (! &is_virtualmachine) {
				for (sort alphanumerically keys %smbios_mem) {
					if ($smbios_mem{$_}) {
						print "$_: $smbios_mem{$_}\n";
						$simmsize=$smbios_mem{$_};
						$simmsize=~s/^.*\b(\d+)M[Bb].*/$1/;
						$smbios_memory += $simmsize if ($simmsize);
					} else {
						&add_to_sockets_empty($_);
					}
				}
			}
			$totmem=$installed_memory;
			&print_empty_memory("memory sockets");
			&finish;
			&pdebug("exit");
			exit;
		}
	}
}

sub check_kstat {
	&pdebug("in check_kstat");
	$instance=0;
	foreach $line (@kstat) {
		$line=&dos2unix($line);
		$_=&mychomp($line);
		# cpu thread instance number
		if (/\scpu_info\s+instance:\s+/) {
			($instance)=(/.*\s(\d+)\s*$/);
		}
		if (/^\s*brand\s/) {
			($val)=(/^\sbrand\s*(\S.*)\s*$/);
			push(@kstat_brand, "$val") if ($val);
		}
		if (/\sclock_MHz\s/) {
			($val)=(/.*\s(\d+)\s*$/);
			push(@kstat_MHz, "$val") if ($val);
		}
		# count # of threads per unique core_id for each chip
		if (/\score_id\s/) {
			($val)=(/.*\s(\d+)\s*$/);
			$kstat_core_id{$instance}=$val;
			$kstat_core{$val}++;
		}
		# number of cores per chip
		if (/\sncore_per_chip\s/) {
			($val)=(/.*\s(\d+)\s*$/);
			$kstat_ncore_per_chip{$instance}=$val;
		}
		# max number of cpus (threads) per chip
		if (/\sncpu_per_chip\s/) {
			($val)=(/.*\s(\d+)\s*$/);
			$kstat_ncpu_per_chip{$instance}=$val;
		}
		$foundGenuineIntel=1 if (/\svendor_id\s+GenuineIntel/);
	}
	if ($foundGenuineIntel && $instance) {
		# Assume all CPUs are same
		for ($val=0; $val <= $instance; $val++) {
			last if (! defined($kstat_core_id{$val}) || ! defined($kstat_ncore_per_chip{$val}) || ! defined($kstat_ncpu_per_chip{$val}));
			$kstat_checked=1;
			if ($kstat_ncpu_per_chip{$val} == 2 * $kstat_ncore_per_chip{$val}) {
				# CPU is hyper-thread capable, but it may not be
				# enabled in the BIOS
				&pdebug("in check_kstat, found CPU capable of Hyper-Threading") if (! $hyperthreadcapable);
				$hyperthreadcapable=1;
				if ($kstat_core{$kstat_core_id{$val}} == 2) {
					# Hyper-Thread is enabled in BIOS.
					# Only change corecnt if not already
					# done earlier in check_psrinfo_pv.
					$corecnt /= 2 if (! $hyperthread);
					$hyperthread=1;
					&pdebug("hyperthread=1: from kstat, cputype=$cputype");
					last;
				}
			}
		}
	} elsif (@kstat_brand && @kstat_MHz) {
		@kstat_brandMHz=();
		@kstat_brand_arr=();
		@kstat_MHz_arr=();
		$i=0;
		foreach $brand (@kstat_brand) {
			$kstat_brandMHz{$brand,$kstat_MHz[$i]}++;
			push(@kstat_brand_arr, "$brand") if (! grep($_ eq $brand, @kstat_brand_arr));
			push(@kstat_MHz_arr, "$kstat_MHz[$i]") if (! grep($_ eq $kstat_MHz[$i], @kstat_MHz_arr));
			$i++;
		}
		@kstat_cpubanners=();
		# return unless have mix of CPUs or is VM
		return if ($#kstat_brand_arr == 0 && $#kstat_MHz_arr == 0 && ! &is_virtualmachine);
		foreach $brand (@kstat_brand_arr) {
			foreach $MHz (@kstat_MHz_arr) {
				if ($kstat_brandMHz{$brand,$MHz}) {
					$cputype=$brand;
					if ($isX86) {
						$cputype=&multicore_cputype($cputype,$corecnt);
					} else {
						&multicore_cpu_cnt;
					}
					$tmp="";
					$cnt=$kstat_brandMHz{$brand,$MHz} / $corecnt;
					$cpucntfrom="kstat";
					$tmp .= "$cnt X " if ($cnt > 1);
					push(@kstat_cpubanners, "$tmp$cputype ${MHz}MHz");
				}
			}
		}
		$i=0;
		foreach (@kstat_cpubanners) {
			$kstat_cpubanner .= ", " if ($i);
			$kstat_cpubanner .= $_;
			$i++;
		}
		$kstat_cpubanner=&cleanup_cputype($kstat_cpubanner);
		&pdebug("in check_kstat, kstat_cpubanner=$kstat_cpubanner");
	}
}

sub found_empty_bank {
	$empty_banks .= "," if ($empty_banks);
	$boardslot_mem=~s/[: ]//g;
	$empty_banks .= " Board $boardslot_mem @_";
}

sub print_empty_memory {
	return if (&is_virtualmachine || $empty_memory_printed);
	$s=shift;
	print "empty $s: ";
	$sockets_empty=~s/^\s*//;
	$sockets_empty=~s/^,\s*//;
	print (($sockets_empty) ? "$sockets_empty\n" : "None\n");
	$empty_memory_printed=1;
}

sub print_bios_error {
	return if (&is_virtualmachine);
	print "    An upgraded BIOS from your manufacturer ";
	if (&check_dmidecode_ver != 0) {
		print "or a newer version of dmidecode\n    from ";
		print "$dmidecodeURL ";
	}
	print "may fix this issue.\n    This is a BIOS ";
	print "or dmidecode " if (&check_dmidecode_ver != 0);
	print "bug, not a bug in memconf";
	print " or dmidecode" if (&check_dmidecode_ver == 0);
	print ".\n";
	&check_dmidecode_ver(1);
	$recognized=0;
	$exitstatus=1;
}

sub found_nvsimm_bank {
	$nvsimm_banks .= ", Board $boardslot_mem @_";
}

sub recommend_prtdiag_patch {
	# Sun BugID 4664349
	print "         This may be corrected by installing ";
	if ($osrel eq "5.9") {
		print "Sun patch 113221-03 or 118558-06 or later.\n";
	} elsif ($osrel eq "5.8") {
		print "Sun patch 109873-26 or 111792-11 or later.\n";
	} else {
		print "a Sun patch on this system.\n";
	}
}

sub numerically {
	$a <=> $b;
}

sub alphanumerically {
	local($&, $`, $', $1, $2);
	# Sort numbers numerically
	return $a cmp $b if ($a !~ /\D/ && $b !~ /\D/);
	# Handle things like CH0/D0, p0.d0, DIMM1_A, Board 1,1A
	return $a cmp $b if ($a =~ /[\/\.,_]/ && $b =~ /[\/\.,_]/);
	# Handle things like DIMM 1A
	return $a cmp $b if ($a =~ /\d\D$/ && $b =~ /\d\D$/);
	# Handle things like DIMM 1 BANK A, ..., DIMM 12 BANK D
	if ($a =~ /(.*\D)(\d+)\D+$/) {
		($a1, $a2) = ($1, $2);
		if ($b =~ /(.*\D)(\d+)\D+$/) {
			($b1, $b2) = ($1, $2);
			return $a2 <=> $b2 if ($a1 eq $b1);
		}
	}
	# Handle things like DIMM1, ..., DIMM10
	if ($a =~ /^(\D+)(\d+)\b/) {
		($a1, $a2) = ($1, $2);
		if ($b =~ /^(\D+)(\d+)\b/) {
			($b1, $b2) = ($1, $2);
			return $a2 <=> $b2 if ($a1 eq $b1);
		}
	}
	# Default is to sort alphabetically
	return $a cmp $b;
}

sub lc {
	$s=shift;
	return "" if (! defined($s));
	$s=~tr/[A-Z]/[a-z]/;
	return $s;
}

sub dos2unix {
	# Convert "CR LF" or "CR" to "LF"
	$s=shift;
	$s=~s/\r\n/\n/g;
	$s=~s/\r/\n/g;
	return $s;
}

sub convert_freq {
	($freqx)=@_;
	if ($isX86) {
		$freq=int(hex("0x$freqx") / 10000 + 0.5);
	} else {
		if ($freqx =~ /'/) {
			$freqpack=$freqx;
			$freqpack=~s/'//g;
			@frequnpack=unpack("C*",$freqpack);
			$freqx="";
			foreach $field (@frequnpack) {
				$freqx.=sprintf("%02lx", $field);
			}
			if ($#frequnpack < 3) {
				$freqx.="00";
			}
		}
		$freq=int(hex("0x$freqx") / 1000000 + 0.5);
	}
	return $freq;
}

sub mychomp {
	# Used instead of chop or chomp for compatibility with perl4 and perl5
	($a)=@_;
	return "" if (! defined($a));
	$a=~s,$/$,,g;
	return $a;
}

sub hex2ascii {
	$_=shift;
	return $_ if (! /^0x/);
	s/0x(([0-9a-f][0-9a-f])+)/pack('H*', $1)/ie;
	s/[\x00|\s]+$//;	# remove trailing nulls and spaces
	return $_;
}

sub pdebug {
	if ($debug == 1) {
		print "DEBUG: @_\n";
	} elsif ($debug == 2) {
		printf "DEBUG time %.2f", ((times)[0] - $starttime);
		print ": @_\n";
	}
}

sub run {
	&pdebug("Running @_");
	`@_ 2>&1`;
}

sub read_prtdiag_bank_table {
	# prtdiag Bank Table
	$simmsize=substr($line,33,5);
	if ($simmsize =~ /\dGB/) {
		$simmsize=~s/GB//g;
		$simmsize *= 1024;
	} else {
		$simmsize=~s/MB//g;
	}
	if (! $prtdiag_banktable_has_dimms || $line =~ /  0$/) {
		# Interleave Way = 0
		$simmsize /= 2;
	}
	if ($prtdiag_banktable_has_dimms && $line =~ / 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15/) {
		# Interleave Way = 16
		$simmsize *= 4;
		$intcnt=1;
		push(@simmsizesfound, "$simmsize");
	} elsif ($intcnt) {
		# Interleave Way = 16
		$intcnt++;
		$simmsize *= 4;
	}
	$a=substr($line,9,2);
	$a=~s/ //g;
	$b=substr($line,23,1);
	$sz=&show_memory_label($simmsize);
	$grpsize{$a,$b}=$sz;
	$memlength=length($line);
	if ($memlength > 49) {
		$grpinterleave{$a,$b}=substr($line,49,40) if (substr($line,49,40));
	}
	if ($intcnt == 0) {
		push(@simmsizesfound, "$simmsize");
		$simmsize=&show_memory_label($simmsize) . "  ";
		if (! $prtdiag_banktable_has_dimms) {
			$newline=substr($line,0,38) . "   2x" . substr($simmsize,0,5);
			$newline .= substr($line,42,20) if ($memlength > 38);
		}
	}
	$intcnt=1 if ($prtdiag_banktable_has_dimms && $line =~ / 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15/);
	$intcnt=0 if ($intcnt == 16);
}

sub read_prtdiag_memory_segment_table {
	# prtdiag Memory Segment Table
	$simmsize=($line =~ /\dGB/) ? substr($line,19,1) * 512 : substr($line,19,3) / 2;
	$grp=substr($line,-2,2);
	$grp=~s/ //g;
	if ($grp eq "-") {
		$grp=$grpcnt;
		$grpcnt++;
	}
	push(@simmsizesfound, "$simmsize");
	$simmsize=&show_memory_label($simmsize);
	$grpsize{0,$grp}=$simmsize;
}

$motherboard="";
$realmodel="";
$manufacturer="";
$i=0;
# May not have had permission to run prtconf, so see if prtdiag works
&check_for_prtdiag;
if ($diagbanner) {
	if (! $filename || $SUNWexplo) {
		$model=$platform;
		$model=~s/SUNW,//g;
		$model=~s/ORCL,//g;
	} else {
		$model=$diagbanner;
		$model=~s/ /-/g;
		# define $model for systems with $diagbanner != $model
		$model="Ultra-4" if ($diagbanner =~ /Sun.Enterprise.450\b/);
		$model="Sun-Blade-1000" if ($diagbanner =~ /Sun.Blade.1000\b/);
		$model="Sun-Fire-280R" if ($diagbanner =~ /Sun.Fire.280R\b/);
		$model="Netra t1" if ($diagbanner =~ /Netra.t1\b/);
		$model="Netra-T4" if ($diagbanner =~ /Netra.T4\b/);
		$model="Sun-Blade-100" if ($diagbanner =~ /Sun.Blade.1[05]0\b/);
		$model="Netra-T12" if ($diagbanner =~ /Sun.Fire.V1280\b/);
		$model="Serverblade1" if ($diagbanner =~ /Serverblade1\b/);
		$model="Ultra-Enterprise" if ($diagbanner =~ /Enterprise.(E?[3-6][05]00|10000)\b/);
	}
	# Check model and banner here in case we don't have prtconf data
	&check_model;
	&check_banner;
}
foreach $line (@config) {
	$line=&dos2unix($line);
	$line=&mychomp($line);
	$config_permission=1 if ($line =~ /Node /);
	if ($line =~ /Permission denied/i) {
		$permission_error="ERROR: $line" if (! $diagbanner || ! $prtdiag_has_mem);
	}
	if ($line =~ /(^\[Component\]:\s+Memory|cstm.*selclass qualifier )/) {
		# for HP-UX regression test file
		&hpux_check;
		&hpux_cprop if ($line =~ /^\[Component\]:\s+Memory/);
		&hpux_cstm;
	}
	if ($line =~ /banner-name:/ && ! $banner) {
		$banner=$line;
		$banner=~s/\s+banner-name:\s+//;
		$banner=~s/'//g;
		$banner=~s/SUNW,//g;
		$banner=~s/ORCL,//g;
		$banner=~s/TWS,//g;
		$banner=~s/CYCLE,//g;
		$banner=~s/\s+$//;
		&check_banner;
	}
	if ($line =~ /model:.*AXUS/) {
		# AXUS clones with their name on OBP
		$manufacturer="AXUS";
	}
	if (($line =~ /SUNW,(Ultra-|SPARC|S240|JavaEngine1|Ultra.*[Ee]ngine)/ ||
	    $line =~ /SUNW,(Ultra.*Netra*|Premier-24|UltraAX-|Netra|Grover)/ ||
	    $line =~ /SUNW,(Enchilada|Serverblade1|Enterprise|A[0-9]|T[0-9])/ ||
	    $line =~ /ORCL,SPARC-|Sun.4|SUNW,Axil-|^i86pc|^i86xpv|^i86xen/ ||
	    $line =~ /model:\s+'(SPARC CPU|SPARC CPCI)-/ ||
	    $line =~ /\s+name:.*(SUNW,Sun-|'i86pc'|COMPstation|Tadpole)/ ||
	    $line =~ /\s+name:.*(Auspex|S-4|FJSV,GP|CompuAdd|RDI,)/) &&
	    $line !~ /\s+:Description\s+/ && $line !~ /\s+:*whoami:*\s+/ &&
	    $line !~ /\s+:*impl-arch-name:*\s+/ && $line !~ /Sun 4x Quad/i) {
		$model=$line;
		$model=~s/\s+name:\s+//;
		$model=~s/\s+model:\s+//;
		$model=~s/\s+:binding-name\s+//;
		$model=~s/\s+:PlatformName\s+//;
		$model=~s/'//g;
		$model=~s/\s+$//;
		&check_model;
		if ($line =~ /CompuAdd/) {
			$manufacturer="CompuAdd";
			if ($model eq "SS-2") {
				$banner=$model if (! $banner);
				$bannermore="SPARCstation 2";
				$modelmore="SPARCstation 2";
			}
		}
	}
	$foundname=1 if ($line =~ /\s+name:\s+/);
	if ($line =~ /\s+model:\s+'.+,/ && ! $foundname) {
		# Ultra 5/10 motherboard is 375-xxxx part number
		# SS10/SS20 motherboard is Sxx,501-xxxx part number
		if ($line =~ /,(375|500|501)-/) {
			$motherboard=$line;
			$motherboard=~s/\s+model:\s+//;
			$motherboard=~s/'//g;
		}
	}
	if ($line =~ /\sname:\s+'memory'/) {
		$j=$i - 2;
		if ($config[$j] =~ /\sreg:\s/) {
			$gotmemory=&mychomp($config[$j]);
		} elsif ($config[$j - 1] =~ /\sreg:\s/) {
			$gotmemory=&mychomp($config[$j - 1]);
		} elsif ($config[$j + 1] =~ /\sreg:\s/) {
			$gotmemory=&mychomp($config[$j + 1]);
		}
	}
	if ($line =~ /\sdevice_type:\s+'memory-bank'/) {
		$j=$i - 3;
		if ($config[$j] =~ /\sreg:\s/ && $config[$j] !~ /.00000000$/) {
			$config[$j]=~s/\s+reg:\s+//;
			$gotmemory=($gotmemory) ? "$gotmemory.$config[$j]" : $config[$j];
			$gotmemory=&mychomp($gotmemory);
		}
	}
	# The following is not used yet
	#if ($line =~ /\sdevice_type:\s+'memory-module'/) {
	#	if ($config[$i - 2] =~ /\sreg:\s/) {
	#		$config[$i - 3]=~s/\s+socket-name:\s+//;
	#		if ($gotmodule) {
	#			$gotmodule .= ".$config[$i - 3]";
	#		} else {
	#			$gotmodule=$config[$i - 3];
	#		}
	#		$gotmodule=&mychomp($gotmodule);
	#		$config[$i - 2]=~s/\s+reg:\s+//;
	#		@module=split(/\./, $config[$i - 2]);
	#		$gotmodule .= ".$module[3]";
	#		$gotmodule=&mychomp($gotmodule);
	#		$config[$i + 1]=~s/\s+name:\s+//;
	#		$config[$i + 1] =~ y/[a-z]/[A-Z]/;
	#		$gotmodule .= ".$config[$i + 1]";
	#		$gotmodule=&mychomp($gotmodule);
	#		$gotmodule=~s/'//g;
	#	}
	#}
	if ($line =~ /\ssimm-use:\s+/) {
		# DIMM usage on Fujitsu GP7000
		$gotmodule=&mychomp($config[$i]);
		$gotmodule=~s/\s+simm-use:\s+//;
		$slotname0="SLOT0" if ($banner =~ /GP7000\b/);
	}
	if ($line =~ /\scomponent-name:\s+'.*CPU.*'/) {
		# CPUs on Fujitsu GP7000F and PrimePower systems
		$slotname=$line;
		$slotname=~s/\s+component-name:\s+//;
		$slotname=~s/'//g;
		$gotcpunames=($gotcpunames) ? "$gotcpunames $slotname" : $slotname;
		$boardname=$slotname;
		$boardname=~s/-.*//g;
		if ($boardname ne $slotname) {
			if ($gotcpuboards) {
				$gotcpuboards .= " $boardname" if ($gotcpuboards !~ /\b$boardname\b/);
			} else {
				$gotcpuboards=$boardname;
			}
		}
	}
	if ($line =~ /\sdevice_type:\s+'memory-module'/) {
		# DIMM usage on Fujitsu GP7000F and PrimePower systems
		$slotname="";
		if ($config[$i - 3] =~ /\scomponent-name:\s/) {
			$slotname=$config[$i - 3];
		}
		if ($config[$i - 4] =~ /\scomponent-name:\s/) {
			$slotname=$config[$i - 4];
		}
		if ($slotname) {
			$slotname=~s/\s+component-name:\s+//;
			$slotname=~s/'//g;
			$slotname=&mychomp($slotname);
			$gotmodulenames=($gotmodulenames) ? "$gotmodulenames.$slotname" : $slotname;
			$slotname0=$slotname if (! $slotname0);
			$config[$i - 1]=~s/\s+reg:\s+//;
			@module=split(/\./, $config[$i - 1]);
			$gotmodulenames .= ".$module[1]";
			$gotmodulenames=&mychomp($gotmodulenames);
		}
	}
	if ($line =~ /\sname:\s+'cgfourteen'/) {
		# Determine size of VSIMM
		# Currently assumes only one VSIMM is installed
		if ($config[$i - 2] =~ /\sreg:\s/) {
			$sx_line=&mychomp($config[$i - 2]);
		} elsif ($config[$i - 3] =~ /\sreg:\s/) {
			$sx_line=&mychomp($config[$i - 3]);
		}
		@sxline=split(/\./, $sx_line);
		$sxmem=hex("0x$sxline[5]") / $meg;
	}
	if ($line =~ /501-2197/) {
		# 1MB Prestoserve NVSIMMs (SS1000/SC2000)
		if ($config[$i + 1] =~ /\sreg:\s/) {
			$nv_line=&mychomp($config[$i + 1]);
		} elsif ($config[$i + 2] =~ /\sreg:\s/) {
			$nv_line=&mychomp($config[$i + 2]);
		}
		@nvline=split(/\./, $nv_line);
		$nvmem += hex("0x$nvline[2]") / $meg;
	}
	if ($line =~ /501-2001/) {
		# 2MB Prestoserve NVSIMMs (SS10/SS20)
		if ($config[$i + 1] =~ /\sreg:\s/) {
			$nv_line=&mychomp($config[$i + 1]);
		} elsif ($config[$i + 2] =~ /\sreg:\s/) {
			$nv_line=&mychomp($config[$i + 2]);
		}
		@nvline=split(/\./, $nv_line);
		$nvmem += hex("0x$nvline[2]") / $meg;
		$nvmem1=1 if ($nvline[1] eq "10000000");
		$nvmem2=1 if ($nvline[1] eq "14000000" || $nvline[1] eq "1c000000");
	}
	if ($line =~ /Memory size:\s/ && $installed_memory == 0) {
		$installed_memory=$line;
		$installed_memory=~s/^.*size: *(\d*[GM]*[Bb]*).*/$1/;
		if ($installed_memory =~ /GB/) {
			$installed_memory=~s/GB//g;
			$installed_memory *= 1024;
		} else {
			$installed_memory=~s/MB//ig;
		}
		# prtconf sometimes reports incorrect total memory
		# 32MB is minimum for sun4u machines
		if ($installed_memory < 32 && $machine eq "sun4u") {
			$prtconf_warn="Incorrect total installed memory (${installed_memory}MB) was reported by prtconf.";
			$installed_memory=0;
		}
		# Round up some odd-number total memory values
		$installed_memory++ if (sprintf("%3d", ($installed_memory + 1) / 2) * 2 != $installed_memory && $installed_memory >= 1023);
		$BSD=0;	# prtconf and prtdiag only have this output
		$config_cmd="/usr/sbin/prtconf -vp" if ($config_cmd !~ /prtconf/);
		$config_command="prtconf";
	}
	if ($sysfreq == 0 && $freq) {
		$sysfreq=$freq;
		$freq=0;
	}
	if ($devtype eq "cpu" || $line =~ /compatible: 'FJSV,SPARC64-/) {
		if ($cputype =~ /SPARC64-/) {
			$cpufreq=$freq if ($freq > $cpufreq);
		} else {
			$cpufreq=$freq;
		}
		$cpuline=$line;
		$j=$i - 3;
		while ($cpuline !~ /^$/ && $cpuline !~ /^\r$/) {
			if ($cpuline =~ /clock-frequency:/) {
				@freq_line=split(' ', $cpuline);
				$cpufreq=&convert_freq($freq_line[1]);
				$sysfreq=$freq if ($sysfreq == 0 && $freq);
			} elsif ($cpuline =~ /\s(name:|compatible:)\s/ && $cpuline !~ /Sun 4/ && $cpuline !~ /SPARCstation/ && $cpuline !~ /CompuAdd/ && $cpuline !~ /'cpu/ && $cpuline !~ /'core'/) {
				$cputype=&mychomp($cpuline);
				$cputype=~s/\s+name:\s+//;
				$cputype=~s/\s+compatible:\s+//;
				$cputype=~s/'//g;
				$cputype=~s/SUNW,//g;
				$cputype=~s/ORCL,//g;
				$cputype=~s/FJSV,//g;
				$cputype=~s/ .*//g;
			} elsif ($cpuline =~ /\sname:\s/ && ! $model) {
				$model=&mychomp($cpuline);
				$model=~s/\s+name:\s+//;
				$model=~s/'//g;
				$model=~s/SUNW,//g;
				$model=~s/ORCL,//g;
				$model=~s/FJSV,//g;
			}
			$j++;
			$cpuline=($config[$j]) ? $config[$j] : "";
		}
		$freq=0;
		$cpufreq=$sysfreq if ($sysfreq >= $cpufreq);
		&pdebug("Checking cputype=$cputype, ncpu=$ncpu, threadcnt=$threadcnt");
		if (! $cputype) {
			$cputype=$machine;
			$cputype="SPARC" if ($cputype =~ /^sun4/ || $model =~ /Sun 4\//);
			@bannerarr=split(/\s/, $banner);
			foreach $field (@bannerarr) {
				if ($field =~ /SPARC/ && $field !~ /SPARCstation/) {
					$cputype=$field;
				} elsif ($field =~ /390Z5/) {
					$field="TI,TMS$field" if ($field =~ /^390Z5/);
					$cputype=($cpufreq > 70) ? "SuperSPARC-II $field" : "SuperSPARC $field";
				} elsif ($field =~ /RT62[56]/) {
					$cputype="hyperSPARC $field";
					$machine="sun4m";
				}
			}
			$cputype=~s/[()]//g;
		} elsif ($cputype =~ /MB86907/) {
			$cputype="TurboSPARC-II $cputype";
		} elsif ($cputype =~ /MB86904|390S10/) {
			$cputype=($cpufreq > 70) ? "microSPARC-II $cputype" : "microSPARC $cputype";
		} elsif ($cputype =~ /,RT62[56]/) {
			$cputype="hyperSPARC $cputype";
			$machine="sun4m";
		} elsif ($cputype =~ /UltraSPARC-IV/) {
			# Count Dual-Core US-IV & US-IV+ as 1 CPU
			$cputype="Dual-Core $cputype";
			$machine="sun4u";
			$threadcnt++;
			$threadcnt=0 if ($threadcnt == 2);
			# CPU count is better from prtdiag than psrinfo for
			# US-IV & US-IV+ Dual-Core processors.
			$use_psrinfo_data=0;
		} elsif ($cputype =~ /UltraSPARC-T1$/) {
			# Count 4-Thread (4, 6, or 8 Core) Niagara CPUs as 1 CPU
			$machine="sun4v";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		} elsif ($cputype =~ /UltraSPARC-T2\+/) {
			# Count 8-Thread (4, 6, or 8 Core) Victoria Falls CPUs as 1 CPU
			$machine="sun4v";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		} elsif ($cputype =~ /UltraSPARC-T2$/) {
			# Count 8-Thread (4 or 8 Core) Niagara-II CPUs as 1 CPU
			$machine="sun4v";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		} elsif ($cputype =~ /SPARC-T3$/) {
			# Count 8-Thread (8 or 16 Core) Rainbow Falls CPUs as 1 CPU
			$machine="sun4v";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		} elsif ($cputype =~ /SPARC-T4$/) {
			# Count 8-Thread 8-Core SPARC-T4 CPUs as 1 CPU
			$machine="sun4v";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		} elsif ($cputype =~ /SPARC-T5$/) {
			# Count 8-Thread 16-Core SPARC-T5 CPUs as 1 CPU
			$machine="sun4v";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		} elsif ($cputype =~ /SPARC64-VI$/ && $devtype eq "cpu") {
			# Count Dual-Core Dual-Thread as 1 CPU
			$machine="sun4u";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		} elsif ($cputype =~ /SPARC64-VII\+\+$/ && $devtype eq "cpu") {
			# Count Quad-Core Dual-Thread as 1 CPU
			$machine="sun4u";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		} elsif ($cputype =~ /SPARC64-VII\+$/ && $devtype eq "cpu") {
			# Count Quad-Core Dual-Thread as 1 CPU
			$machine="sun4u";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		} elsif ($cputype =~ /SPARC64-VII$/ && $devtype eq "cpu") {
			# Count Quad-Core Dual-Thread as 1 CPU
			$machine="sun4u";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		} elsif ($cputype eq "SPARC64-VIII" && $devtype eq "cpu") {
			# Guess on the Venus SPARC64-VIII name ???
			# Count 8-Core Dual-Thread as 1 CPU
			$machine="sun4u";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		} elsif ($cputype =~ /SPARC64-X$/ && $devtype eq "cpu") {
			# Count 16-Core Dual-Thread as 1 CPU
			$machine="sun4v";
			$threadcnt++;
			# Number of cores & CPUs counted outside this loop below
		}
		if ($threadcnt == 0 && $devtype eq "cpu") {
			$ncpu++;
			$cpucnt{"$cputype $cpufreq"}++;
			$cpucntfrom=$config_command;
		}
		$devtype="";
		if (! $kernbit) {
			$kernbit=32 if ($machine =~ /sun4[cdm\b]/);
			$kernbit=64 if ($machine eq "sun4v" || $cputype =~ /UltraSPARC-III|UltraSPARC-IV|SPARC64/);
		}
	}
	if ($line =~ /device_type:/) {
		@dev_line=split(/\'/, $line);
		$devtype=$dev_line[1];
	}
	if ($line =~ /clock-frequency:/) {
		@freq_line=split(' ', $line);
		$freq=&convert_freq($freq_line[1]);
	}
	if ($line =~ /\sversion:\s+'OBP/ && ! $romver) {
		$romver=$line;
		$romver=~s/\s+version:\s+//;
		$romver=~s/'//g;
		@romverarr=split(/\s/, $romver);
		$romvernum=$romverarr[1];
	}
	if ($line =~ /compatible:\s+'sun4.'/ && ! $osrel) {
		@compatible_line=split(/\'/, $line);
		$machine=$compatible_line[1];
	}
	if ($line =~ /value='.*AMD Opteron/ && $cputype eq "x86") {
		$cputype_prtconf=$line;
		$cputype_prtconf=~s/.*='//;
		$cputype_prtconf=~s/'//g;
	}
	$i++;
}
&multicore_cpu_cnt;
&check_cpuinfo;
&check_xm_info;
if (! $osrel) {
	if ($BSD) {
		$osrel="4.X";
		$config_cmd="/usr/etc/devinfo -pv";
		$config_command="devinfo";
		$cpucntfrom="devinfo";
#	} elsif ($os =~ /Linux|FreeBSD/) {
#		$osrel="2.X";	# Could also be 3.X Linux kernel, so leave empty
	} else {
		$osrel="5.X";
		$solaris="2.X";
		if ($machine =~ /86/) {
			$solaris .= " X86";
		} elsif ($machine =~ /sun4/) {
			$solaris .= " SPARC";
		}
		$config_cmd="/usr/sbin/prtconf -vp";
		$config_command="prtconf";
	}
}
$memfrom=$config_command;
#$sysfreq=$freq if ($sysfreq == 0 && $freq);
#$cpufreq=$sysfreq if ($sysfreq > $cpufreq && $ncpu);

@romverarr=split(/\./, $romvernum) if ($romver);
$romvermajor=($romverarr[0]) ? $romverarr[0] : 2;
$romverminor=($romverarr[1]) ? $romverarr[1] : 0;
$romverminor=0 if (! $romverminor || $romverminor eq "X");
if ($banner =~ /^ \(/) {
	# banner-name does not include the eeprom banner name. This happens
	# sometimes when OBP 3.23 is installed on Ultra-60/E220R and
	# Ultra-80/E420R systems.
	$bannermore="Ultra 60 or Enterprise 220R" if ($model eq "Ultra-60");
	$bannermore="Ultra 80, Enterprise 420R or Netra t 1400/1405" if ($model eq "Ultra-80");
}
#
# SPARCengine systems
#
$ultra="AX" if ($motherboard =~ /501-3043/);
$ultra="AX-300" if ($motherboard =~ /501-5037/);
$ultra="AXi" if ($motherboard =~ /501-4559/);
$ultra="AXmp" if ($banner =~ /UltraAX-MP/ || $model =~ /UltraAX-MP/ || $motherboard =~ /501-(5296|5487|5670)/);
$ultra="AXmp+" if ($banner =~ /UltraAX-MP\+/ || $model =~ /UltraAX-MP\+/ || $motherboard =~ /501-4324/);
$ultra="AXe" if ($banner =~ /UltraAXe\b/ || $model =~ /UltraAX-e\b/ || $motherboard =~ /375-0088/);
$ultra="AX-e2" if ($banner =~ /Netra AX1105-500\b/ || $model =~ /UltraAX-e2\b/ || $motherboard =~ /375-0128/);
$ultra="Netra X1" if ($banner =~ /Netra X1\b/ || $motherboard =~ /375-3015/);
$ultra="Netra T1 200" if ($banner =~ /Netra T1 200\b/ || $motherboard =~ /375-0132/);
$ultra="Sun Fire V100" if ($banner =~ /Sun Fire V100\b/);
# Sun Fire V120/Netra 120 can use motherboard 375-0132 like Netra T1 200 above
$ultra="Sun Fire V120" if ($banner =~ /Sun Fire V120\b/);
$ultra="Netra 120" if ($banner =~ /Netra 120\b/);
if ($ultra =~ /AX/) {
	if ($banner !~ /SPARCengine.*Ultra/) {
		$tmp="(SPARCengine Ultra $ultra)";
		$bannermore=($bannermore) ? "$tmp $bannermore" : $tmp;
	}
}
if ($model =~ /Ultra-5_10\b/) {
	if ($banner =~ /\bVoyagerIIi\b/) {
		# Tadpole Voyager IIi has 8 DIMM slots, but prtconf reports
		# it as an Ultra 5/10
		$model="VoyagerIIi";
		$ultra="VoyagerIIi";
	}
}
$ultra="Sun Blade 150" if ($banner =~ /Sun Blade 150\b/ || $diagbanner =~ /Sun Blade 150\b/);
$ultra="UP-20" if ($banner =~ /\bUP-20\b/); # untested ???
$ultra="UP-520IIi" if ($motherboard =~ /501-4559/ && $banner =~ /\b520IIi\b/);

$need_obp2=0;
if ($model eq "Sun 4/20" || $model eq "Sun 4/25" || $model eq "Sun 4/40" || $model eq "Sun 4/50" || $model eq "Sun 4/60" || $model eq "Sun 4/65" || $model eq "Sun 4/75" || $model eq "SS-2") {
	$machine="sun4c";
	$need_obp2=1 if ($model eq "Sun 4/40" || $model eq "Sun 4/60" || $model eq "Sun 4/65");
}

&check_prtdiag if ($isX86);
if ($isX86) {
	# Round up Solaris x86 memory (may have 128MB or more reserved)
	$installed_memory=&roundup_memory($installed_memory);
}

if (! $gotmemory && $ultra eq 0 && $machine ne "sun4d" && $boardfound_mem eq 0) {
	&check_prtdiag;
	&show_header;
	if ($installed_memory) {
		print "total memory = ";
		&show_memory($installed_memory);
	}
	print "$permission_error\n" if ($permission_error);
	print "$prtconf_warn\n" if ($prtconf_warn);
	if ($prtdiag_failed == 2) {
		&found_nonglobal_zone;
	} else {
		print "ERROR: no 'memory' line in \"$config_cmd\" output.\n" if ($machine =~ /sun4/);
		if (! $config_permission && $machine =~ /sun4/ && ! $prtconf_warn) {
			print "       This user ";
			print (($permission_error) ? "does" : "may");
			print " not have permission to run $config_command.\n";
			print "       Try running memconf as a privileged user like root.\n" if ($uid ne "0");
		} elsif ($need_obp2) {
			print "       Upgrading from Open Boot PROM V1.X to V2.X will ";
			print "allow memconf to\n       detect the memory installed.\n";
		} elsif ($prtconf_warn =~ /openprom/) {
			print "       Please correct the problem with the openprom device.\n" if ($machine =~ /sun4/);
		} else {
			print "       This is an unsupported system by memconf.\n" if ($machine =~ /sun4/);
		}
	}
	&show_supported if ($machine !~ /sun4/ && $prtdiag_failed != 2);
	$exitstatus=1;
	&mailmaintainer if ($verbose == 3);
	&pdebug("exit $exitstatus");
	exit $exitstatus;
}

$gotmemory=~s/\s+reg:\s+//;
$gotmemory=~s/'//g;
@slots=split(/\./, $gotmemory);
$slot=1;
if ($machine =~ /sun4|i86pc|i86xpv|i86xen/ && $manufacturer && $manufacturer !~ /^Sun\b|^Oracle\b/ && $ultra !~ /SPARC Enterprise M[34589]000 Server/ && ! &is_virtualmachine) {
	$bannermore=($bannermore) ? "$bannermore clone" : "clone" if ($manufacturer ne "Force Computers");
	$modelmore=($modelmore) ? "$modelmore clone" : "clone" if (! $isX86);
	$clone=1;
}
# DIMMs are installed in pairs on Ultra 1, 5 and 10; quads on
# Ultra 2, 60, 80, 220R, 420R, 450; 8's in Ultra Enterprise
#
# On 64-bit systems, prtconf format is AAAAAAAA.AAAAAAAA.SSSSSSSS.SSSSSSSS
# and on 32-bit systems, prtconf format is AAAAAAAA.AAAAAAAA.SSSSSSSS
# where A is for Address, S is for Size.
# Minimum module size is 1MB (0x00100000), so strip off last 5 hex digits of LSB
# and prepend last 5 digits of MSB, which allows recognizing up to 4500TB!
#
if ($ultra) {
	$val0=3;	# simmsize is in 3rd and 4th fields
	$valaddr=2;	# address is 2 fields before simmsize
	$valinc=4;	# fields per simm
	$memtype="DIMM";
} else {
	$val0=2;	# simmsize is in 3rd field
	$valaddr=1;	# address is 1 field before simmsize
	$valinc=3;	# fields per simm
}

#
# Define memory layout for specific systems
#
if ($model eq "Sun 4/20") {
	# SLC accepts 4MB SIMMs on motherboard
	#   501-1676 (4MB 100ns), 501-1698 (4MB 80ns)
	#   33-bit 72-pin Fast Page Mode (36-bit work also)
	# Does not support Open Boot PROM V2.X, so devinfo/prtconf output will
	# not have memory lines.
	$devname="OffCampus";
	$untested=1;
	$simmrangex="00000010";
	$simmbanks=4;
	$simmsperbank=1;
	@simmsizes=(4);
	@socketstr=("U0502","U0501","U0602","U0601");
}
if ($model eq "Sun 4/25") {
	# ELC accepts 4MB or 16MB SIMMs on motherboard
	#   501-1698 or 501-1812 (4MB 80ns), 501-1822 (16MB 80ns)
	#   33-bit 72-pin Fast Page Mode (36-bit work also)
	$devname="NodeWarrior";
	$untested=0;
	$simmrangex="00000010";
	$simmbanks=4;
	$simmsperbank=1;
	@simmsizes=(4,16);
	@socketstr=("U0407".."U0410");
	@bankstr=("MEM1".."MEM4");
}
if ($model eq "Sun 4/40") {
	# IPC accepts 1MB or 4MB SIMMs on motherboard
	#   501-1697 (1MB 80ns), 501-1625 (4MB 100ns), 501-1739 (4MB 80ns)
	# Does not show memory with Open Boot PROM V1.X, but does with OBP V2.X
	$devname="Phoenix";
	$untested=0;
	$simmrangex="00000010";
	$simmbanks=3;
	$simmsperbank=4;
	@simmsizes=(1,4);
	@socketstr=("U0588","U0587","U0586","U0585","U0584","U0591","U0590","U0589","U0678","U0676","U0683","U0677");
	@bankstr=(0,0,0,0,1,1,1,1,2,2,2,2);
	@bytestr=(0..3,0..3,0..3);
}
if ($model eq "Sun 4/50") {
	# IPX accepts 4MB or 16MB SIMMs on motherboard
	#   501-1812 (4MB 80ns), 501-1915 or 501-1822 (16MB 80ns)
	#   33-bit 72-pin Fast Page Mode (36-bit work also)
	$devname="Hobbes";
	$untested=0;
	$simmrangex="00000010";
	$simmbanks=4;
	$simmsperbank=1;
	@simmsizes=(4,16);
	@socketstr=("U0310","U0309","U0308","U0307");
	@bankstr=(0..3);
}
if ($model eq "Sun 4/60" || $model eq "Sun 4/65") {
	# SS1 and SS1+ accepts 1MB or 4MB SIMMs on motherboard
	#   501-1408 (1MB 100ns), 501-1697 (SS1+ only) (1MB 80ns),
	#   501-1625 (4MB 100ns), 501-1739 (4MB 80ns)
	# Does not show memory with Open Boot PROM V1.X, but does with OBP V2.X
	if ($model eq "Sun 4/60") {
		$devname="Campus";
		$untested=0;
	} else {
		$devname="CampusB, Campus+";
		$untested=1;
	}
	$simmrangex="00000010";
	$simmbanks=4;
	$simmsperbank=4;
	@simmsizes=(1,4);
	@socketstr=("U0588","U0587","U0586","U0585","U0584","U0591","U0590","U0589","U0678","U0676","U0683","U0677","U0682","U0681","U0680","U0679");
	@bankstr=(0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3);
	@bytestr=(0..3,0..3,0..3,0..3);
}
if ($model eq "Sun 4/75" || $model eq "SS-2") {
	# SS2 accepts 4MB SIMMs on motherboard and 32MB or 64MB SBus expansion
	# card (501-1823 Primary and 501-1824 Secondary)
	#   501-1739 (4MB 80ns)
	$devname="Calvin";
	$untested=0;
	$simmrangex="00000010";
	$simmbanks=4;
	$simmsperbank=4;
	@simmsizes=(4);
	@socketstr=("U0311","U0309","U0307","U0322","U0312","U0310","U0308","U0321","U0313","U0314","U0315","U0320","U0319","U0318","U0317","U0316");
	@bankstr=(0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3);
	@bytestr=(0..3,0..3,0..3,0..3);
}
if ($model =~ /SPARCclassic|SPARCstation-LX/) {
	# Classic-X (4/10) accepts 1MB, 2MB, 4MB and 16MB SIMMs on motherboard
	# Classic (4/15) and LX (4/30) accepts 4MB and 16MB SIMMs on motherboard
	# Can accept 32MB SIMMs in bank 1, allowing 128MB total (2x32, 4x16)
	# Possibly accepts 8MB SIMMs in bank 1
	#   501-2289 (1MB), 501-2433 (2MB) on Classic-X only
	#   501-1991 (4MB), 501-2059 (16MB)
	#   36-bit 72-pin 60ns Fast Page Mode
	$devname="Sunergy";
	if ($model =~ /SPARCclassic-X/) {
		$untested=1;
		@simmsizes=(1,2,4,8,16,32);
	} else {
		$untested=0;
		@simmsizes=(4,8,16,32);
	}
	$simmrangex="00000020";
	$simmbanks=3;
	$simmsperbank=2;
	@socketstr=("U0304","U0303","U0301","U0302","U0402","U0401");
	@bankstr=(1,1,2,2,3,3);
}
if ($model eq "S240") {
	# Voyager has 16MB on motherboard, plus accepts one or two 16MB or 32MB
	# Memory cards (501-2327 32MB, 501-2366 16MB)
	# Motherboard, address 0x00000000-0x007fffff, 0x01000000-0x017fffff
	# Lower slot=Mem 1, address 0x02000000-0x07ffffff
	# Upper slot=Mem 2, address 0x0a000000-0x0fffffff
	$devname="Gypsy";
	$untested=0;
	$memtype="memory card";
	$sockettype="slot";
	$simmrangex="00000020";
	$simmbanks=8;	# Count the skipped address range
	$simmsperbank=1;
	@simmsizes=(16,32);
	@socketstr=("motherboard","Mem 1","Mem 1","Mem 1","?","Mem 2","Mem 2","Mem 2");
	@orderstr=("","lower slot","lower slot","lower slot","?","upper slot","upper slot","upper slot");
}
if ($model eq "JavaEngine1") {
	# Accepts 8MB, 16MB and 32MB EDO DIMMs
	$devname="Bali";
	$untested=0;
	$memtype="DIMM";
	$simmrangex="00000020";
	$simmbanks=2;
	$simmsperbank=1;
	@simmsizes=(8,16,32);
	@socketstr=("J0501","J0502");
	@bankstr=(0,1);
}
if ($model eq "SPARCstation-4") {
	# Accepts 8MB and 32MB SIMMs on motherboard
	#   501-2470 (8MB), 501-2471 (32MB)
	#   168-pin 60ns Fast Page Mode
	$devname="Perigee";
	$untested=0;
	$simmrangex="00000020";
	$simmbanks=5;
	$simmsperbank=1;
	@simmsizes=(8,32);
	@socketstr=("J0301".."J0305");
	@bankstr=(0..4);
}
if ($model eq "SPARCstation-5" || $model eq "micro COMPstation 5" || $model =~ /Axil-255/ || $banner =~ /TWINstation 5G\b/) {
	# Accepts 8MB and 32MB SIMMs on motherboard
	#   501-2470 (8MB), 501-2471 (32MB)
	#   168-pin 60ns Fast Page Mode
	$devname="Aurora" if ($model eq "SPARCstation-5");
	$untested=0;
	$simmrangex="00000020";
	$simmbanks=8;
	$simmsperbank=1;
	@simmsizes=(8,32);
	@socketstr=("J0300".."J0303","J0400".."J0403");
	@bankstr=(0..7);
	if ($banner =~ /TWINstation 5G\b/) {
		$simmbanks=6;
		@socketstr=(0..5);
	}
	if ($model ne "SPARCstation-5") {
		$bannermore="SPARCstation 5 clone";
		$modelmore="SPARCstation 5 clone";
	}
}
if ($model =~ /SPARCstation-10/ || $model eq "Premier-24" || $motherboard eq "SUNW,S10,501-2365") {
	# Accepts 16MB and 64MB SIMMs on motherboard
	#   501-1785 or 501-2273 (16MB 80ns), 501-2479 (16MB 60ns),
	#   501-2622 (32MB 60ns), 501-1930 (64MB 80ns), 501-2480 (64MB 60ns)
	#   200-pin 60ns or 80ns Fast Page Mode ECC
	# 32MB SIMMs not supported according to Sun, but appears to work fine
	# depending on the OBP revision. OBP 2.12 and older detects the 32MB
	# SIMM as 16MB, OBP 2.19 and later properly detects the 32MB SIMM.
	$devname="Campus2" if ($model =~ /SPARCstation-10/);
	$devname="Campus2+" if ($model =~ /Premier-24/);
	$untested=0;
	$simmrangex="00000040";
	$simmbanks=8;
	$simmsperbank=1;
	$romvernum="2.X" if (! $romvernum);
	$romverminor=0 if (! $romverminor || $romverminor eq "X");
	@simmsizes=(($romvermajor eq 2) && ($romverminor >= 19)) ? (16,32,64) : (16,64);
	@socketstr=("J0201","J0203","J0302","J0304","J0202","J0301","J0303","J0305");
	@orderstr=("1st","3rd","4th","2nd","8th","6th","5th","7th");
	@bankstr=(0..7);
}
if ($model =~ /SPARCstation-20|COMPstation-20S/ || $banner =~ /TWINstation 20G\b/) {
	# Accepts 16MB, 32MB and 64MB SIMMs on motherboard
	#   501-2479 (16MB), 501-2622 (32MB), 501-2480 (64MB)
	#   200-pin 60ns Fast Page Mode ECC
	$devname="Kodiak" if ($model eq "SPARCstation-20");
	$untested=0;
	$simmrangex="00000040";
	$simmbanks=8;
	$simmsperbank=1;
	@simmsizes=(16,32,64);
	@socketstr=("J0201","J0303","J0202","J0301","J0305","J0203","J0302","J0304");
	@orderstr=("1st","2nd","3rd","4th","5th","6th","7th","8th");
	@bankstr=(0..7);
	if ($model !~ /SPARCstation-20/) {
		$bannermore="SPARCstation 20 clone";
		$modelmore="SPARCstation 20 clone";
	}
	if ($model eq "SPARCstation-20I") {
		$bannermore="(SPARCstation-20I) clone";
		$modelmore="clone";
	}
	if ($banner =~ /TWINstation 20G\b/) {
#		@socketstr=("J0201","J0303","J0202","J0301","J0305","J0203","J0302","J0304");
#		@orderstr=("1st","6th","2nd","4th","8th","3rd","5th","7th");
		@socketstr=(0..7);
		@orderstr=("");
	}
}
if ($model eq "SPARCsystem-600" || $model =~ /Sun.4.600/) {
	# Accepts 4MB or 16MB SIMMs on motherboard
	# Accepts 1MB, 4MB or 16MB SIMMs on VME expansion cards
	# A memory bank is 16 SIMMs of the same size and speed
	# Minimum memory configuration is 16 SIMMs in Bank 0 on the motherboard
	# Motherboard Bank 1 must be populated before adding expansion cards
	# Up to two VME memory expansion cards can be added
	# Use 4MB SIMM 501-1739-01 or 501-2460-01
	# Use 16MB SIMM 501-2060-01
	$devname="Galaxy";
	$untested=0;
	$simmrangex="00000100";
	$simmbanks=2; # 2 banks on CPU board, 4 banks on each expansion cards
	$simmsperbank=16;
	@simmsizes=(4,16);
	# Sockets, banks and bytes on motherboard
	@socketstr=("U1107","U1307","U1105","U1305","U1103","U1303","U1101","U1301","U1207","U1407","U1205","U1405","U1203","U1403","U1201","U1401","U1108","U1308","U1106","U1306","U1104","U1304","U1102","U1302","U1208","U1408","U1206","U1406","U1204","U1404","U1202","U1402");
	@bankstr=(0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1);
	@banksstr=("Motherboard bank 0","Motherboard bank 1");
	@bytestr=("0L0","0L1","1L0","1L1","2L0","2L1","3L0","3L1","4L0","4L1","5L0","5L1","6L0","6L1","7L0","7L1","0H0","0H1","1H0","1H1","2H0","2H1","3H0","3H1","4H0","4H1","5H0","5H1","6H0","6H1","7H0","7H1");
	# Sockets, banks and bytes on VME expansion cards
	@socketstr_exp=("U1501","U1503","U1505","U1507","U1601","U1603","U1605","U1607","U1701","U1703","U1705","U1707","U1801","U1803","U1805","U1807","U1502","U1504","U1506","U1508","U1602","U1604","U1606","U1608","U1702","U1704","U1706","U1708","U1802","U1804","U1806","U1808","U1901","U1903","U1905","U1907","U2001","U2003","U2005","U2007","U2101","U2103","U2105","U2107","U2201","U2203","U2205","U2207","U1902","U1904","U1906","U1908","U2002","U2004","U2006","U2008","U2102","U2104","U2106","U2108","U2202","U2204","U2206","U2208");
	@bankstr_exp=("B0","B0","B0","B0","B0","B0","B0","B0","B0","B0","B0","B0","B0","B0","B0","B0","B1","B1","B1","B1","B1","B1","B1","B1","B1","B1","B1","B1","B1","B1","B1","B1","B2","B2","B2","B2","B2","B2","B2","B2","B2","B2","B2","B2","B2","B2","B2","B2","B3","B3","B3","B3","B3","B3","B3","B3","B3","B3","B3","B3","B3","B3","B3","B3");
	@bytestr_exp=("0L0","0L1","1L0","1L1","2L0","2L1","3L0","3L1","4L0","4L1","5L0","5L1","6L0","6L1","7L0","7L1","0H0","0H1","1H0","1H1","2H0","2H1","3H0","3H1","4H0","4H1","5H0","5H1","6H0","6H1","7H0","7H1","8L0","8L1","9L0","9L1","aL0","aL1","bL0","bL1","cL0","cL1","dL0","dL1","eL0","eL1","fL0","fL1","8H0","8H1","9H0","9H1","aH0","aH1","bH0","bH1","cH0","cH1","dH0","dH1","eH0","eH1","fH0","fH1");
}
if ($model eq "Ultra-1" || $ultra eq 1) {
	# Accepts 16MB, 32MB, 64MB or 128MB DIMMs on motherboard
	#   501-2479 (16MB), 501-2622 (32MB), 501-2480 or 501-5691 (64MB),
	#   501-3136 (128MB)
	#   200-pin 60ns Fast Page Mode ECC
	$devname="Neutron (Ultra 1), Electron (Ultra 1E), Dublin (Ultra 150)";
	$familypn="A11 (Ultra 1), A12 (Ultra 1E)";
	$untested=0;
	$simmrangex="00000100";
	$simmbanks=4;
	$simmsperbank=2;
	@simmsizes=(16,32,64,128);
	@socketstr=("U0701","U0601","U0702","U0602","U0703","U0603","U0704","U0604");
	@bankstr=("0L","0H","1L","1H","2L","2H","3L","3H");
	@bytestr=("00-15","16-31","00-15","16-31","00-15","16-31","00-15","16-31");
}
if ($model eq "Ultra-2" || $ultra eq 2) {
	# Accepts 16MB, 32MB, 64MB or 128MB DIMMs on motherboard
	$devname="Pulsar";
	$familypn="A14";
	$untested=0;
	$simmrangex="00000200";
	$simmbanks=4;
	$simmsperbank=4;
	@simmsizes=(16,32,64,128);
	@socketstr=("U0501","U0401","U0701","U0601","U0502","U0402","U0702","U0602","U0503","U0403","U0703","U0603","U0504","U0404","U0704","U0604");
	@groupstr=(0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3);
	@bankstr=("0L","0H","1L","1H","0L","0H","1L","1H","0L","0H","1L","1H","0L","0H","1L","1H");
	@bytestr=("00-15","16-31","32-47","48-63","00-15","16-31","32-47","48-63","00-15","16-31","32-47","48-63","00-15","16-31","32-47","48-63");
}
if ($model eq "Ultra-30" || $ultra eq 30) {
	# Also Netra t 1100
	# Accepts 16MB, 32MB, 64MB or 128MB DIMMs on motherboard
	#   501-2479 (16MB), 501-2622 (32MB), 501-2480 or 501-5691 (64MB),
	#   501-3136 (128MB)
	#   200-pin 60ns Fast Page Mode ECC
	# Two DIMMs form a pair, two pairs of DIMMs form a quad.
	# Minumum requirements is two DIMMs in any adjacent pair.
	# DIMMs can be installed in any order of pairs.
	# Interleaving requires a fully populated quad.
	# Each quad addresses 512MB of memory.
	$devname="Quark (Ultra-30), Lightweight (Netra t 1100)";
	$familypn="A16 (Ultra-30), N01 (Netra t 1100)";
	$untested=0;
	# simmrangex, simmbanks, and simmsperbank set later after determining
	# if interleaving banks using quads rather than pairs
	@simmsizes=(16,32,64,128);
	@socketstr=("U0701","U0801","U0901","U1001","U0702","U0802","U0902","U1002","U0703","U0803","U0903","U1003","U0704","U0804","U0904","U1004");
	@bankstr=("Quad 0 Pair 0","Quad 0 Pair 0","Quad 0 Pair 1","Quad 0 Pair 1","Quad 1 Pair 0","Quad 1 Pair 0","Quad 1 Pair 1","Quad 1 Pair 1","Quad 2 Pair 0","Quad 2 Pair 0","Quad 2 Pair 1","Quad 2 Pair 1","Quad 3 Pair 0","Quad 3 Pair 0","Quad 3 Pair 1","Quad 3 Pair 1");
}
if ($model eq "Ultra-5_10" || $ultra eq "5_10" || $ultra eq 5 || $ultra eq 10) {
	# Accepts 16MB, 32MB, 64MB, 128MB or 256MB DIMMs on motherboard
	# 16MB DIMM uses 10-bit column addressing and was not sold
	# 32, 64, 128 and 256MB DIMMs use 11-bit column addressing
	# Do not mix 16MB DIMMs with other sizes
	# 256MB DIMM not supported in Ultra 5 according to Sun documentation,
	# but they do work as long as you use low-profile DIMMs or take out the
	# floppy drive.
	# Memory speed is 60ns if 50ns and 60ns DIMMs are mixed
	# 2-way interleaving supported with four identical sized DIMMs
	# 50ns DIMMs supported on 375-0066 & 375-0079 motherboards
	# Bank 0 DIMM1/DIMM2 0x00000000-0x0fffffff, 0x20000000-0x2fffffff
	# Bank 1 DIMM3/DIMM4 0x10000000-0x1fffffff, 0x30000000-0x3fffffff
	$devname="Darwin/Otter (Ultra 5), Darwin/SeaLion (Ultra 10)";
	$familypn="A21 (Ultra 5), A22 (Ultra 10)";
	$untested=0;
	$simmrangex="00000100";
	$simmbanks=2;
	$simmsperbank=2;
	@simmsizes=(16,32,64,128,256);
	@socketstr=("DIMM1".."DIMM4");
	@bankstr=("0L","0H","1L","1H");
	$sortslots=0;
}
if ($model eq "Ultra-60" || $ultra eq 60 || $ultra eq "220R") {
	# Also Netra t1120/1125
	# Accepts 16MB, 32MB, 64MB or 128MB DIMMs on motherboard
	#   501-2479 (16MB), 501-2622 (32MB), 501-2480 or 501-5691 (64MB),
	#   501-3136 (128MB)
	#   200-pin 60ns Fast Page Mode ECC
	# U1001-U1004 bank 3 address 0xa0000000-0xbfffffff
	# U0901-U0904 bank 2 address 0x80000000-0x9fffffff
	# U0801-U0804 bank 1 address 0x20000000-0x3fffffff
	# U0701-U0704 bank 0 address 0x00000000-0x1fffffff
	if ($model eq "Ultra-60" || $ultra eq 60) {
		$devname="Deuterium (Ultra-60), Lightweight 2 (Netra t112x)";
		$familypn="A23 (Ultra-60), N02/N04 (Netra t1120), N03 (Netra t1125)";
	}
	if ($ultra eq "220R") {
		$devname="Razor";
		$familypn="A34";
	}
	$untested=0;
	$simmrangex="00000200";
	$simmbanks=6;	# Count the skipped address range
	$simmsperbank=4;
	@simmsizes=(16,32,64,128);
	@socketstr=("U0701".."U0704","U0801".."U0804","?","?","?","?","?","?","?","?","U0901".."U0904","U1001".."U1004");
	@bankstr=(0,0,0,0,1,1,1,1,"?","?","?","?","?","?","?","?",2,2,2,2,3,3,3,3);
}

#
# SPARCengine systems
#
if ($banner =~ /(Netra t1|Ultra CP 1500)\b/ || $ultra eq "Netra t1" || $model eq "Netra t1" || $ultra eq "CP1500" || $ultra eq "Netra ct400" || $ultra eq "Netra ct410" || $ultra eq "Netra ct800" || $ultra eq "Netra ct810") {
	# Netra t1 100/105, Netra ct400/410/800/810, SPARCengine CP1500
	#  Accepts 1 or 2 64MB, 128MB, 256MB or 512MB mezzanine memory cards
	# Netra ct400/800 use the Netra ct1600 DC chassis (N08)
	# Netra ct410/810 use the Netra ct1600 AC chassis (N09)
	# Also used in Sun Fire 12K & Sun Fire 15K
	# Install the highest capacity memory board first
	# The 370-4155 was sold for use in the Netra t1 100/105
	# Up to four 370-4155 256MB memory boards can be installed
	# Only one 370-4155 can be mixed with any other memory boards
	# Cannot distinguish between 4 370-4155 256MB and 2 512MB memory boards
	# Maximum memory: 768MB for 270MHz/33MHz, 1GB for 360MHz/440MHz systems
	#
	#   Top slot ->  64MB    64MB   128MB   128MB   256MB   256MB   512MB
	# Bottom slot   SSF SS  DSF SS  SSF SS  DSF SS  DSF DS  DSF SS  DSF DS
	#       |
	#       v       ------  ------  ------  ------  ------  ------  ------
	#  64MB SSF SS  Y       N       Y       N       N       Y       N
	#  64MB DSF SS  Y       Y       Y       Y       Y       Y       Y
	# 128MB SSF SS  Y       N       Y       N       N       Y       N
	# 128MB DSF SS  Y       Y       Y       Y       Y       Y       Y
	# 256MB DSF SS  Y       Y       Y       Y       Y       Y       Y
	# 512MB DSF DS  Y/N *   Y/N *   Y/N *   Y/N *   Y/N *   Y/N *   Y/N *
	#
	# SSF=single-sided fab, DSF=double-sided fab
	# SS=stuffed on one side, DS=stuffed on both sides
	# * 512MB DSF DS board is supported on 360MHz and 440MHz systems,
	#   512MB DSF DS board is not supported on 270MHz and 333MHz systems
	# Lower board, address 0x00000000-0x0fffffff, 0x20000000-0x2fffffff
	# upper board, address 0x10000000-0x1fffffff, 0x30000000-0x3fffffff
	if ($banner =~ /Netra t1\b/ || $ultra eq "Netra t1" || $model eq "Netra t1") {
		$devname="Flyweight (Model 100), Flapjack (Model 105)";
		$familypn="N07 (Model 100), N06 (Model 105)";
	}
	$devname="Tonga" if ($ultra eq "Netra ct400");
	$devname="Monte Carlo" if ($ultra eq "Netra ct800");
	$familypn="N08" if ($ultra =~ /Netra ct[48]00/);
	if ($ultra =~ /Netra ct[48]10/) {
		$devname="Makaha";
		$familypn="N09";
	}
	$untested=0;
	$untested=1 if ($ultra eq "Netra ct400" || $ultra =~ /Netra ct[48]10/);
	$memtype="memory card";
	$sockettype="";
	$simmrangex="00000100";
	$simmbanks=2;
	$simmsperbank=1;
	@simmsizes=(64,128,256,512);
	@socketstr=("base mezzanine board","additional mezzanine board");
	@orderstr=("lower board","upper board");
	$sortslots=0;
}
if ($banner =~ /Ultra CP 1400\b/ || $ultra eq "CP1400") {
	# Accepts 1 or 2 64MB, 128MB, 256MB or 512MB mezzanine memory cards
	# Has 64MB on-board memory on motherboard
	# Maximum memory: 832MB (64MB motherboard, 512MB bottom, 256MB top)
	#
	#   Top slot ->  64MB    64MB   128MB   128MB   256MB   512MB
	# Bottom slot   SSF SS  DSF SS  SSF SS  DSF SS  DSF SS  DSF DS
	#       |
	#       v       ------  ------  ------  ------  ------  ------
	#  64MB SSF SS  Y       N       Y       N       Y       N
	#  64MB DSF SS  Y       Y       Y       Y       Y       N
	# 128MB SSF SS  Y       N       Y       N       Y       N
	# 128MB DSF SS  Y       Y       Y       Y       Y       N
	# 256MB DSF SS  Y       Y       Y       Y       Y       N
	# 512MB DSF DS  Y       Y       Y       Y       Y       N
	#
	# SSF=single-sided fab, DSF=double-sided fab
	# SS=stuffed on one side, DS=stuffed on both sides
	# 512MB DSF DS board is only supported in bottom slot
	#
	# Motherboard, address 0x00000000-0x03ffffff
	# Upper board, address 0x08000000-0xffffffff, 0x28000000-0x2fffffff
	# Lower board, address 0x10000000-0x17ffffff, 0x30000000-0x37ffffff
	$devname="Casanova";
	$untested=0;
	$memtype="memory card";
	$sockettype="";
	$simmrangex="00000080";
	$simmbanks=3;
	$simmsperbank=1;
	@simmsizes=(64,128,256,512);
	@socketstr=("motherboard","additional mezzanine board","base mezzanine board");
	@orderstr=("","upper board","lower board");
	$sortslots=0;
}
if ($ultra eq "AX" || $ultra eq "AX-300") {
	# SPARCengine Ultra AX and AX-300
	# Accepts 8MB, 16MB, 32MB or 64MB DIMMs on motherboard
	# AX-300 also accepts 128MB DIMMs on motherboard
	$devname="Photon";
	$untested=0;		# unsure if socket order is correct
	$simmrangex="00000200";
	$simmbanks=2;
	$simmsperbank=4;
	@simmsizes=(8,16,32,64,128);
	@socketstr=("U0301".."U0304","U0401".."U0404");
	@bankstr=(0,0,0,0,1,1,1,1);
}
if ($ultra eq "AXi") {
	# SPARCengine Ultra AXi
	# Accepts 8MB, 16MB, 32MB, 64MB or 128MB single or dual bank 10-bit
	#  column address type DIMMs on motherboard in all socket pairs
	# Accepts 8MB, 16MB, 32MB, 64MB, 128MB or 256MB dual bank 11-bit
	#  column address type DIMMs on motherboard in Pairs 0 & 2
	#  (leave Pairs 1 & 3 empty)
	# DIMMs should be chosen as all 10-bit or all 11-bit column address type
	# Use 60ns DIMMs only
	#$devname="unknown";
	$untested=0;
	$simmrangex="00000100";
	$simmbanks=4;
	$simmsperbank=2;
	@simmsizes=(8,16,32,64,128,256);
	@socketstr=("U0404","U0403","U0304","U0303","U0402","U0401","U0302","U0301");
	@bankstr=(0,0,2,2,1,1,3,3);
	$sortslots=0;
}
if ($ultra eq "AXmp" || $ultra eq "AXmp+") {
	# SPARCengine Ultra AXmp
	#  Accepts 8MB, 16MB, 32MB, 64MB or 128MB DIMMs on motherboard
	#  Accepts 256MB dual-bank DIMMs in bank 0 or 1 (not both)
	#  Can't distinguish dual-bank DIMMs from two banks of single bank DIMMs
	# SPARCengine Ultra AXmp+
	#  Accepts 8MB, 16MB, 32MB, 64MB, 128MB or 256MB DIMMs on motherboard
	#  Accepts dual-bank DIMMs in both bank 0 and 1
	#  Can't distinguish dual-bank DIMMs from two banks of single bank DIMMs
	$devname="Crichton";
	$untested=0;
	$simmbanks=2;
	$simmsperbank=8;
	if ($ultra eq "AXmp+") {
		$simmrangex="00000400";
		@simmsizes=(8,16,32,64,128,256);
	} else {
		$simmrangex="00000800";
		@simmsizes=(8,16,32,64,128);
	}
	@socketstr=("U0701".."U0704","U0801".."U0804","U0901".."U0904","U1001".."U1004");
	@bankstr=(0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1);
	$sortslots=0;
}
if ($ultra eq "AXe") {
	# SPARCengine Ultra AXe
	# Accepts 32MB, 64MB, 128MB or 256MB single or dual bank DIMMs
	# DIMMs should be chosen as all 10-bit or all 11-bit column address type
	$devname="Topdog";
	$untested=0;
	$simmrangex="00000100";
	$simmbanks=2;
	$simmsperbank=2;
	@simmsizes=(32,64,128,256);
	@socketstr=("DIMM3","DIMM4","DIMM1","DIMM2");
	@bankstr=(0,0,1,1);
	# Assume stacked DIMMs like AXi since only 128MB DIMMs have been tested
	$sortslots=0;
}
if ($ultra eq "AX-e2") {
	# Netra AX1105-500
	# Accepts up to 4 64MB, 128MB, 256MB or 512MB registered SDRAM PC133
	# DIMMs; 128MB Minimum, 2GB Maximum
	# DIMM0 & DIMM1 form Bank 0, DIMM2 & DIMM3 form Bank 1
	# DIMMs don't have to be installed as pairs
	$devname="Birdsnest Lite";
	$untested=0;
	$simmrangex="00000200";
	$simmbanks=4;
	$simmsperbank=1;
	@simmsizes=(64,128,256,512);
	@socketstr=("DIMM0".."DIMM3");
	@bankstr=(0,0,1,1);
}
if ($ultra eq "Netra X1" || $ultra eq "Sun Fire V100") {
	# Netra X1, Sun Fire V100, UltraAX-i2
	# Accepts up to 4 128MB or 256MB PC133 DIMMs for 1GB maximum
	# 500MHz model also accepts up to 4 512MB PC133 DIMMs for 2GB maximum
	# Have seen slower models also work with 512MB DIMMs for 2GB maximum
	# Sun Fire V100 is 500MHz only
	# The memory installation sequence is Slot 3, 2, 1, and 0.
	# Each DIMM slot addresses 512MB with 400MHz UltraSPARC IIe
	# Each DIMM slot addresses 1GB with >= 550MHz UltraSPARC IIe
	# Memory is SDRAM PC133 CL=3 ECC registered
	# When equal size DIMMs are installed, the lowest slot number is
	#  mapped to the lowest address range.
	# When mixed size DIMMs are installed, the slot number with the largest
	#  size DIMM is mapped to the lowest address range.
	$devname="Flapjack-lite" if ($ultra eq "Netra X1");
	$devname="Flapjack-liteCD500" if ($ultra eq "Sun Fire V100");
	$familypn="N19";
	$untested=0;
	$simmrangex=($cpufreq > 520) ? "00000400" : "00000200";
	$simmbanks=4;
	$simmsperbank=1;
	@simmsizes=(128,256,512);
	@socketstr=("DIMM0".."DIMM3");
}
if ($ultra eq "Netra T1 200" || $ultra eq "Sun Fire V120" || $ultra eq "Netra 120") {
	# Netra T1 200, Sun Fire V120, Netra 120, UltraAX-i2
	# Accepts up to 4 256MB, 512MB or 1GB PC133 DIMMs for 4GB maximum
	# Sun Fire V120 is 550MHz or 650MHz
	# Netra 120 is same platform as Sun Fire V120, but is 650MHz only
	# Memory is SDRAM PC133 CL=3 ECC registered
	# The minimum memory requirement is one DIMM in Slot 0
	# The memory installation sequence is Slot 0, 1, 2, 3
	# Each DIMM slot addresses 512MB of memory with 500MHz UltraSPARC IIe
	# Each DIMM slot addresses 1GB of memory with >= 550MHz UltraSPARC IIe
	# When equal size DIMMs are installed, the lowest slot number is
	#  mapped to the lowest address range.
	# When mixed size DIMMs are installed, the slot number with the largest
	#  size DIMM is mapped to the lowest address range.
	if ($ultra eq "Netra T1 200") {
		$devname="Flapjack2";
		$familypn="N21";
	}
	if ($ultra eq "Sun Fire V120" || $ultra eq "Netra 120") {
		$devname="Flapjack2+";
		$familypn="N25";
	}
	$untested=0;
	$simmrangex=($cpufreq > 520) ? "00000400" : "00000200";
	$simmbanks=4;
	$simmsperbank=1;
	@simmsizes=(256,512,1024);
	@socketstr=("DIMM0".."DIMM3");
}
if ($banner =~ /\bCP2000\b/ || $ultra =~ /^CP2[01]\d0$/) {
	# Netra CP2000/CP2100 Series CompactPCI Boards (UltraSPARC-IIe)
	# CP2040 (SUNW,UltraSPARC-IIe-NetraCT-40) supports 256MB, 512MB, and 1GB
	# CP2060 (SUNW,UltraSPARC-IIe-NetraCT-60) has non-expandable 512MB
	# CP2080 (SUNW,UltraSPARCengine_CP-80) supports 256MB, 512MB, and 1GB
	# CP2140 (SUNW,UltraSPARCengine_CP-40) supports 512MB, 1GB and 2GB
	# CP2160 (SUNW,UltraSPARCengine_CP-60) supports 1GB and 2GB
	# 256MB Single-Wide module 375-3024
	# 512MB Single-Wide module 375-3025
	# 1GB Double-Wide module 375-3026
	# 1GB Single-Wide module 375-3125
	# 2GB Double-Wide module 375-3114
	# Max number of stacked memory boards is two
	# Install double wide memory first, then single wide memory
	$devname="Othello" if ($ultra eq "CP2040");
	$devname="Sputnik Bluesky" if ($ultra eq "CP2060");
	$devname="Sputnik Orion" if ($ultra eq "CP2080");
	$devname="Othello+" if ($ultra eq "CP2140");
	$devname="Sputnik+" if ($ultra eq "CP2160");
	$untested=1;
	$untested=0 if ($ultra eq "CP2140");
	if ($ultra eq "CP2060") {
		$memtype="embedded memory";
		$sockettype="";
		$simmrangex="00001000";
		$simmbanks=1;
		$simmsperbank=1;
		@simmsizes=(512);
	} else {
		$memtype="memory card";
		$sockettype="";
		$simmrangex="00001000";
		$simmbanks=2;
		$simmsperbank=1;
		if ($ultra eq "CP2140") {
			@simmsizes=(512,1024,2048);
		} elsif ($ultra eq "CP2160") {
			@simmsizes=(1024,2048);
		} else {
			@simmsizes=(256,512,1024);
		}
		@socketstr=("base mezzanine board","additional mezzanine board");
		@orderstr=("lower board","upper board");
		$sortslots=0;
	}
}

#
# Clones: most do not have verbose output since I don't have any socket data
# on them
#
if ($ultra eq "axus250" || $modelmore =~ /Ultra-250/) {
	# AXUS Microsystems, Inc. http://www.axus.com.tw
	# AXUS 250 clone
	# accepts up to 128MB DIMMs on motherboard
	$untested=0;
	$simmrangex="00000200";
	$simmbanks=4;
	$simmsperbank=4;
	@simmsizes=(8,16,32,64,128);
	@socketstr=("U0501","U0601","U0701","U0801","U0502","U0602","U0702","U0802","U0503","U0603","U0703","U0803","U0504","U0604","U0704","U0804");
	@bankstr=(0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3);
}
if ($model =~ /SPARC (CPU|CPCI)-/) {
	# Force Computers, http://www.forcecomputers.com
	# model format: "SPARC CPU-5V/64-110-X" for 64MB w/ 110MHz CPU
	$untested=1;
	$untested=0 if ($model =~ /SPARC CPU-/);
	if ($model =~ /\/${installed_memory}-/) {
		$totmem=$installed_memory;
		push(@simmsizesfound, "$totmem");
		$buffer="motherboard contains ${totmem}MB on-board memory\n";
		&finish;
	}
}
if ($model =~ /Axil/) {
	# RAVE Computer Association, http://rave.com
	$untested=1;
	$untested=0 if ($model =~ /Axil-(245|255|311|320)/);
}
if ($manufacturer =~ /Tadpole/) {
	# Tadpole RDI, http://www.tadpole.com
	$untested=1;
	$untested=0 if ($banner =~ /Tadpole S3|\bVoyagerIIi\b|\bCycleQUAD\b/);
	$untested=0 if ($model =~ /PowerLite-170/);
	if ($ultra eq "UP-20") {
		# Cycle UP-20 to upgrade SPARCstation 5/20 motherboards
		# Accepts 16MB, 32MB and 64MB SIMMs from SPARCstation 20
		# Install SIMMs in pairs to form each bank
		$untested=1;
		$simmrangex="00000040";
		$simmbanks=4;
		$simmsperbank=2;
		@simmsizes=(16,32,64);
		@bankstr=(0,0,1,1,2,2,3,3);
	}
	if ($ultra eq "UP-520IIi") {
		# Cycle UP-520-IIi to upgrade SPARCstation 5/20 motherboards
		# Accepts 8MB, 16MB, 32MB, 64MB, 128MB and 256MB DIMMs
		$untested=0;
		$simmrangex="00000200";
		$simmbanks=4;
		$simmsperbank=2;
		@simmsizes=(8,16,32,64,128,256);
		@socketstr=("J301".."J304");
		@bankstr=(0,0,1,1);
	}
	if ($banner =~ /\bSPARCLE\b/) {
		# UltraSPARC-IIe at 440MHz, 500MHz, or 650MHz
		# 256MB - 2GB ECC SDRAM, two slots, PC-133, 144-pin SO-DIMMs
		$untested=0;
		$simmbanks=2;
		$simmsperbank=1;
		@simmsizes=(128,256,512,1024);
		@socketstr=("DIMM0","DIMM1");
		$memtype="SO-DIMM";
	}
}
if ($manufacturer eq "Auspex") {
	# Auspex Netserver, http://www.auspex.com
	$memtype="Memory Module";
	$untested=1;
	$untested=0 if ($model eq "SPARC Processor");
	if ($osrel =~ /^5./) {
		$untested=1;	# Untested with Solaris 2.X
		$untested_type="OS";
	}
}
if ($manufacturer =~ /Fujitsu/) {
	# Hal Computer Systems, a Fujitsu Company, http://www.hal.com
	# Fujitsu Siemens, http://www.fujitsu-siemens.com
	$untested=1;
	$untested=0 if ($model =~ /S-4\/10H|S-4\/20[ABLH]/);
	if ($banner =~ /(GP7000|GP7000F)\b/) {
		$untested=0;
		if ($slotname0 =~ /SLOT[0-9]/) {
			# M200
			# Up to 4GB of memory
			# System board has 16 DIMM slots, #00 - #15
			# Banks - 0,0,1,1,2,2,2,2,3,3,3,3,4,4,4,4
			# First Modules installed in Bank 0, slots 0-1
			# Second Modules Installed in Bank 1, slots 2-3
			# Modules in Bank 0 and 1 must be same size
			# Subsequent memory expansion installed in sets of four
			#   modules in Bank 2 - 4 (Slots 4-7, 8-11, 12-15)
			@socketstr=("SLOT0".."SLOT9","SLOT10".."SLOT15");
		}
		if ($slotname0 =~ /SLOT[AB][0-9]/) {
			# M400 and M600
			# Up to 4GB of memory
			# System board has 32 DIMM slots, #00 - #15 Group A & B
			# Banks - 0,0,1,1,2,2,2,2,3,3,3,3,4,4,4,4
			# First Modules installed in Bank 0 Group A, slots 0-1
			# Second Modules installed in Bank 0 Group B, slots 0-1
			# Modules in Group A and B must be same size
			# Next memory expansion installs in Bank 1 Group A & B,
			#   slots 2-3 using modules of same size as Bank 0
			# Subsequent memory expansion installed in sets of eight
			#   modules in Bank 2 - 4 (Slots 4-7, 8-11, 12-15) in
			#   both Group A and B
			@socketstr=("SLOTA0".."SLOTA9","SLOTA10".."SLOTA15","SLOTB0".."SLOTB9","SLOTB10".."SLOTB15");
		}
	}
	if ($banner =~ /PRIMEPOWER *100N?\b/) {
		# PRIMEPOWER100N, 1U rack mount
		# Up to 2GB of memory
		# 4 memory module slots
		# 100MHz SDRAM ECC
		# Mount memory modules in order from memory module slot 0
		$untested=1;
	}
	if ($banner =~ /PRIMEPOWER *[246]00\b/) {
		# Up to 8GB of memory
		# Each system board has 16 DIMM slots, #00 - #15
		# Four banks of 4 (0-3,4-7,8-11,12-15)
		# PrimePower 200 and 400 use 1 system board
		# PrimePower 600 uses 2 system boards (00, 01)
		$untested=0;
		foreach $brd ("00","01") {
			if ($gotcpuboards =~ /\b$brd\b/) {
				if ($gotmodulenames =~ /${brd}-SLOT[0-9]/) {
					foreach $i (0..15) {
						push(@socketstr, ("${brd}-SLOT$i"));
					}
				}
			}
		}
	}
	if ($banner =~ /PRIMEPOWER *(800|1000|2000)\b/) {
		# 1-4 SPARC64 GP CPUs / system board
		# PrimePower 800 can have 4 system boards per system
		# PrimePower 1000 can have 8 system boards per system
		# PrimePower 2000 can have 32 system boards per system
		# Minimum Memory: 1GB / system board, 2GB / system
		# Maximum Memory: 8GB / system board, 32GB / system
		# 32 or 16 memory modules per system board, installed in quads
		$untested=0;
		@simmsizes=(128,256,512);
		foreach $brd ("00".."77") {
			if ($gotcpuboards =~ /\b$brd\b/) {
				if ($gotmodulenames =~ /${brd}-SLOT#[AB][0-9]/) {
					foreach $j ("A","B") {
						foreach $i ("00".."03","10".."13","20".."23","30".."33") {
							push(@socketstr, ("${brd}-SLOT#$j$i"));
						}
					}
				}
			}
		}
	}
	if ($banner =~ /PRIMEPOWER *250\b/) {
		# Pedestal, 2U or 4U rack mount
		# 1-2 SPARC64 V processors at 1.1GHz, 1.32GHz, 1.87GHz
		# 1GB-16GB DDR-SDRAM memory with ECC, 2-way, 8 DIMM slots
		$untested=0;
		@simmsizes=(256,512,1024,2048);
		foreach $i ("00".."07") {
			push(@socketstr, ("SLOT#$i"));
		}
	}
	if ($banner =~ /PRIMEPOWER *450\b/) {
		# Pedestal, 4U or 7U rack mount
		# 1-4 SPARC64 V processors at 1.1GHz, 1.32GHz, 1.87GHz
		# 1GB-32GB DDR-SDRAM memory with ECC, 4-way, 16 DIMM slots
		$untested=0;
		@simmsizes=(256,512,1024,2048);
		foreach $i ("00".."15") {
			push(@socketstr, ("SLOT#$i"));
		}
	}
	if ($banner =~ /PRIMEPOWER *[68]50\b/) {
		# PrimePower 650: 2-8 SPARC64 V processors at 1.1GHz or faster
		#   2GB-64GB memory, 8-way, 1 system board, 8U rack mount
		# PrimePower 850: 4-16 SPARC64 V processors at 1.1GHz or faster
		#   2GB-128GB memory, 16-way, 2 system boards, 16U rack mount
		# Uses DDR SDRAM ECC memory in 256MB, 512MB and 1GB sizes
		# Each system board has 32 memory module slots, layed out
		# with 4 DIMMs on 8 DIMM riser cards.
		$untested=0;
		@simmsizes=(256,512,1024,2048);
		foreach $brd ("C0S00","C0S01") {
			if ($gotcpuboards =~ /\b$brd\b/) {
				if ($gotmodulenames =~ /${brd}-SLOT#[A-D][0-9]/) {
					foreach $j ("A".."D") {
						foreach $i ("00".."07") {
							push(@socketstr, ("${brd}-SLOT#$j$i"));
						}
					}
				}
			}
		}
	}
	if ($banner =~ /PRIMEPOWER *(HPC2500|900|[12]500)\b/) {
		# SPARC64 V CPUs at 1.3GHz or 1.89GHz
		# PRIMEPOWER HPC2500 / 2500
		#   2-8 CPUs / system board, 64-128 / system
		#   Up to 16 8-way system boards / system
		#   Up to 1024GB DDR-SDRAM memory with ECC, 128-way
		#   Minimum Memory: 4GB / system board, 4GB / system
		#   Maximum Memory: 64GB / system board, 1024GB / system
		# PRIMEPOWER 900
		#   17U rack mount
		#   1-8 CPUs / system board, 1-16 / system
		#   Up to 2 8-way system boards / system
		#   Up to 128GB DDR-SDRAM memory with ECC, 8-way
		#   Minimum Memory: 2GB / system board, 2GB / system
		#   Maximum Memory: 64GB / system board, 128GB / system
		# PRIMEPOWER 1500
		#   1-8 CPUs / system board, 1-32 / system
		#   Up to 4 8-way system boards / system
		#   Up to 256GB DDR-SDRAM memory with ECC, 8-way
		#   Minimum Memory: 2GB / system board, 2GB / system
		#   Maximum Memory: 64GB / system board, 256GB / system
		$untested=0;
		@simmsizes=(256,512,1024,2048);
		foreach $cab ("C0S","C1S") {
			foreach $brd ("00".."07") {
				if ($gotcpuboards =~ /\b$cab$brd\b/) {
					foreach $j ("A","B") {
						foreach $i ("00".."15") {
							push(@socketstr, ("$cab${brd}-SLOT#$j$i"));
						}
					}
				}
			}
		}
	}
}
if ($model =~ /COMPstation.10/) {
	# Tatung Science and Technology, http://www.tsti.com
	# Accepts 16MB and 64MB SIMMs on motherboard
	# Bank 0 must be filled first
	# Layout is like SPARCstation-10, but I don't know if it can accept
	# 32MB SIMMs or NVSIMMs
	$untested=0;
	$simmrangex="00000040";
	$simmbanks=8;
	$simmsperbank=1;
	@simmsizes=(16,64);
	@socketstr=("J0201","J0203","J0302","J0304","J0202","J0301","J0303","J0305");
	@bankstr=(0,2,4,6,1,3,5,7);
}
if ($model =~ /COMPstation-20A\b/) {
	# Tatung Science and Technology, http://www.tsti.com
	# Accepts 16MB, 32MB and 64MB SIMMs on motherboard
	$untested=1;
	$simmrangex="00000040";
	$simmbanks=8;
	$simmsperbank=1;
	@simmsizes=(16,32,64);
	@socketstr=("J0201","J0304","J0203","J0302","J0303","J0301","J0305","J0202");
	@orderstr=("1st","2nd","3rd","4th","5th","6th","7th","8th");
	@bankstr=(1..8);
}
if ($model =~ /COMPstation-20AL/) {
	# Tatung Science and Technology, http://www.tsti.com
	# Accepts 16MB, 32MB and 64MB SIMMs on motherboard
	$untested=0;
	$simmrangex="00000040";
	$simmbanks=8;
	$simmsperbank=1;
	@simmsizes=(16,32,64);
	@socketstr=("J0201","J0203","J0302","J0304","J0202","J0301","J0303","J0305");
	@orderstr=("1st","2nd","3rd","4th","5th","6th","7th","8th");
	@bankstr=(0..7);
}
if ($banner =~ /COMPstation_U(60|80D)_Series/) {
	# Tatung Science and Technology, http://www.tsti.com
	# Accepts 16MB, 32MB, 64MB, 128MB or 256MB DIMMs on motherboard
	# 4 banks with 4 DIMMs per bank
	$untested=0;
	if ($banner =~ /COMPstation_U60_Series/) {
		$simmrangex="00000200"; # use "00000400" with 256MB DIMMs
		$simmbanks=6;	# Count the skipped address range
	} else {
		$simmrangex="00000400";
		$simmbanks=4;
	}
	$simmsperbank=4;
	@simmsizes=(16,32,64,128,256);
}
if ($model =~ /\bVoyagerIIi\b/) {
	# Tadpole Voyager IIi has 8 DIMM slots, but otherwise appears
	# to look like an Ultra 5. It allows 256MB to 1GB of memory.
	$untested=0;
	$simmrangex="00000100";
	$simmbanks=4;
	$simmsperbank=2;
	@simmsizes=(16,32,64,128);
	@socketstr=("DIMM1","DIMM2","DIMM5","DIMM6","DIMM3","DIMM4","DIMM7","DIMM8");
	$sortslots=1;
}

#
# systems below may have memory information available in prtdiag output
#
if ($model eq "SPARCserver-1000" || $model eq "SPARCcenter-2000") {
	$devname="Scorpion" if ($model eq "SPARCserver-1000");
	$devname="Scorpion+" if ($banner =~ "1000E");
	$devname="Dragon" if ($model eq "SPARCcenter-2000");
	$devname="Dragon+" if ($banner =~ "2000E");
	# Accepts 8MB and 32MB SIMMs on motherboard
	$untested=0;
	@simmsizes=(8,32);
	$prtdiag_has_mem=1;
	&check_prtdiag;
	if ($boardfound_mem) {
		$memfrom="prtdiag";
		&pdebug("displaying memory from prtdiag");
		foreach $line (@boards_mem) {
			if ($line =~ /Board/) {
				$boardslot_mem=substr($line,5,1);
				$simmsize=int substr($line,46,3) / 4;
				if ($simmsize == 0) {
					&found_empty_bank("Group 0");
				} elsif ($simmsize == 1) {
					&found_nvsimm_bank("Group 0");
				} else {
					push(@simmsizesfound, "$simmsize");
				}
				$simmsize=int substr($line,54,3) / 4;
				if ($simmsize == 0) {
					&found_empty_bank("Group 1");
				} elsif ($simmsize == 1) {
					&found_nvsimm_bank("Group 1");
				} else {
					push(@simmsizesfound, "$simmsize");
				}
				$simmsize=int substr($line,62,3) / 4;
				if ($simmsize == 0) {
					&found_empty_bank("Group 2");
				} elsif ($simmsize == 1) {
					&found_nvsimm_bank("Group 2");
				} else {
					push(@simmsizesfound, "$simmsize");
				}
				$simmsize=int substr($line,70,3) / 4;
				if ($simmsize == 0) {
					&found_empty_bank("Group 3");
				} elsif ($simmsize == 1) {
					&found_nvsimm_bank("Group 3");
				} else {
					push(@simmsizesfound, "$simmsize");
				}
			}
		}
		&show_header;
		print @boards_mem;
		print "Each memory unit group is comprised of 4 SIMMs\n";
		$empty_banks=" None" if (! $empty_banks);
		print "empty memory groups:$empty_banks\n";
	} else {
		&show_header;
		$recognized=0;
	}
	$totmem=$installed_memory;
	&finish;
	&pdebug("exit");
	exit;
}
if ($model eq "Ultra-4" || $ultra eq 450 || $model eq "Ultra-4FT" || $ultra eq "Netra ft1800") {
	# Accepts 32MB, 64MB, 128MB or 256MB DIMMs on motherboard
	# 16MB DIMMs are not supported and may cause correctable ECC errors
	#   501-2622 (32MB), 501-2480 or 501-5691 (64MB), 501-3136 (128MB),
	#   501-4743 or 501-5896 (256MB)
	#   200-pin 60ns Fast Page Mode ECC
	# Netra ft1800 is based on Ultra 450
	$devname="Tazmo (Tazmax/Tazmin)";
	$familypn="A20, A25";
	$familypn="N05" if ($model eq "Ultra-4FT" || $ultra eq "Netra ft1800");
	$untested=0;
	$simmrangex="00000400";
	$simmbanks=4;
	$simmsperbank=4;
	@simmsizes=(16,32,64,128,256);
	@socketstr=("U1901".."U1904","U1801".."U1804","U1701".."U1704","U1601".."U1604");
	@groupstr=("A","A","A","A","B","B","B","B","C","C","C","C","D","D","D","D");
	@bankstr=(2,2,2,2,3,3,3,3,0,0,0,0,1,1,1,1);
}
if ($model eq "Ultra-250" || $ultra eq 250) {
	# Accepts 16MB, 32MB, 64MB, or 128MB DIMMs on motherboard
	#   501-2479 (16MB), 501-2622 (32MB), 501-2480 or 501-5691 (64MB),
	#   501-3136 (128MB)
	#   200-pin 60ns Fast Page Mode ECC
	$devname="Javelin";
	$familypn="A26";
	$untested=0;
	$simmrangex="00000200";
	$simmbanks=4;
	$simmsperbank=4;
	@simmsizes=(16,32,64,128);
	@socketstr=("U0701","U0801","U0901","U1001","U0702","U0802","U0902","U1002","U0703","U0803","U0903","U1003","U0704","U0804","U0904","U1004");
	@bankstr=("A","A","A","A","B","B","B","B","C","C","C","C","D","D","D","D");
}
if ($model eq "Ultra-80" || $ultra eq 80 || $ultra eq "420R" || $ultra eq "Netra t140x") {
	# Accepts 64MB or 256MB DIMMs
	#   501-5691 (64MB), 501-4743 501-5936 501-6005 501-6056 (256MB)
	#   200-pin 60ns 5V Fast Page Mode ECC, 576 bits data width
	# 64MB DIMMs same as in Ultra-60, 256MB DIMMs same as in Enterprise-450
	# U0403,U0404,U1403,U1404 bank 3 address 0xc0000000-0xffffffff
	# U0303,U0304,U1303,U1304 bank 2 address 0x80000000-0xbfffffff
	# U0401,U0402,U1401,U1402 bank 1 address 0x40000000-0x7fffffff
	# U0301,U0302,U1301,U1302 bank 0 address 0x00000000-0x3fffffff
	# The minimum requirement is four DIMMs in any bank. The recommended
	# installation sequence is Bank 0,2,1,3. DIMMs are required on both the
	# Riser Board (U0[34]0?) and the System Board (U1[34]0?). Two-way and
	# four-way memory bank interleaving is supported. Memory is 2-way
	# interleaved when the same size DIMMs are installed in Banks 0 and 1.
	# Memory is 4-way interleaved when the same size DIMMs are installed in
	# Banks 0, 1, 2 and 3.
	#
	# prtconf does not reliably show the size of DIMMs in each slot when
	# 1GB of total memory is installed. It shows this:
	#  reg: 00000000.00000000.00000000.40000000
	# A system with 1GB is reported as having 4 256MB DIMMs, but may be
	# using 16 64MB DIMMs in a 4-way interleave.
	# This is an issue that Sun could fix in the OBP.
	# It is broken with OBP 3.33.0 2003/10/07 (patch 109082-06) and older.
	# prtfru (Solaris 8 and later) also does not work.
	#
	# Sun shipped U80 1GB configurations w/ 4x256MB DIMMs
	# Sun shipped U80 256MB configurations w/ 4x64MB DIMMs
	# Sun shipped E420R with 501-5936 256MB DIMMs
	# 64MB DIMM 501-2480 and 128MB DIMM 501-3136 are not supported.
	# 16MB and 32MB DIMMs are not sold for the Ultra 80.
	#
	$devname="Quasar (U80), Quahog (420R), Lightweight 3 (Netra t140x)";
	$familypn="A27 (U80), A33 (420R), N14 (Netra t1405), N15 (Netra t1400)";
	if ($ultra eq 80) {
		$devname="Quasar";
		$familypn="A27";
	}
	if ($ultra eq "420R") {
		$devname="Quahog";
		$familypn="A33";
	}
	if ($ultra eq "Netra t140x") {
		$devname="Lightweight 3";
		$familypn="N14 (Netra t1405), N15 (Netra t1400)";
	}
	$untested=0;
	$simmrangex="00000400";
	$simmbanks=4;
	$simmsperbank=4;
	@simmsizes=(64,256); # Sun only supports 64MB and 256MB DIMMs
	@socketstr=("U0301","U0302","U1301","U1302","U0401","U0402","U1401","U1402","U0303","U0304","U1303","U1304","U0403","U0404","U1403","U1404");
	@bankstr=(0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3);
}
if ($ultra eq "Sun Blade 1000" || $ultra eq "Sun Blade 2000" || $ultra eq "Sun Fire 280R" || $ultra eq "Netra 20") {
	# Accepts up to 8 128MB, 256MB, 512MB, 1GB or 2GB DIMMs installed in
	#  groups of four DIMMs per bank on motherboard
	# Uses 232-pin 3.3V ECC 7ns SDRAM
	# J0407 Group 1 Bank 1/3 address 0x0fa000000 - 0x1f3ffffff
	# J0406 Group 0 Bank 0/2 address 0x000000000 - 0x0f9ffffff
	# J0305 Group 1 Bank 1/3 address 0x0fa000000 - 0x1f3ffffff
	# J0304 Group 0 Bank 0/2 address 0x000000000 - 0x0f9ffffff
	# J0203 Group 1 Bank 1/3 address 0x0fa000000 - 0x1f3ffffff
	# J0202 Group 0 Bank 0/2 address 0x000000000 - 0x0f9ffffff
	# J0101 Group 1 Bank 1/3 address 0x0fa000000 - 0x1f3ffffff
	# J0100 Group 0 Bank 0/2 address 0x000000000 - 0x0f9ffffff
	# The minimum memory requirement is four DIMMs in any Group
	# DIMMs can be installed in any group order
	# Each group addresses 4GB of memory
	# Memory slots (Jxxxx) map to same-numbered DIMMs (Uxxxx)
	# For maximum 4-way interleaving, install 8 DIMMs of identical sizes
	$devname="Excalibur (Sun Blade 1000), Littleneck (Sun Fire 280R), Lightweight 2+ (Netra 20/Netra T4), Sun Blade 2000 (Sun Blade 2000)";
	$familypn="A28 (Sun Blade 1000), A35 (Sun Fire 280R), N28 (Netra 20/Netra T4), A29 (Sun Blade 2000)";
	if ($ultra eq "Sun Blade 1000") {
		$devname="Excalibur (Sun Blade 1000), Sun Blade 2000 (Sun Blade 2000)";
		$familypn="A28 (Sun Blade 1000), A29 (Sun Blade 2000)";
	}
	if ($ultra eq "Sun Fire 280R") {
		$devname="Littleneck";
		$familypn="A35";
	}
	if ($ultra eq "Netra 20") {
		$devname="Lightweight 2+";
		$familypn="N28";
	}
	if ($ultra eq "Sun Blade 2000") {
		$devname="Sun Blade 2000";
		$familypn="A29";
	}
	$untested=0;
	# SB1000/2000 uses 501-4143, 501-5938, 501-6230 or 501-6560 motherboards
	# SB1000 can use 600, 750 and 900MHz UltraSPARC-III CPUs
	# SB1000 can use 900MHz and faster UltraSPARC-III+ Cu CPUs
	# SB2000 only shipped with 900MHz and faster UltraSPARC-III+ Cu CPUs
	# SB2000 can use any of the SB1000 motherboards
	if ($ultra eq "Sun Blade 1000") {
		$modelmore=$banner;
		$modelmore=~s/Sun-Blade-1000/or Sun-Blade-2000/g;
		$modelmore=~s/\s+$//;
		while (($cf,$cnt)=each(%cpucnt)) {
			$cf=~/^(.*) (\d*)$/;
			$cfreq=$2;
			$modelmore=~s/\)/ ${cfreq}MHz\)/g if ($cfreq);
		}
	}
	$prtdiag_has_mem=1;
	$simmrangex="00001000";
	$simmbanks=2;
	$simmsperbank=4;
	@simmsizes=(128,256,512,1024,2048);
	@socketstr=("J0100","J0202","J0304","J0406","J0101","J0203","J0305","J0407");
	@bankstr=(0,0,0,0,1,1,1,1);
}
if ($model eq "Sun-Blade-100" || $ultra eq "Sun Blade 100" || $ultra eq "Sun Blade 150") {
	# Accepts 128MB, 256MB or 512MB DIMMs on motherboard
	# Uses 168-pin 3.3V ECC PC133 CL=3 SDRAM
	# U5 DIMM3 address 0x60000000 - 0x7fffffff or 0xc0000000 - 0xffffffff
	# U4 DIMM2 address 0x40000000 - 0x5fffffff or 0x80000000 - 0xbfffffff
	# U3 DIMM1 address 0x20000000 - 0x3fffffff or 0x40000000 - 0x7fffffff
	# U2 DIMM0 address 0x00000000 - 0x1fffffff or 0x00000000 - 0x3fffffff
	# The minimum memory requirement is one DIMM in U2
	# The memory installation sequence is U2, U3, U4, U5
	# Each bank addresses 512MB of memory with 500MHz UltraSPARC
	# Each bank addresses 1GB of memory with >= 550MHz UltraSPARC
	if ($model eq "Sun-Blade-100" || $ultra eq "Sun Blade 100") {
		$devname="Grover";
		$familypn="A36";
	}
	if ($ultra eq "Sun Blade 150") {
		$devname="Grover+";
		$familypn="A41";
	}
	$untested=0;
	$prtdiag_has_mem=1;
	$simmrangex=($cpufreq > 520) ? "00000400" : "00000200";
	$simmbanks=4;
	$simmsperbank=1;
	@simmsizes=(128,256,512);
	@socketstr=("DIMM0".."DIMM3");
	@bankstr=(0..3);
}
if ($ultra eq "Sun Fire" || $ultra eq "Sun Fire 15K" || $ultra eq "Sun Fire 12K" || $ultra =~ /Sun Fire ([346]8[01]0|E[246]900|E2[05]K)\b/) {
	# Sun Fire 3800 system
	#   2-8 UltraSPARC-III processors
	#   Up to 2 CPU/Memory boards
	# Sun Fire 4800, 4810 and 6800 system
	#   2-12 UltraSPARC-III processors
	#   Up to 3 CPU/Memory boards
	# Sun Fire 6800 system
	#   2-24 UltraSPARC-III processors
	#   Up to 6 CPU/Memory boards
	# Sun Fire 15K system
	#   16-106 UltraSPARC-III+, IV or IV+ processors
	#   Up to 18 CPU/Memory boards
	# Sun Fire 12K system
	#   up to 56 UltraSPARC-III+, IV or IV+ processors and 288GB memory
	# Sun Fire E2900 & E4900 system
	#   4, 8, or 12 UltraSPARC-IV or IV+ processors, up to 3 Uniboards
	#   E4900 adds dynamic system domains when compared to E2900
	# Sun Fire E6900 system
	#   4-24 UltraSPARC-IV or IV+ processors, up to 6 Uniboards
	# Sun Fire E20K system
	#   4-36 UltraSPARC-IV or IV+ processors, up to 9 Uniboards
	# Sun Fire E25K system
	#   Up to 72 UltraSPARC-IV or IV+ processors, up to 18 Uniboards
	# Each CPU/Memory board holds up to 4 processors and up to 32GB memory
	#  (32 DIMMs per board, 8 banks of 4 DIMMs)
	# Accepts 256MB, 512MB or 1GB DIMMs
	#  1GB DIMM not supported at 750MHz
	#  256MB DIMM only supported on US-III
	# 2GB DIMMs supported on 48x0/6800/E2900/E4900/E6900/E20K/E25K
	# System Board slots are labeled SB0 and higher
	# A populated DIMM bank requires an UltraSPARC CPU.
	# DIMMs are 232-pin 3.3V ECC 7ns SDRAM
	# prtdiag output shows the memory installed.
	#
	# CPU1 and CPU0 Memory  CPU3 and CPU2 Memory
	# --------------------  --------------------
	# Socket CPU Bank DIMM  Socket CPU Bank DIMM
	# ------ --- ---- ----  ------ --- ---- ----
	# J14600  P1  B0   D3   J16600  P3  B0   D3
	# J14601  P1  B1   D3   J16601  P3  B1   D3
	# J14500  P1  B0   D2   J16500  P3  B0   D2
	# J14501  P1  B1   D2   J16501  P3  B1   D2
	# J14400  P1  B0   D1   J16400  P3  B0   D1
	# J14401  P1  B1   D1   J16401  P3  B1   D1
	# J14300  P1  B0   D0   J16300  P3  B0   D0
	# J14301  P1  B1   D0   J16301  P3  B1   D0
	# J13600  P0  B0   D3   J15600  P2  B0   D3
	# J13601  P0  B1   D3   J15601  P2  B1   D3
	# J13500  P0  B0   D2   J15500  P2  B0   D2
	# J13501  P0  B1   D2   J15501  P2  B1   D2
	# J13400  P0  B0   D1   J15400  P2  B0   D1
	# J13401  P0  B1   D1   J15401  P2  B1   D1
	# J13300  P0  B0   D0   J15300  P2  B0   D0
	# J13301  P0  B1   D0   J15301  P2  B1   D0
	#
	$devname="Serengeti" if ($ultra eq "Sun Fire");
	if ($banner =~ /Sun Fire 3800\b/ || $diagbanner =~ /Sun Fire 3800\b/) {
		$devname="Serengeti8, SF3800 or SP";
		$familypn="F3800";
	}
	if ($banner =~ /Sun Fire 4800\b/ || $diagbanner =~ /Sun Fire 4800\b/) {
		$devname="Serengeti12, SF4800 or MD";
		$familypn="F4800";
	}
	if ($banner =~ /Sun Fire 4810\b/ || $diagbanner =~ /Sun Fire 4810\b/) {
		$devname="Serengeti12i, SF4810 or ME";
		$familypn="F4810";
	}
	if ($banner =~ /Sun Fire 6800\b/ || $diagbanner =~ /Sun Fire 6800\b/) {
		$devname="Serengeti24, SF6800 or DC";
		$familypn="F6800";
	}
	if ($ultra eq "Sun Fire 15K") {
		$devname="Starcat, Serengeti72";
		$familypn="F15K";
	}
	$devname="Starkitty" if ($ultra eq "Sun Fire 12K");
	if ($banner =~ /Sun Fire E2900\b/ || $diagbanner eq "Sun Fire E2900") {
		$devname="Amazon 2";
		$familypn="E29";
	}
	if ($banner =~ /Sun Fire E4900\b/ || $diagbanner eq "Sun Fire E4900") {
		$devname="Amazon 4";
		$familypn="E49";
	}
	$devname="Amazon 6" if ($banner =~ /Sun Fire E6900\b/ || $diagbanner eq "Sun Fire E6900");
	$devname="Amazon 20" if ($banner =~ /Sun Fire E20K\b/ || $diagbanner eq "Sun Fire E20K");
	$devname="Amazon 25" if ($banner =~ /Sun Fire E25K\b/ || $diagbanner eq "Sun Fire E25K");
	$untested=0;
	$prtdiag_has_mem=1;
	@simmsizes=(256,512,1024);
	@simmsizes=(256,512,1024,2048) if ($ultra =~ /Sun Fire ([46]8[01]0|E[246]900|E2[05]K)\b/);
}
if ($ultra eq "Sun Fire V880") {
	# Accepts 128MB, 256MB, 512MB or 1GB DIMMs in groups of four per CPU
	# 128MB DIMMs only supported on 750MHz CPU/memory boards
	# 1GB DIMMs only supported on 900MHz or faster CPU/memory boards
	# 2-8 UltraSPARC-III processors, 750MHz or faster
	# Up to 64GB memory, 8GB max per CPU, 4 DIMMs per CPU, 2 CPUs per board
	# DIMMs must be added four-at-a-time within the same group of DIMM
	#  slots; every fourth slot belongs to the same DIMM group.
	# Each CPU/Memory board must be populated with a minimum of eight DIMMs,
	#  installed in groups A0 and B0.
	# For 1050MHz and higher system boards, each CPU/Memory board must be
	#  populated with all sixteen DIMMs, installed in groups A0,A1,B0,B1.
	# Each group used must have four identical DIMMs installed (all four
	#  DIMMs must be from the same manufacturing vendor and must have the
	#  same capacity).
	# DIMMs are 232-pin 3.3V ECC 7ns SDRAM
	# Uses 128-bit-wide path to memory, 150MHz DIMMs, 2.4GB/sec
	#   bandwidth to processor and an aggregate memory bw of 9.6GB/sec
	# prtdiag output shows the memory installed.
	#
	# CPU CPU/Memory Slot Associated DIMM Group
	# --- --------------- ---------------------
	#  0      Slot A             A0,A1
	#  2      Slot A             B0,B1
	#  1      Slot B             A0,A1
	#  3      Slot B             B0,B1
	#  4      Slot C             A0,A1
	#  6      Slot C             B0,B1
	#  5      Slot D             A0,A1
	#  7      Slot D             B0,B1
	#
	$devname="Daktari (V880), Nandi (V880z)";
	$familypn="A30 (V880), A47 (V880z)";
	$untested=0;
	@simmsizes=($cpufreq < 800) ? (128,256,512) : (256,512,1024,2048);
	@banksstr=("A0","A1","B0","B1");
	$prtdiag_has_mem=1;
}
if ($ultra eq "Sun Fire V480") {
	# Accepts 256MB, 512MB or 1GB DIMMs in groups of four per CPU
	# 2 or 4 UltraSPARC-III processors, 900MHz or faster
	# Up to 32GB memory, 8GB max per CPU, 4 DIMMs per CPU, 2 CPUs per board
	# Smaller version of Sun Fire V880 above
	$devname="Cherrystone";
	$familypn="A37";
	$untested=0;
	@simmsizes=(256,512,1024,2048);
	@banksstr=("A0","A1","B0","B1");
	$prtdiag_has_mem=1;
}
if ($ultra eq "Sun Fire V490" || $ultra eq "Sun Fire V890") {
	# Accepts 512MB or 1GB DIMMs in groups of four per CPU
	# 2 or 4 UltraSPARC-III, IV or IV+ processors, 1050MHz or faster
	# Up to 32GB memory, 8GB max per CPU, 4 DIMMs per CPU, 2 CPUs per board
	# Similar memory contraints as Sun Fire V880 above
	if ($ultra eq "Sun Fire V490") {
		$devname="Sebring";
		$familypn="A52";
	}
	if ($ultra eq "Sun Fire V890") {
		$devname="Silverstone";
		$familypn="A53";
	}
	$untested=0;
	@simmsizes=(512,1024,2048);
	@banksstr=("A0","A1","B0","B1");
	$prtdiag_has_mem=1;
}
if ($ultra eq "Netra T12") {
	# Sun Fire V1280, Netra 1280
	# Essentially the same as a Sun Fire 4810, but is marketed as a low cost
	# single domain system.
	# 2-12 UltraSPARC-IIIcu processors using up to 3 CPU/Memory boards
	# Each CPU/Memory board holds up to 4 processors and up to 32GB memory
	#  (32 DIMMs per board, 8 banks of 4 DIMMs)
	# Accepts 256MB, 512MB, 1GB or 2GB DIMMs
	# System Board slots are labeled SB0 and higher
	# A populated DIMM bank requires an UltraSPARC III CPU.
	# DIMMs are 232-pin 3.3V ECC 7ns SDRAM
	# prtdiag output shows the memory installed.
	$devname="Lightweight 8";
	$familypn="A40 (Sun Fire V1280), N40 (Netra 1280)";
	$untested=0;
	$prtdiag_has_mem=1;
	@simmsizes=(256,512,1024,2048);
}
if ($ultra eq "Enchilada") {
	# Sun Fire V210, V240, Netra 210, 240
	# 1-2 UltraSPARC-IIIi (Jalapeno) processors
	# UltraSPARC IIIi supports 128MB to 1GB single bank DIMMs.
	# UltraSPARC IIIi supports 256MB to 2GB dual bank DIMMs.
	# DDR-1 SDRAM PC2100 DIMMs, 8 DIMM slots, 4 DIMMs per processor,
	#  2 banks per processor, 2 DIMMs per bank
	# V210 accepts 1GB & 2GB DIMMs by installing Fan Upgrade Kit, X7418A
	# Mixing DIMM sizes and capacities is not supported.
	# prtdiag output can show the memory installed.
	$devname="Enchilada";	# Enxs
	if ($banner =~ /Sun Fire V210\b/ || $model =~ /Sun-Fire-V210/) {
		$devname="Enchilada 1U";
		$familypn="N31";
	}
	if ($model =~ /Netra-210\b/) {
		$devname="Salsa 19";
		$familypn="N79";
	}
	if ($banner =~ /Sun Fire V240\b/ || $model =~ /Sun-Fire-V240/) {
		$devname="Enchilada 2U";
		$familypn="N32";
	}
	if ($model =~ /Netra-240\b/) {
		$devname="Enchilada 19";
		$familypn="N54";
	}
	$untested=0 if ($banner =~ /Sun Fire (V210|240)\b/ || $model =~ /Sun-Fire-(V210|V240)/ || $model =~ /Netra-2[14]0\b/);
	$prtdiag_has_mem=1;
	$prtdiag_banktable_has_dimms=1;
	$simmrangex="00002000";
	# Count the skipped address range for dual CPU
	$simmbanks=($ncpu > 1) ? 10 : 2;
	$simmsperbank=2;
	@simmsizes=(128,256,512,1024,2048);
	@socketstr=("MB/P0/B0/D0","MB/P0/B0/D1","MB/P0/B1/D0","MB/P0/B1/D1","?","?","?","?","?","?","?","?","?","?","?","?");
	push(@socketstr, "MB/P1/B0/D0","MB/P1/B0/D1","MB/P1/B1/D0","MB/P1/B1/D1") if ($ncpu > 1);
}
if ($ultra eq "Sun Fire V440" || $ultra eq "Netra 440") {
	# 1-4 UltraSPARC-IIIi (Jalapeno) processors
	# UltraSPARC IIIi supports 128MB to 1GB single bank DIMMs.
	# UltraSPARC IIIi supports 256MB to 2GB dual bank DIMMs.
	# DDR-1 SDRAM PC2100 DIMMs, 16 DIMM slots, 4 DIMMs per processor,
	#  2 banks per processor, 2 DIMMs per bank
	# prtdiag output can show the memory installed.
	$devname="Chalupa";
	$familypn="A42";
	if ($ultra eq "Netra 440") {
		$devname="Chalupa 19";
		$familypn="N42";
	}
	$untested=0;
	$prtdiag_has_mem=1;
	$prtdiag_banktable_has_dimms=1;
	$simmrangex="00002000";
	$simmbanks=26;	# Count the skipped address range for each CPU
	$simmsperbank=2;
	@simmsizes=(128,256,512,1024,2048);
	# Each CPU card has 4 DIMM slots labeled J0601 (B0/D0), J0602 (B0/D1),
	#  J0701 (B1/D0) and J0702 (B1/D1).
	@socketstr=("C0/P0/B0/D0","C0/P0/B0/D1","C0/P0/B1/D0","C0/P0/B1/D1","?","?","?","?","?","?","?","?","?","?","?","?");
	push(@socketstr, "C1/P0/B0/D0","C1/P0/B0/D1","C1/P0/B1/D0","C1/P0/B1/D1","?","?","?","?","?","?","?","?","?","?","?","?") if ($ncpu > 1);
	push(@socketstr, "C2/P0/B0/D0","C2/P0/B0/D1","C2/P0/B1/D0","C2/P0/B1/D1","?","?","?","?","?","?","?","?","?","?","?","?") if ($ncpu > 2);
	push(@socketstr, "C3/P0/B0/D0","C3/P0/B0/D1","C3/P0/B1/D0","C3/P0/B1/D1") if ($ncpu > 3);
}
if ($ultra eq "Sun Blade 1500") {
	# 1 UltraSPARC-IIIi (Jalapeno) processor
	# UltraSPARC IIIi supports 128MB to 1GB single bank DIMMs.
	# UltraSPARC IIIi supports 256MB to 2GB dual bank DIMMs.
	# 184-pin DDR-1 SDRAM PC2100 DIMMs installed in pairs, 4 DIMM slots
	# prtdiag output can show the memory installed.
	$devname="Taco";
	$devname .= "+" if ($modelmore =~ /\(Silver\)/ || $banner =~ /\(Silver\)/);
	$familypn="A43";
	$untested=0;
	$prtdiag_has_mem=1;
	$prtdiag_banktable_has_dimms=1;
	$simmrangex="00002000";
	$simmbanks=2;
	$simmsperbank=2;
	@simmsizes=(128,256,512,1024,2048);
	@socketstr=("DIMM0".."DIMM3");	# DIMM1-DIMM4 on prototype
}
if ($ultra eq "Sun Blade 2500" || $ultra eq "Sun Fire V250") {
	# 1-2 UltraSPARC-IIIi (Jalapeno) processors
	# UltraSPARC IIIi supports 128MB to 1GB single bank DIMMs.
	# UltraSPARC IIIi supports 256MB to 2GB dual bank DIMMs.
	# 184-pin DDR-1 SDRAM PC2100 DIMMs, 8 DIMM slots, 4 DIMMs per processor,
	#  2 banks per processor, 2 DIMMs per bank
	# prtdiag output can show the memory installed.
	if ($ultra eq "Sun Blade 2500") {
		$devname="Enchilada Workstation";
		$devname .= " Silver" if ($modelmore =~ /\(Silver\)/ || $banner =~ /\(Silver\)/);
		$familypn="A39";
	}
	if ($ultra eq "Sun Fire V250") {
		$devname="Enchilada 2P Tower";
		$familypn="A50";
	}
	$untested=0;
	$prtdiag_has_mem=1;
	$prtdiag_banktable_has_dimms=1;
	$simmrangex="00002000";
	# Count the skipped address range for dual CPU
	$simmbanks=($ncpu > 1) ? 20 : 2;
	$simmsperbank=2;
	@simmsizes=(128,256,512,1024,2048);
	if ($ultra eq "Sun Blade 2500") {
		@socketstr=("DIMM0".."DIMM3");
		push(@socketstr, "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "DIMM4".."DIMM7") if ($ncpu > 1);
	} else {
		@socketstr=("MB/DIMM0","MB/DIMM1","MB/DIMM2","MB/DIMM3");
		push(@socketstr, "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "MB/DIMM4","MB/DIMM5","MB/DIMM6","MB/DIMM7") if ($ncpu > 1);
	}
}
if ($ultra eq "Sun Ultra 45 Workstation" || $ultra eq "Sun Ultra 45 or Ultra 25 Workstation") {
	# 1-2 UltraSPARC-IIIi (Jalapeno) 1.6GHz processors
	# 1GB to 16GB of DDR1 SDRAM 266 or 333MHz registered ECC memory using
	#  matched pairs of 512MB, 1GB and 2GB DIMMs
	# maximum of 4 DIMMs (8GB) per CPU
	# CPU0 Bank0 DIMM1&DIMM3 blue sockets, Bank1 DIMM0&DIMM2 black sockets
	# CPU1 Bank0 DIMM4&DIMM6 blue sockets, Bank1 DIMM5&DIMM7 black sockets
	# prtdiag output can show the memory installed.
	$devname="Chicago";	# also "Netra Salsa-19" development name
	$familypn="A70";
	$untested=0;
	$prtdiag_has_mem=1;
	$prtdiag_banktable_has_dimms=1;
	$simmrangex="00002000";
	# Count the skipped address range for dual CPU
	$simmbanks=($ncpu > 1) ? 20 : 2;
	$simmsperbank=2;
	@simmsizes=(512,1024,2048);
	@socketstr=("MB/DIMM1","MB/DIMM3","MB/DIMM0","MB/DIMM2");
	push(@socketstr, "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "?", "MB/DIMM4","MB/DIMM6","MB/DIMM5","MB/DIMM7") if ($ncpu > 1);
}
if ($ultra eq "Sun Ultra 25 Workstation") {
	# 1 UltraSPARC-IIIi (Jalapeno) 1.34GHz processors
	# 1GB to 8GB of DDR1 SDRAM 266 or 333MHz registered ECC memory using
	#  matched pairs of 512MB, 1GB and 2GB DIMMs
	# maximum of 4 DIMMs (8GB)
	# Bank0 DIMM1&DIMM3 blue sockets, Bank1 DIMM0&DIMM2 black sockets
	# prtdiag output can show the memory installed.
	$devname="Southside";
	$familypn="A89";
	$untested=0;
	$prtdiag_has_mem=1;
	$prtdiag_banktable_has_dimms=1;
	$simmrangex="00002000";
	$simmbanks=2;
	$simmsperbank=2;
	@simmsizes=(512,1024,2048);
	@socketstr=("MB/DIMM1","MB/DIMM3","MB/DIMM0","MB/DIMM2");
}
if ($ultra eq "Sun Fire V125") {
	# 1 UltraSPARC-IIIi (Jalapeno) processor
	# UltraSPARC IIIi supports 128MB to 1GB single bank DIMMs.
	# UltraSPARC IIIi supports 256MB to 2GB dual bank DIMMs.
	# DDR-1 SDRAM PC2100 DIMMs, 4 DIMM slots, 2 DIMMs per bank
	# Mixing DIMM sizes and capacities is not supported.
	# prtdiag output can show the memory installed.
	$devname="El Paso";
	$familypn="125";
	$untested=0;
	$prtdiag_has_mem=1;
	$prtdiag_banktable_has_dimms=1;
	$simmrangex="00002000";
	$simmbanks=2;
	$simmsperbank=2;
	@simmsizes=(128,256,512,1024,2048);
	@socketstr=("MB/P0/B0/D0","MB/P0/B0/D1","MB/P0/B1/D0","MB/P0/B1/D1");
}
if ($ultra eq "Seattle") {
	# Sun Fire V215, V245
	# 1-2 UltraSPARC-IIIi (Jalapeno) processors
	# UltraSPARC IIIi supports 128MB to 1GB single bank DIMMs.
	# UltraSPARC IIIi supports 256MB to 2GB dual bank DIMMs.
	# DDR-1 SDRAM PC2100 DIMMs, 8 DIMM slots, 4 DIMMs per processor,
	#  2 banks per processor, 2 DIMMs per bank
	# Mixing DIMM sizes and capacities is not supported.
	# prtdiag output can show the memory installed.
	$devname="Seattle";	# Enxs
	if ($banner =~ /Sun Fire V215\b/ || $model =~ /Sun-Fire-V215/) {
		$devname="Seattle 1U";
		$familypn="215";
	}
	if ($banner =~ /Sun Fire V245\b/ || $model =~ /Sun-Fire-V245/) {
		$devname="Seattle 2U";
		$familypn="245";
	}
	$untested=0;
	$prtdiag_has_mem=1;
	$prtdiag_banktable_has_dimms=1;
	$simmrangex="00002000";
	# Count the skipped address range for dual CPU
	$simmbanks=($ncpu > 1) ? 10 : 2;
	$simmsperbank=2;
	@simmsizes=(128,256,512,1024,2048);
	@socketstr=("MB/P0/B0/D0","MB/P0/B0/D1","MB/P0/B1/D0","MB/P0/B1/D1","?","?","?","?","?","?","?","?","?","?","?","?");
	push(@socketstr, "MB/P1/B0/D0","MB/P1/B0/D1","MB/P1/B1/D0","MB/P1/B1/D1") if ($ncpu > 1);
}
if ($ultra eq "Boston") {
	# Sun Fire V445
	# 2-4 UltraSPARC-IIIi (Jalapeno) processors
	# UltraSPARC IIIi supports 128MB to 1GB single bank DIMMs.
	# UltraSPARC IIIi supports 256MB to 2GB dual bank DIMMs.
	# DDR-1 SDRAM PC2100 DIMMs, 16 DIMM slots, 4 DIMMs per processor,
	#  2 banks per processor, 2 DIMMs per bank
	# prtdiag output can show the memory installed.
	$devname="Boston";
	$familypn="445, A77";
	$untested=0;
	$prtdiag_has_mem=1;
	$prtdiag_banktable_has_dimms=1;
	$simmrangex="00002000";
	$simmbanks=26;	# Count the skipped address range for each CPU
	$simmsperbank=2;
	@simmsizes=(128,256,512,1024,2048);
	# Each CPU card has 4 DIMM slots labeled J0601 (B0/D0), J0602 (B0/D1),
	#  J0701 (B1/D0) and J0702 (B1/D1).
	@socketstr=("C0/P0/B0/D0","C0/P0/B0/D1","C0/P0/B1/D0","C0/P0/B1/D1","?","?","?","?","?","?","?","?","?","?","?","?");
	push(@socketstr, "C1/P0/B0/D0","C1/P0/B0/D1","C1/P0/B1/D0","C1/P0/B1/D1","?","?","?","?","?","?","?","?","?","?","?","?") if ($ncpu > 1);
	push(@socketstr, "C2/P0/B0/D0","C2/P0/B0/D1","C2/P0/B1/D0","C2/P0/B1/D1","?","?","?","?","?","?","?","?","?","?","?","?") if ($ncpu > 2);
	push(@socketstr, "C3/P0/B0/D0","C3/P0/B0/D1","C3/P0/B1/D0","C3/P0/B1/D1") if ($ncpu > 3);
}
if ($ultra eq "Serverblade1") {
	# Sun Fire B100s Blade Server
	# 1 UltraSPARC-IIi 650MHz processors
	# Two PC-133 DIMM slots holding up to 2GB memory
	# Up to 16 Blade Servers in a single B1600 Intelligent Shelf
	# prtdiag output shows the memory installed.
	$bannermore="(Sun Fire B100s Blade Server)";
	$modelmore=$bannermore;
	$devname="Stiletto";
	$familypn="A44";
	$untested=0;
	$prtdiag_has_mem=1;
	$simmrangex="00000400";
	$simmbanks=2;
	$simmsperbank=1;
	@simmsizes=(256,512,1024);
	@socketstr=("Blade/DIMM0","Blade/DIMM1");
}
if ($ultra eq "T2000") {
	# 1 UltraSPARC-T1 (Niagara) processor with "CoolThreads" multithreading
	# 8 Core 1.2GHz (9.6GHz clock speed rating) or 4, 6, or 8 Core 1.0GHz
	#  or 8 Core 1.4GHz
	# Up to 64GB DDR2 memory in 16 slots w/ Chipkill and DRAM sparing, ECC
	#  registered DIMMs. Supports 512MB, 1GB, 2GB and 4GB DIMMs.
	# Option X7800A - 1GB (2x512MB DDR2) 370-6207, 512MB DDR2 DIMM, 533MHz
	# Option X7801A - 2GB (2x1GB DDR2) 370-6208, 1GB DDR2 DIMM, 533MHz
	# Option X7802A - 4GB (2x2GB DDR2) 370-6209, 2GB DDR2 DIMM, 533MHz
	# DIMMs must be installed in sets of 8. Two basic memory configurations
	#  are supported: 8-DIMM or 16-DIMM. All DIMMs must have identical
	#  capacity. An 8 DIMM configuration fully populates Rank 0 (R0) slots.
	# Base configurations sold by Sun use all 16 DIMM slots (2 ranks) except
	#  smallest memory configuration (4GB, 8 x 512MB in Rank 0).
	# The minimum T2000 memory requirement is 8 Rank 0 DIMMs.
	# 4 memory controllers embedded in UltraSPARC-T1 (CH0-CH3)
	#
	#			T2000 Memory Map
	#             +----------------------------------------+
	#             | J0901    Channel 0    Rank 1    DIMM 1 | DIMM 1
	# Install 1st | J0701    Channel 0    Rank 0    DIMM 1 | DIMM 2
	#             | J0801    Channel 0    Rank 1    DIMM 0 | DIMM 3
	# Install 1st | J0601    Channel 0    Rank 0    DIMM 0 | DIMM 4
	#             | J1401    Channel 1    Rank 1    DIMM 1 | DIMM 5
	# Install 1st | J1201    Channel 1    Rank 0    DIMM 1 | DIMM 6
	#             | J1301    Channel 1    Rank 1    DIMM 0 | DIMM 7
	# Install 1st | J1101    Channel 1    Rank 0    DIMM 0 | DIMM 8
	#             +----------------------------------------+
	#                           +---------------+
	#                           | UltraSPARC T1 |
	#                           +---------------+
	#             +----------------------------------------+
	# Install 1st | J2101    Channel 3    Rank 0    DIMM 0 | DIMM 9
	#             | J2301    Channel 3    Rank 1    DIMM 0 | DIMM 10
	# Install 1st | J2201    Channel 3    Rank 0    DIMM 1 | DIMM 11
	#             | J2401    Channel 3    Rank 1    DIMM 1 | DIMM 12
	# Install 1st | J1601    Channel 2    Rank 0    DIMM 0 | DIMM 13
	#             | J1801    Channel 2    Rank 1    DIMM 0 | DIMM 14
	# Install 1st | J1701    Channel 2    Rank 0    DIMM 1 | DIMM 15
	#             | J1901    Channel 2    Rank 1    DIMM 1 | DIMM 16
	#             +----------------------------------------+
	$devname="Ontario";
	$familypn="T20";
	if ($model =~ /Netra-T2000\b/ || $banner =~ /Netra T2000\b/) {
		$devname="Pelton";
		$familypn="N20";
	}
	$familypn="T20, SEB" if ($model =~ /SPARC-Enterprise-T2000/ || $banner =~ /SPARC Enterprise T2000/);
	$untested=0;
	$simmrangex="00002000";
	if (scalar(@slots) == 8) {
		# Two ranks reported
		$simmbanks=2;
		$simmsperbank=8;
	} else {
		# One rank reported, but default base configurations ship with
		# two ranks (16 DIMMs)
		$simmbanks=1;
		$simmsperbank=16;
	}
	@simmsizes=(512,1024,2048,4096);
	@socketstr=("MB/CMP0/CH0/R0/D0","MB/CMP0/CH0/R0/D1","MB/CMP0/CH1/R0/D0","MB/CMP0/CH1/R0/D1","MB/CMP0/CH2/R0/D0","MB/CMP0/CH2/R0/D1","MB/CMP0/CH3/R0/D0","MB/CMP0/CH3/R0/D1","MB/CMP0/CH0/R1/D0","MB/CMP0/CH0/R1/D1","MB/CMP0/CH1/R1/D0","MB/CMP0/CH1/R1/D1","MB/CMP0/CH2/R1/D0","MB/CMP0/CH2/R1/D1","MB/CMP0/CH3/R1/D0","MB/CMP0/CH3/R1/D1");
	&check_for_LDOM;
}
if ($ultra eq "T1000") {
	# 1 UltraSPARC-T1 (Niagara) processor with "CoolThreads" multithreading
	# 6 or 8 Core 1.0GHz
	# Up to 32GB DDR2 memory in 8 slots w/ Chipkill and DRAM sparing, ECC
	#  registered DIMMs. Supports 512MB, 1GB, 2GB and 4GB DIMMs.
	# Option X7800A - 1GB (2x512MB DDR2) 370-6207, 512MB DDR2 DIMM, 533MHz
	# Option X7801A - 2GB (2x1GB DDR2) 370-6208, 1GB DDR2 DIMM, 533MHz
	# Option X7802A - 4GB (2x2GB DDR2) 370-6209, 2GB DDR2 DIMM, 533MHz
	# DIMMs must be installed in sets of 4.
	# Base configurations sold by Sun use all 8 DIMM slots (2 ranks) except
	#  smallest memory configuration (2GB, 4 x 512MB in Rank 0).
	# The minimum T1000 memory requirement is 4 Rank 0 DIMMs.
	# 4 memory controllers embedded in UltraSPARC-T1 (CH0-CH3)
	#
	#			T1000 Memory Map
	#             +----------------------------------------+
	#             | J1301    Channel 3    Rank 1    DIMM 1 |
	# Install 1st | J1101    Channel 3    Rank 0    DIMM 1 |
	#             | J1201    Channel 3    Rank 1    DIMM 0 |
	# Install 1st | J1001    Channel 3    Rank 0    DIMM 0 |
	#             +----------------------------------------+
	#                           +---------------+
	#                           | UltraSPARC T1 |
	#                           +---------------+
	#             +----------------------------------------+
	# Install 1st | J0501    Channel 0    Rank 0    DIMM 0 |
	#             | J0701    Channel 0    Rank 1    DIMM 0 |
	# Install 1st | J0601    Channel 0    Rank 0    DIMM 1 |
	#             | J0801    Channel 0    Rank 1    DIMM 1 |
	#             +----------------------------------------+
	$devname="Erie";
	$familypn="T10";
	$familypn="T10, SEA" if ($model =~ /SPARC-Enterprise-T1000/ || $banner =~ /SPARC Enterprise T1000/);
	$untested=0;
	$simmrangex="00002000";
	if (scalar(@slots) == 8) {
		# Two ranks reported
		$simmbanks=2;
		$simmsperbank=4;
	} else {
		$simmbanks=1;
		$simmsperbank=8;
	}
	@simmsizes=(512,1024,2048,4096);
	@socketstr=("MB/CMP0/CH0/R0/D0","MB/CMP0/CH0/R0/D1","MB/CMP0/CH3/R0/D0","MB/CMP0/CH3/R0/D1","MB/CMP0/CH0/R1/D0","MB/CMP0/CH0/R1/D1","MB/CMP0/CH3/R1/D0","MB/CMP0/CH3/R1/D1");
	&check_for_LDOM;
}
if ($ultra eq "T6300") {
	# 1 UltraSPARC-T1 (Niagara) processor with "CoolThreads" multithreading
	# 6-Core 1.0GHz, 8-Core 1.0GHz, 1.2GHz or 1.4GHz
	# Up to 32GB ECC Registered DDR2 PC4200
	#  Supports 1GB, 2GB and 4GB DIMMs.
	# DIMMs must be installed in sets of 4.
	# Supported memory configurations:
	#  4 FB-DIMMs (Channel 0 and Channel 3)
	#  4 FB-DIMMs (Channel 1 and Channel 2)
	#  8 FB-DIMMs (Channel 0, 1, 2 and 3) (fully populated configuration)
	# Due to interleaving rules for the CPU, the system will operate at
	#  the lowest capacity of all the DIMMs installed. Therefore, it is
	#  ideal to install eight identical DIMMs (not four DIMMs of one
	#  capacity and four DIMMs of another capacity).
	$devname="St. Paul";
	$familypn="A94";
	$untested=0;
	$memtype="FB-DIMM";
	$simmrangex="00002000";
	$showrange=0;
	$simmbanks=2;
	$simmsperbank=4;
	@simmsizes=(1024,2048,4096);
	@socketstr=("MB/CMP0/CH0/R0/D0","MB/CMP0/CH0/R0/D1","MB/CMP0/CH3/R0/D0","MB/CMP0/CH3/R0/D1","MB/CMP0/CH1/R0/D0","MB/CMP0/CH1/R0/D1","MB/CMP0/CH2/R0/D0","MB/CMP0/CH2/R0/D1");
	@socketlabelstr=("J6301","J6401","J7201","J7301","J6601","J6701","J6901","J7001");
	&check_for_LDOM;
}
if ($ultra eq "T5120" || $ultra eq "T5220" || $ultra eq "T6320") {
	# 1 UltraSPARC-T2 (Niagara-II) multicore processor with "CoolThreads"
	#  multithreading, 1.2GHz 4 or 8-Core or 1.4GHz 8-Core
	# Up to 64GB Fully Buffered ECC-registered DDR2 @ 667MHz
	#  Supports 1GB, 2GB, 4GB and 8GB DIMMs.
	# DIMMs must be installed in sets of 4.
	# All FB-DIMMs must be the same density (same type and Sun part number)
	# Supported memory configurations:
	#  4 FB-DIMMs (Group 1)     MB/CMP0/BR[0-3]/CH0/D0
	#  8 FB-DIMMs (Groups 1-2)  MB/CMP0/BR[0-3]/CH[01]/D0
	#  16 FB-DIMMs (Groups 1-3) MB/CMP0/BR[0-3]/CH[01]/D[01]
	#
	# FB-DIMM Configuration:
	#                                                 Install FB-DIMM
	# Branch  Channel  FRU Name              FB-DIMM  Order   Pair
	#
	# 0       0        MB/CMP0/BR0/CH0/D0    J1001    1       A
	#                  MB/CMP0/BR0/CH0/D1    J1101    3       B
	#         1        MB/CMP0/BR0/CH1/D0    J1201    2       A
	#                  MB/CMP0/BR0/CH1/D1    J1301    3       B
	# 1       0        MB/CMP0/BR1/CH0/D0    J1401    1       C
	#                  MB/CMP0/BR1/CH0/D1    J1501    3       D
	#         1        MB/CMP0/BR1/CH1/D0    J1601    2       C
	#                  MB/CMP0/BR1/CH1/D1    J1701    3       D
	# 2       0        MB/CMP0/BR2/CH0/D0    J2001    1       E
	#                  MB/CMP0/BR2/CH0/D1    J2101    3       F
	#         1        MB/CMP0/BR2/CH1/D0    J2201    2       E
	#                  MB/CMP0/BR2/CH1/D1    J2301    3       F
	# 3       0        MB/CMP0/BR3/CH0/D0    J2401    1       G
	#                  MB/CMP0/BR3/CH0/D1    J2501    3       H
	#         1        MB/CMP0/BR3/CH1/D0    J2601    2       G
	#                  MB/CMP0/BR3/CH1/D1    J2701    3       H
	#
	# Note - FB-DIMM names in ILOM messages are displayed with the full FRU
	# name, such as /SYS/MB/CMP0/BR0/CH0/D0.
	$devname="Huron";
	if ($ultra eq "T5120") {
		$devname="Huron 1U";
		$familypn="SEC";
	}
	if ($ultra eq "T5220") {
		$devname="Huron 2U";
		$familypn="SED";
	}
	if ($banner =~ /Netra T5220\b/) {
		$devname="Turgo";
		$familypn="NT52";
	}
	if ($ultra eq "T6320") {
		$devname="Glendale";
		$familypn="A95";
	}
	$untested=0;
	$memtype="FB-DIMM";
	$simmrangex="00008000";
	$showrange=0;
	$simmbanks=4;
	$simmsperbank=4;
	@simmsizes=(1024,2048,4096,8192);
	@socketstr=("MB/CMP0/BR0/CH0/D0","MB/CMP0/BR1/CH0/D0","MB/CMP0/BR2/CH0/D0","MB/CMP0/BR3/CH0/D0","MB/CMP0/BR0/CH1/D0","MB/CMP0/BR1/CH1/D0","MB/CMP0/BR2/CH1/D0","MB/CMP0/BR3/CH1/D0","MB/CMP0/BR0/CH0/D1","MB/CMP0/BR1/CH0/D1","MB/CMP0/BR2/CH0/D1","MB/CMP0/BR3/CH0/D1","MB/CMP0/BR0/CH1/D1","MB/CMP0/BR1/CH1/D1","MB/CMP0/BR2/CH1/D1","MB/CMP0/BR3/CH1/D1");
	&check_for_LDOM;
}
if ($ultra eq "CP3260") {
	# 1 UltraSPARC-T2 (Niagara-II) multicore processor with "CoolThreads"
	#  multithreading, 6 or 8 core with 8 threads per core
	# 8 FB-DIMM slots, 8GB or 16GB, using 1GB or 2GB DIMMs, 8 channels
	#  Fully Buffered ECC-registered DDR2 @ 667MHz
	# All FB-DIMMs must be the same density (same type and Sun part number)
	# Supported memory configurations:
	#  FB0B FB0A     FB1B FB1A     FB2A FB2B     FB3A FB3B
	#  DIMM Pair 0   DIMM Pair 1   DIMM Pair 2   DIMM Pair 3
	$devname="Monza";
	$untested=1;
	$memtype="FB-DIMM";
	$simmrangex="00008000";
	$showrange=0;
	$simmbanks=1;
	$simmsperbank=8;
	@simmsizes=(1024,2048);
	@socketstr=("FB0A","FB0B","FB1A","FB1B","FB2A","FB2B","FB3A","FB3B");
	&check_for_LDOM;
}
if ($ultra eq "T5140" || $ultra eq "T5240" || $ultra eq "T6340") {
	# T5140 has 2 UltraSPARC-T2+ (Victoria Falls) multicore processors with
	#  "CoolThreads" multithreading, 1.2GHz 4, 6, or 8-Core
	# T5240 has 2 UltraSPARC-T2+ (Victoria Falls) multicore processors with
	#  "CoolThreads" multithreading, 1.2GHz 4, 6, or 8-Core or 1.4GHz 8-Core
	# T6340 has 2 UltraSPARC-T2+ (Victoria Falls) multicore processors with
	#  "CoolThreads" multithreading, 1.4GHz 8-Core
	# 8GB to 64GB Fully Buffered ECC-registered DDR2 @ 667MHz
	# Supports 1GB, 2GB, 4GB and 8GB DIMMs.
	# T5240 also supports optional mezzanine memory board doubling memory
	#  with an additional 16 FB-DIMM sockets
	# All FB-DIMMs must be the same density (same type and Sun part number)
	#
	# T5140,T5240 Supported memory configurations:
	#  8 FB-DIMMs (Group 1)     MB/CMP[01]/BR[01]/CH[01]/D0
	#  12 FB-DIMMs (Groups 1-2) MB/CMP[01]/BR[01]/CH[01]/D0,MB/CMP0/BR[01]/CH[01]/D1
	#  16 FB-DIMMs (Groups 1-3) MB/CMP[01]/BR[01]/CH[01]/D[01]
	# T5240 with memory mezzanine assembly supports these additional
	# memory configurations once the motherboard is fully populated:
	#  24 FB-DIMMs (Groups 1-4) MB/CMP[01]/MR0/BR[01]/CH[01]/D[23]
	#  32 FB-DIMMs (Groups 1-5) MB/CMP[01]/MR[01]/BR[01]/CH[01]/D[23]
	#
	# FB-DIMM Configuration:
	#                                                   Install FB-DIMM
	# Branch  Channel  FRU Name                FB-DIMM  Order   Pair
	#
	# CMP0,0  0        MB/CMP0/BR0/CH0/D0      J0500    1       A
	#                  MB/CMP0/BR0/CH0/D1      J0600    2       B
	#         1        MB/CMP0/BR0/CH1/D0      J0700    1       A
	#                  MB/CMP0/BR0/CH1/D1      J0800    2       B
	# CMP0,1  0        MB/CMP0/BR1/CH0/D0      J0900    1       C
	#                  MB/CMP0/BR1/CH0/D1      J1000    2       D
	#         1        MB/CMP0/BR1/CH1/D0      J1100    1       C
	#                  MB/CMP0/BR1/CH1/D1      J1200    2       D
	# CMP1,0  0        MB/CMP1/BR0/CH0/D0      J1800    1       E
	#                  MB/CMP1/BR0/CH0/D1      J1900    3       F
	#         1        MB/CMP1/BR0/CH1/D0      J2000    1       E
	#                  MB/CMP1/BR0/CH1/D1      J2100    3       F
	# CMP1,1  0        MB/CMP1/BR1/CH0/D0      J2200    1       G
	#                  MB/CMP1/BR1/CH0/D1      J2300    3       H
	#         1        MB/CMP1/BR1/CH1/D0      J2400    1       G
	#                  MB/CMP1/BR1/CH1/D1      J2500    3       H
	# CMP0,0  0        MB/CMP0/MR0/BR0/CH0/D2  J0201    4
	#                  MB/CMP0/MR0/BR0/CH0/D3  J0301    4
	#         1        MB/CMP0/MR0/BR0/CH1/D2  J0401    4
	#                  MB/CMP0/MR0/BR0/CH1/D3  J0501    4
	# CMP0,1  0        MB/CMP0/MR0/BR1/CH0/D2  J0601    4
	#                  MB/CMP0/MR0/BR1/CH0/D3  J0701    4
	#         1        MB/CMP0/MR0/BR1/CH1/D2  J0801    4
	#                  MB/CMP0/MR0/BR1/CH1/D3  J0901    4
	# CMP1,0  0        MB/CMP1/MR1/BR0/CH0/D2  J0201    5
	#                  MB/CMP1/MR1/BR0/CH0/D3  J0301    5
	#         1        MB/CMP1/MR1/BR0/CH1/D2  J0401    5
	#                  MB/CMP1/MR1/BR0/CH1/D3  J0501    5
	# CMP1,1  0        MB/CMP1/MR1/BR1/CH0/D2  J0601    5
	#                  MB/CMP1/MR1/BR1/CH0/D3  J0701    5
	#         1        MB/CMP1/MR1/BR1/CH1/D2  J0801    5
	#                  MB/CMP1/MR1/BR1/CH1/D3  J0901    5
	#
	# Note - FB-DIMM names in ILOM messages are displayed with the full FRU
	# name, such as /SYS/MB/CMP0/BR0/CH0/D0.
	$devname="Maramba";
	if ($ultra eq "T5140") {
		$devname="Maramba 1U";
		$familypn="SET";
	}
	if ($ultra eq "T5240") {
		$devname="Maramba 2U";
		$familypn="SEU";
	}
	$untested=0;
	if ($model =~ /-USBRDT-5240/) {
		$devname="Thunder";
		$untested=1;
	}
	if ($ultra eq "T6340") {
		$devname="Scottsdale";
		$familypn="T6340";
	}
	if ($model =~ /Netra.*T6340/) {
		$familypn="NT6340";
		$untested=1;
	}
	$memtype="FB-DIMM";
	$simmrangex="00008000";
	$showrange=0;
	$simmbanks=4;
	$simmbanks=8 if ($ultra eq "T5240" || $ultra eq "T6340");
	$simmsperbank=4;
	@simmsizes=(1024,2048,4096,8192);
	@socketstr=("MB/CMP0/BR0/CH0/D0","MB/CMP0/BR0/CH1/D0","MB/CMP0/BR1/CH0/D0","MB/CMP0/BR1/CH1/D0","MB/CMP1/BR0/CH0/D0","MB/CMP1/BR0/CH1/D0","MB/CMP1/BR1/CH0/D0","MB/CMP1/BR1/CH1/D0","MB/CMP0/BR0/CH0/D1","MB/CMP0/BR0/CH1/D1","MB/CMP0/BR1/CH0/D1","MB/CMP0/BR1/CH1/D1","MB/CMP1/BR0/CH0/D1","MB/CMP1/BR0/CH1/D1","MB/CMP1/BR1/CH0/D1","MB/CMP1/BR1/CH1/D1");
	push(@socketstr, "MB/CMP0/MR0/BR0/CH0/D2","MB/CMP0/MR0/BR0/CH0/D3","MB/CMP0/MR0/BR0/CH1/D2","MB/CMP0/MR0/BR0/CH1/D3","MB/CMP0/MR0/BR1/CH0/D2","MB/CMP0/MR0/BR1/CH0/D3","MB/CMP0/MR0/BR1/CH1/D2","MB/CMP0/MR0/BR1/CH1/D3","MB/CMP1/MR1/BR0/CH0/D2","MB/CMP1/MR1/BR0/CH0/D3","MB/CMP1/MR1/BR0/CH1/D2","MB/CMP1/MR1/BR0/CH1/D3","MB/CMP1/MR1/BR1/CH0/D2","MB/CMP1/MR1/BR1/CH0/D3","MB/CMP1/MR1/BR1/CH1/D2","MB/CMP1/MR1/BR1/CH1/D3") if ($ultra eq "T5240");
	push(@socketstr, "MB/CMP0/BR0/CH0/D2","MB/CMP0/BR0/CH0/D3","MB/CMP0/BR0/CH1/D2","MB/CMP0/BR0/CH1/D3","MB/CMP0/BR1/CH0/D2","MB/CMP0/BR1/CH0/D3","MB/CMP0/BR1/CH1/D2","MB/CMP0/BR1/CH1/D3","MB/CMP1/BR0/CH0/D2","MB/CMP1/BR0/CH0/D3","MB/CMP1/BR0/CH1/D2","MB/CMP1/BR0/CH1/D3","MB/CMP1/BR1/CH0/D2","MB/CMP1/BR1/CH0/D3","MB/CMP1/BR1/CH1/D2","MB/CMP1/BR1/CH1/D3") if ($ultra eq "T6340");
	&check_for_LDOM;
}
if ($ultra eq "T5440") {
	# T5440 has 4 UltraSPARC-T2+ (Victoria Falls) multicore processors
	# Netra-T5440 has 2 UltraSPARC-T2+ (Victoria Falls) multicore processors
	# 16GB to 256GB Fully Buffered ECC-registered DDR2 @ 667MHz
	# Supports 2GB, 4GB and 8GB DIMMs.
	# All FB-DIMMs must be the same density (same type and Sun part number)
	#
	# Note - FB-DIMM names in ILOM messages are displayed with the full FRU
	# name, such as /SYS/MB/CMP0/BR0/CH0/D0.
	$devname="Batoka" if ($ultra eq "T5440");
	$devname="Congo" if ($model =~ /Netra-T5440/);
	$devname="Lightning" if ($model =~ /-USBRDT-5440/);
	$untested=0;
	$untested=1 if ($model =~ /-USBRDT-5440/);
	$memtype="FB-DIMM";
	$simmrangex="00004000";
	$showrange=0;
	$simmbanks=4;
	$simmsperbank=4;
	@simmsizes=(2048,4096,8192);
	if ($model =~ /Netra-T5440/) {
		$familypn="NT544";
		@socketstr=("MB/CMP0/BR0/CH0/D0","MB/CMP0/BR0/CH1/D0","MB/CMP0/BR1/CH0/D0","MB/CMP0/BR1/CH1/D0","MB/CMP1/BR0/CH0/D0","MB/CMP1/BR0/CH1/D0","MB/CMP1/BR1/CH0/D0","MB/CMP1/BR1/CH1/D0","MB/CMP0/BR0/CH0/D1","MB/CMP0/BR0/CH1/D1","MB/CMP0/BR1/CH0/D1","MB/CMP0/BR1/CH1/D1","MB/CMP1/BR0/CH0/D1","MB/CMP1/BR0/CH1/D1","MB/CMP1/BR1/CH0/D1","MB/CMP1/BR1/CH1/D1","MB/CMP0/MR0/BR0/CH0/D2","MB/CMP0/MR0/BR0/CH0/D3","MB/CMP0/MR0/BR0/CH1/D2","MB/CMP0/MR0/BR0/CH1/D3","MB/CMP0/MR0/BR1/CH0/D2","MB/CMP0/MR0/BR1/CH0/D3","MB/CMP0/MR0/BR1/CH1/D2","MB/CMP0/MR0/BR1/CH1/D3","MB/CMP1/MR1/BR0/CH0/D2","MB/CMP1/MR1/BR0/CH0/D3","MB/CMP1/MR1/BR0/CH1/D2","MB/CMP1/MR1/BR0/CH1/D3","MB/CMP1/MR1/BR1/CH0/D2","MB/CMP1/MR1/BR1/CH0/D3","MB/CMP1/MR1/BR1/CH1/D2","MB/CMP1/MR1/BR1/CH1/D3");
	} else {
		$familypn="SEV";
		@socketstr=("MB/CPU0/CMP0/BR0/CH0/D0","MB/CPU0/CMP0/BR0/CH1/D0","MB/CPU0/CMP0/BR1/CH0/D0","MB/CPU0/CMP0/BR1/CH1/D0","MB/MEM0/CMP0/BR0/CH0/D1","MB/MEM0/CMP0/BR0/CH1/D1","MB/MEM0/CMP0/BR1/CH0/D1","MB/MEM0/CMP0/BR1/CH1/D1","MB/CPU1/CMP1/BR0/CH0/D0","MB/CPU1/CMP1/BR0/CH1/D0","MB/CPU1/CMP1/BR1/CH0/D0","MB/CPU1/CMP1/BR1/CH1/D0","MB/MEM1/CMP1/BR0/CH0/D1","MB/MEM1/CMP1/BR0/CH1/D1","MB/MEM1/CMP1/BR1/CH0/D1","MB/MEM1/CMP1/BR1/CH1/D1","MB/CPU2/CMP2/BR0/CH0/D0","MB/CPU2/CMP2/BR0/CH1/D0","MB/CPU2/CMP2/BR1/CH0/D0","MB/CPU2/CMP2/BR1/CH1/D0","MB/MEM2/CMP2/BR0/CH0/D1","MB/MEM2/CMP2/BR0/CH1/D1","MB/MEM2/CMP2/BR1/CH0/D1","MB/MEM2/CMP2/BR1/CH1/D1","MB/CPU3/CMP3/BR0/CH0/D0","MB/CPU3/CMP3/BR0/CH1/D0","MB/CPU3/CMP3/BR1/CH0/D0","MB/CPU3/CMP3/BR1/CH1/D0","MB/MEM3/CMP3/BR0/CH0/D1","MB/MEM3/CMP3/BR0/CH1/D1","MB/MEM3/CMP3/BR1/CH0/D1","MB/MEM3/CMP3/BR1/CH1/D1");
	}
	&check_for_LDOM;
}
if ($ultra eq "T3-1" || $ultra eq "T3-1B") {
	# SPARC T3-1 and T3-1B have 1 SPARC-T3 (Rainbow Falls) multicore
	#  processor with 8-Threads, 16-Core, 1.65GHz
	# 16 DIMM slots for up to 128GB memory (16 x 8GB), 8GB min (4 x 2GB)
	# supports 2GB, 4GB & 8GB DDR3 DIMMs, dual-rank
	# DIMM slots are organized into four branches, with each branch
	#  connected to a separate Buffer-on-Board (BOB) ASIC, designated BOB0
	#  through BOB3. Each BOB ASIC has two DDR3 channels, with each channel
	#  supporting two DIMMs.
	# Populate the 4 blue slots first (CH1/D0), the 4 white slots second
	#  (CH0/D0), and the 8 black slots third (D1).
	$memtype="DDR3 DIMM";
	$simmrangex="00004000";
	$showrange=0;
	$simmbanks=4;
	# Assume largest DIMMs installed for prtconf-only data
	$simmsperbank=&roundup_memory($installed_memory) / 8192;
	@simmsizes=(2048,4096,8192);
	$familypn="SE3" if ($ultra eq "T3-1");
	$familypn="T31B" if ($ultra eq "T3-1B");
	$familypn="NST3" if ($ultra eq "T3-1" && $banner =~ /Netra/i);
	$untested=0 if ($ultra eq "T3-1" || $ultra eq "T3-1B");
	$untested=1 if ($banner =~ /Netra/i);
	@socketstr=("MB/CMP0/BOB0/CH1/D0","MB/CMP0/BOB1/CH1/D0","MB/CMP0/BOB2/CH1/D0","MB/CMP0/BOB3/CH1/D0","MB/CMP0/BOB0/CH0/D0","MB/CMP0/BOB1/CH0/D0","MB/CMP0/BOB2/CH0/D0","MB/CMP0/BOB3/CH0/D0","MB/CMP0/BOB0/CH1/D1","MB/CMP0/BOB1/CH1/D1","MB/CMP0/BOB2/CH1/D1","MB/CMP0/BOB3/CH1/D1","MB/CMP0/BOB0/CH0/D1","MB/CMP0/BOB1/CH0/D1","MB/CMP0/BOB2/CH0/D1","MB/CMP0/BOB3/CH0/D1");
	&check_for_LDOM;
}
if ($ultra eq "T3-1BA") {
	# Netra SPARC T3-1BA has 1 SPARC-T3 (Rainbow Falls) multicore processor
	#  with 8-Threads, 12-Core, 1.4GHz
	# 8 DIMM slots, 2GB or 4GB DDR3, all slots must be populated same
	# 16GB min (8 x 2GB), 32GB max (8 x 4GB)
	$memtype="DDR3 DIMM";
	$simmrangex="00004000";
	$showrange=0;
	$simmbanks=1;
	$simmsperbank=8;
	@simmsizes=(2048,4096);
	$untested=1;
	@socketstr=("DIMM0".."DIMM7"); # Guess
	&check_for_LDOM;
}
if ($ultra eq "T3-2") {
	# SPARC T3-2 has 2 SPARC-T3 (Rainbow Falls) multicore processors, each
	#  with 8-Threads, 16-Core, 1.65GHz
	# 32 DIMM slots for up to 256GB memory (32 x 8GB), 64GB min (16 x 4GB)
	# supports 4GB & 8GB DDR3 DIMMs, dual-rank
	# A maximum of two memory risers (MR0 & MR1) supported per CPU, thus
	#  allowing up to four memory risers total.
	# Each memory riser slot in the server chassis must be filled with
	#  either a memory riser or filler panel, and each memory riser must be
	#  filled with DIMMs and/or DIMM filler panels.
	# Each memory riser has 8 DIMM slots (D0-D3 for MB1, D4-D7 for MB0)
	# Install D0/D4 (blue), then D2/D6 (white), then D1/D5 (black), and
	#  then D3/D7 (green).
	# Performance-oriented configurations should be configured with two
	#  memory risers per CPU. In configurations that do not require two
	#  memory risers per CPU, the following guidelines should be followed:
	#  - Populate riser slot MR0 for each CPU, starting with the lowest
	#    numbered CPU (P0).
	#  - Populate riser slot MR1 for each CPU, starting with the lowest
	#    numbered CPU (P0).
	$memtype="DDR3 DIMM";
	$simmrangex="00004000";
	$showrange=0;
	$simmbanks=4;
	# Assume largest DIMMs installed for prtconf-only data
	$simmsperbank=&roundup_memory($installed_memory) / 8192;
	@simmsizes=(4096,8192);
	$familypn="SE4";
	$untested=0;
	$untested=1 if ($banner =~ /Netra/i);
	@socketstr=("MB/CMP0/MR0/BOB0/CH0/D0","MB/CMP0/MR0/BOB0/CH1/D0","MB/CMP0/MR0/BOB1/CH0/D0","MB/CMP0/MR0/BOB1/CH1/D0","MB/CMP1/MR0/BOB0/CH0/D0","MB/CMP1/MR0/BOB0/CH1/D0","MB/CMP1/MR0/BOB1/CH0/D0","MB/CMP1/MR0/BOB1/CH1/D0","MB/CMP0/MR1/BOB0/CH0/D0","MB/CMP0/MR1/BOB0/CH1/D0","MB/CMP0/MR1/BOB1/CH0/D0","MB/CMP0/MR1/BOB1/CH1/D0","MB/CMP1/MR1/BOB0/CH0/D0","MB/CMP1/MR1/BOB0/CH1/D0","MB/CMP1/MR1/BOB1/CH0/D0","MB/CMP1/MR1/BOB1/CH1/D0","MB/CMP0/MR0/BOB0/CH0/D1","MB/CMP0/MR0/BOB0/CH1/D1","MB/CMP0/MR0/BOB1/CH0/D1","MB/CMP0/MR0/BOB1/CH1/D1","MB/CMP1/MR0/BOB0/CH0/D1","MB/CMP1/MR0/BOB0/CH1/D1","MB/CMP1/MR0/BOB1/CH0/D1","MB/CMP1/MR0/BOB1/CH1/D1","MB/CMP0/MR1/BOB0/CH0/D1","MB/CMP0/MR1/BOB0/CH1/D1","MB/CMP0/MR1/BOB1/CH0/D1","MB/CMP0/MR1/BOB1/CH1/D1","MB/CMP1/MR1/BOB0/CH0/D1","MB/CMP1/MR1/BOB0/CH1/D1","MB/CMP1/MR1/BOB1/CH0/D1","MB/CMP1/MR1/BOB1/CH1/D1");
	&check_for_LDOM;
}
if ($ultra eq "T3-4") {
	# SPARC T3-4 has 2 or 4 SPARC-T3 (Rainbow Falls) multicore processors,
	#  each with 8-Threads, 16-Core, 1.65GHz
	# 64 DIMM slots for up to 512GB memory (64 x 8GB), 128GB min (32 x 4GB)
	# supports 4GB & 8GB DDR3 DIMMs, dual-rank
	$memtype="DDR3 DIMM";
	$simmrangex="00004000";
	$showrange=0;
	$simmbanks=4;
	# Assume largest DIMMs installed for prtconf-only data
	$simmsperbank=&roundup_memory($installed_memory) / 8192;
	@simmsizes=(4096,8192);
	$familypn="SE5";
	$untested=1;
	$untested=1 if ($banner =~ /Netra/i);
	# Guess on socket name order ???
	@socketstr=("PM0/CMP1/BOB0/CH0/D0","PM0/CMP1/BOB0/CH1/D0","PM0/CMP1/BOB1/CH0/D0","PM0/CMP1/BOB1/CH1/D0","PM0/CMP1/BOB2/CH0/D0","PM0/CMP1/BOB2/CH1/D0","PM0/CMP1/BOB3/CH0/D0","PM0/CMP1/BOB3/CH1/D0","PM0/CMP0/BOB0/CH0/D0","PM0/CMP0/BOB0/CH1/D0","PM0/CMP0/BOB1/CH0/D0","PM0/CMP0/BOB1/CH1/D0","PM0/CMP0/BOB2/CH0/D0","PM0/CMP0/BOB2/CH1/D0","PM0/CMP0/BOB3/CH0/D0","PM0/CMP0/BOB3/CH1/D0");
	push(@socketstr, "PM0/CMP1/BOB0/CH0/D1","PM0/CMP1/BOB0/CH1/D1","PM0/CMP1/BOB1/CH0/D1","PM0/CMP1/BOB1/CH1/D1","PM0/CMP1/BOB2/CH0/D1","PM0/CMP1/BOB2/CH1/D1","PM0/CMP1/BOB3/CH0/D1","PM0/CMP1/BOB3/CH1/D1","PM0/CMP0/BOB0/CH0/D1","PM0/CMP0/BOB0/CH1/D1","PM0/CMP0/BOB1/CH0/D1","PM0/CMP0/BOB1/CH1/D1","PM0/CMP0/BOB2/CH0/D1","PM0/CMP0/BOB2/CH1/D1","PM0/CMP0/BOB3/CH0/D1","PM0/CMP0/BOB3/CH1/D1");
	# Need to determine if PM1 is installed, its DIMMs are next
	push(@socketstr, "PM1/CMP1/BOB0/CH0/D0","PM1/CMP1/BOB0/CH1/D0","PM1/CMP1/BOB1/CH0/D0","PM1/CMP1/BOB1/CH1/D0","PM1/CMP1/BOB2/CH0/D0","PM1/CMP1/BOB2/CH1/D0","PM1/CMP1/BOB3/CH0/D0","PM1/CMP1/BOB3/CH1/D0","PM1/CMP0/BOB0/CH0/D0","PM1/CMP0/BOB0/CH1/D0","PM1/CMP0/BOB1/CH0/D0","PM1/CMP0/BOB1/CH1/D0","PM1/CMP0/BOB2/CH0/D0","PM1/CMP0/BOB2/CH1/D0","PM1/CMP0/BOB3/CH0/D0","PM1/CMP0/BOB3/CH1/D0");
	push(@socketstr, "PM1/CMP1/BOB0/CH0/D1","PM1/CMP1/BOB0/CH1/D1","PM1/CMP1/BOB1/CH0/D1","PM1/CMP1/BOB1/CH1/D1","PM1/CMP1/BOB2/CH0/D1","PM1/CMP1/BOB2/CH1/D1","PM1/CMP1/BOB3/CH0/D1","PM1/CMP1/BOB3/CH1/D1","PM1/CMP0/BOB0/CH0/D1","PM1/CMP0/BOB0/CH1/D1","PM1/CMP0/BOB1/CH0/D1","PM1/CMP0/BOB1/CH1/D1","PM1/CMP0/BOB2/CH0/D1","PM1/CMP0/BOB2/CH1/D1","PM1/CMP0/BOB3/CH0/D1","PM1/CMP0/BOB3/CH1/D1");
	&check_for_LDOM;
}
if ($ultra eq "T4-1" || $ultra eq "T4-1B") {
	# SPARC T4-1 and T4-1B have 1 SPARC-T4 multicore processor with
	#  8-Threads, 8-Core, 2.85GHz
	# 16 DIMM slots for up to 256GB memory (16 x 16GB), 16GB min (4 x 4GB)
	# supports 4GB, 8GB & 16GB DDR3 DIMMs
	# DIMM slots are organized into four branches, with each branch
	#  connected to a separate Buffer-on-Board (BOB) ASIC, designated BOB0
	#  through BOB3. Each BOB ASIC has two DDR3 channels, with each channel
	#  supporting two DIMMs.
	# Populate the 4 blue slots first (CH1/D0), the 4 white slots second
	#  (CH0/D0), and the 8 black slots third (D1).
	$memtype="DDR3 DIMM";
	$simmrangex="00008000";	# Guess
	$showrange=0;
	$simmbanks=4;
	# Assume largest DIMMs installed for prtconf-only data
	$simmsperbank=&roundup_memory($installed_memory) / 16384;
	@simmsizes=(4096,8192,16384);
	$familypn="T41B" if ($ultra eq "T4-1B");
	$untested=0 if ($ultra eq "T4-1");
	@socketstr=("MB/CMP0/BOB0/CH1/D0","MB/CMP0/BOB1/CH1/D0","MB/CMP0/BOB2/CH1/D0","MB/CMP0/BOB3/CH1/D0","MB/CMP0/BOB0/CH0/D0","MB/CMP0/BOB1/CH0/D0","MB/CMP0/BOB2/CH0/D0","MB/CMP0/BOB3/CH0/D0","MB/CMP0/BOB0/CH1/D1","MB/CMP0/BOB1/CH1/D1","MB/CMP0/BOB2/CH1/D1","MB/CMP0/BOB3/CH1/D1","MB/CMP0/BOB0/CH0/D1","MB/CMP0/BOB1/CH0/D1","MB/CMP0/BOB2/CH0/D1","MB/CMP0/BOB3/CH0/D1");
	&check_for_LDOM;
}
if ($ultra eq "T4-2" || $ultra eq "T4-2B") {
	# SPARC T4-2 and T4-2B have 2 SPARC-T4 multicore processor with
	#  8-Threads, 8-Core, 2.85GHz
	# 32 DIMM slots for up to 512GB memory (32 x 16GB), 64GB min (16 x 4GB)
	# supports 4GB, 8GB & 16GB DDR3 DIMMs
	$memtype="DDR3 DIMM";
	$simmrangex="00008000";	# Guess
	$showrange=0;
	$simmbanks=8;
	# Assume largest DIMMs installed for prtconf-only data
	$simmsperbank=&roundup_memory($installed_memory) / 16384;
	@simmsizes=(4096,8192,16384);
	$untested=0 if ($ultra eq "T4-2");
	$untested=1 if ($banner =~ /Netra/i);
	@socketstr=("MB/CMP0/MR0/BOB0/CH0/D0","MB/CMP0/MR0/BOB0/CH1/D0","MB/CMP0/MR0/BOB1/CH0/D0","MB/CMP0/MR0/BOB1/CH1/D0","MB/CMP1/MR0/BOB0/CH0/D0","MB/CMP1/MR0/BOB0/CH1/D0","MB/CMP1/MR0/BOB1/CH0/D0","MB/CMP1/MR0/BOB1/CH1/D0","MB/CMP0/MR1/BOB0/CH0/D0","MB/CMP0/MR1/BOB0/CH1/D0","MB/CMP0/MR1/BOB1/CH0/D0","MB/CMP0/MR1/BOB1/CH1/D0","MB/CMP1/MR1/BOB0/CH0/D0","MB/CMP1/MR1/BOB0/CH1/D0","MB/CMP1/MR1/BOB1/CH0/D0","MB/CMP1/MR1/BOB1/CH1/D0","MB/CMP0/MR0/BOB0/CH0/D1","MB/CMP0/MR0/BOB0/CH1/D1","MB/CMP0/MR0/BOB1/CH0/D1","MB/CMP0/MR0/BOB1/CH1/D1","MB/CMP1/MR0/BOB0/CH0/D1","MB/CMP1/MR0/BOB0/CH1/D1","MB/CMP1/MR0/BOB1/CH0/D1","MB/CMP1/MR0/BOB1/CH1/D1","MB/CMP0/MR1/BOB0/CH0/D1","MB/CMP0/MR1/BOB0/CH1/D1","MB/CMP0/MR1/BOB1/CH0/D1","MB/CMP0/MR1/BOB1/CH1/D1","MB/CMP1/MR1/BOB0/CH0/D1","MB/CMP1/MR1/BOB0/CH1/D1","MB/CMP1/MR1/BOB1/CH0/D1","MB/CMP1/MR1/BOB1/CH1/D1");
	&check_for_LDOM;
}
if ($ultra eq "T4-4") {
	# SPARC T4-4 has 4 SPARC-T4 multicore processor with
	#  8-Threads, 8-Core, 3.0GHz
	# 64 DIMM slots for up to 1TB memory (64 x 16GB), 64GB min (16 x 4GB)
	# supports 4GB, 8GB & 16GB DDR3 DIMMs
	$memtype="DDR3 DIMM";
	$simmrangex="00008000";	# Guess
	$showrange=0;
	$simmbanks=16;
	# Assume largest DIMMs installed for prtconf-only data
	$simmsperbank=&roundup_memory($installed_memory) / 16384;
	@simmsizes=(4096,8192,16384);
	$untested=0;
	$untested=1 if ($banner =~ /Netra/i);
	@socketstr=("/SYS/PM0/CMP0/BOB0/CH0/D0","/SYS/PM0/CMP0/BOB0/CH1/D0","/SYS/PM0/CMP0/BOB1/CH0/D0","/SYS/PM0/CMP0/BOB1/CH1/D0","/SYS/PM0/CMP0/BOB2/CH0/D0","/SYS/PM0/CMP0/BOB2/CH1/D0","/SYS/PM0/CMP0/BOB3/CH0/D0","/SYS/PM0/CMP0/BOB3/CH1/D0","/SYS/PM0/CMP1/BOB0/CH0/D0","/SYS/PM0/CMP1/BOB0/CH1/D0","/SYS/PM0/CMP1/BOB1/CH0/D0","/SYS/PM0/CMP1/BOB1/CH1/D0","/SYS/PM0/CMP1/BOB2/CH0/D0","/SYS/PM0/CMP1/BOB2/CH1/D0","/SYS/PM0/CMP1/BOB3/CH0/D0","/SYS/PM0/CMP1/BOB3/CH1/D0","/SYS/PM1/CMP0/BOB0/CH0/D0","/SYS/PM1/CMP0/BOB0/CH1/D0","/SYS/PM1/CMP0/BOB1/CH0/D0","/SYS/PM1/CMP0/BOB1/CH1/D0","/SYS/PM1/CMP0/BOB2/CH0/D0","/SYS/PM1/CMP0/BOB2/CH1/D0","/SYS/PM1/CMP0/BOB3/CH0/D0","/SYS/PM1/CMP0/BOB3/CH1/D0","/SYS/PM1/CMP1/BOB0/CH0/D0","/SYS/PM1/CMP1/BOB0/CH1/D0","/SYS/PM1/CMP1/BOB1/CH0/D0","/SYS/PM1/CMP1/BOB1/CH1/D0","/SYS/PM1/CMP1/BOB2/CH0/D0","/SYS/PM1/CMP1/BOB2/CH1/D0","/SYS/PM1/CMP1/BOB3/CH0/D0","/SYS/PM1/CMP1/BOB3/CH1/D0");
	&check_for_LDOM;
}
if ($ultra eq "T5-2") {
	# SPARC T5-2 has 2 SPARC-T5 multicore processor with
	#  8-Threads, 16-Core, 3.6GHz
	# 32 DIMM slots for up to 1TB memory (32 x 32GB), 256GB min (32 x 8GB)
	# supports 8GB, 16GB & 32GB DDR3 DIMMs
	# Each slot on a memory riser must be filled with a DIMM
	# All memory risers must contain the same type of DIMM
	$memtype="DDR3 DIMM";
	$showrange=0;
	@simmsizes=(8192,16384,32768);
	$untested=0;
	# /SYS/MB/CM0/CMP/MR0/BOB0/CH0/D0 - /SYS/MB/CM1/CMP/MR3/BOB1/CH1/D0
	for $s_cm (0,1) {
		for $s_mr (0..3) {
			for $s_bob (0,1) {
				for $s_ch (0,1) {
					push(@socketstr, "/SYS/MB/CM$s_cm/CMP/MR$s_mr/BOB$s_bob/CH$s_ch/D0");
				}
			}
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "T5-4") {
	# SPARC T5-4 has 4 SPARC-T5 multicore processor with
	#  8-Threads, 16-Core, 3.6GHz
	# 64 DIMM slots for 2TB memory (64 x 32GB) or 1TB min (64 x 16GB)
	# supports 16GB & 32GB DDR3 DIMMs
	# All DIMMs installed in the server must have identical capacities
	# All DIMMs installed in each processor module must be identical
	$memtype="DDR3 DIMM";
	$showrange=0;
	@simmsizes=(16384,32768);
	$untested=0;
	# /SYS/PM0/CM0/CMP/BOB0/CH0/D0 - /SYS/PM1/CM1/CMP/BOB7/CH1/D0
	for $s_pm (0,1) {
		for $s_cm (0,1) {
			for $s_bob (0..7) {
				for $s_ch (0,1) {
					push(@socketstr, "/SYS/PM$s_pm/CM$s_cm/CMP/BOB$s_bob/CH$s_ch/D0");
				}
			}
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "T5-8") {
	# SPARC T5-8 has 8 SPARC-T5 multicore processor with
	#  8-Threads, 16-Core, 3.6GHz
	# 128 DIMM slots for 4TB memory (128 x 32GB) or 2TB min (128 x 16GB)
	# supports 16GB & 32GB DDR3 DIMMs
	# All DIMMs installed in the server must have identical capacities
	# All DIMMs installed in each processor module must be identical
	$memtype="DDR3 DIMM";
	$showrange=0;
	@simmsizes=(16384,32768);
	$untested=1;
	# /SYS/PM0/CM0/CMP/BOB0/CH0/D0 - /SYS/PM3/CM1/CMP/BOB7/CH1/D0
	for $s_pm (0..3) {
		for $s_cm (0,1) {
			for $s_bob (0..7) {
				for $s_ch (0,1) {
					push(@socketstr, "/SYS/PM$s_pm/CM$s_cm/CMP/BOB$s_bob/CH$s_ch/D0");
				}
			}
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "T5-1B") {
	# SPARC T5-1B has 1 SPARC-T5 multicore processor with
	#  8-Threads, 16-Core, 3.6GHz
	# 16 DIMM slots for up to 512GB memory (16 x 32GB), 128GB min (16 x 8GB)
	# supports 8GB, 16GB & 32GB DDR3 DIMMs
	# Install quantities of 16 DIMMs
	# Ensure that all DIMMs are the same capacity and rank classification
	$memtype="DDR3 DIMM";
	$showrange=0;
	@simmsizes=(8192,16384,32768);
	$untested=1;
	# /SYS/MB/CM0/CMP/BOB0/CH0/D0 - /SYS/MB/CM0/CMP/BOB7/CH1/D0
	for $s_bob (0..7) {
		for $s_ch (0,1) {
			push(@socketstr, "/SYS/MB/CM0/CMP/BOB$s_bob/CH$s_ch/D0");
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "M5-32" || $ultra eq "M6-32") {
	# SPARC M5-32 has 8 to 32 SPARC M5 processor at 3.6GHz, each with:
	#  6 cores, 48 threads
	#  32 DIMM slots for up to 1TB memory (32 x 32GB)
	#  supports 16GB & 32GB 1066MHz DDR3 DIMMs
	# SPARC M6-32 has 8 to 32 SPARC M5 processor at 3.6GHz, each with:
	#  12 cores, 96 threads
	#  32 DIMM slots for up to 1TB memory (32 x 32GB)
	#  supports 16GB & 32GB 1066MHz DDR3 DIMMs
	# Each CMU (CPU Memory Unit) includes 2 CMPs and 64 DIMM slots
	# Each CMU can be Quarter, Half, or Fully-Populated
	#  Quarter-Populated: CMP[01]/D0000-D1101 (16 DIMMs)
	#  Half-Populated: CMP[01]/D0000-D1103 (32 DIMMs)
	#  Fully-Populated: CMP[01]/D0000-D1113 (64 DIMMs)
	$memtype="DDR3 DIMM";
	$showrange=0;
	@simmsizes=(16384,32768);
	$untested=1;
	# /SYS/CMU0/CMP0/D0000 - /SYS/CMU15/CMP1/D1113
	$s_cmu=int(($npcpu/2)-1);
	for (0..$s_cmu) {
		for $s_cmp (0,1) {
			for $s_d1 (0,1) {
				for $s_d2 (0,1) {
					for $s_d3 (0,1) {
						for $s_d4 (0..3) {
							push(@socketstr, "/SYS/CMU$s_cmu/CMP$s_cmp/D$s_d1$s_d2$s_d3$s_d4");
						}
					}
				}
			}
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "M10-1") {
	# Fujitsu SPARC M10-1 has 1 SPARC64-X processor at 2.8GHz
	#  16 cores, 32 threads
	# 16 DIMM slots for up to 512GB memory (16 x 32GB), 128GB min (16 x 8GB)
	# supports 8GB, 16GB & 32GB R-DIMM or 64GB LR-DIMM
	# Mount memory in units of four or eight modules
	# Within a unit of four or eight modules, all the DIMMs must be of the
	#  same capacity and rank
	# First mount memory group A, then mount memory group B
	$memtype="DIMM";
	$showrange=0;
	@simmsizes=(8192,16384,32768,65536);
	$untested=0;
	# /SYS/MBU/CMP0/MEM[01][0-3][AB]
	for $s_memAB ("A","B") {
		for $s_cmp (0,1) {
			for $s_memN (0..3) {
				push(@socketstr, "/SYS/MBU/CMP0/MEM$s_cmp$s_memN$s_memAB");
			}
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "M10-4" || $ultra eq "M10-4S") {
	# Fujitsu SPARC M10-4 has up to 4 SPARC64-X processor at 2.8GHz
	#  16 cores, 32 threads each
	# 32 DIMM slots per memory unit for up to 2TB memory (32 x 64GB), 64GB min (8 x 8GB)
	# supports 8GB, 16GB & 32GB R-DIMM or 64GB LR-DIMM
	# Mount memory in units of eight modules
	# Within a unit of eight modules, all the DIMMs must be of the same
	#  capacity and rank
	# First mount memory group A, then mount memory group B
	# M10-4S is a modular system that combines up to 16 M10-4 servers for
	#  up to 64 processors and up to 32TB memory
	$memtype="DIMM";
	$showrange=0;
	@simmsizes=(8192,16384,32768,65536);
	$untested=0;
	$untested=1 if ($ultra eq "M10-4S");
	if ($npcpu > 4) {	# M10-4S
		$ultra="M10-4S";
		$untested=1;
	}
	# M10-4: /BB0/CMUL/CMP0/MEM0[0-7]A - /BB0/CMUU/CMP1/MEM1[0-7]B
	# M10-4S: /BB00/CMUL/CMP0/MEM0[0-7]A - /BB15/CMUU/CMP1/MEM1[0-7]B # Guess
	$bb=int(($npcpu/4)-1);	# BB: Building Block
	for (0..$bb) {
		$bb="0$bb" if ($ultra eq "M10-4S" && $bb < 10);	# Guess
		if (($npcpu/2) % 2) {
			push(@cmus, "/BB$bb/CMUL");
		} else {
			push(@cmus, "/BB$bb/CMUU");
		}
		for $s_cmu (@cmus) {
			for $s_cmp (0,1) {
				for $s_memAB ("A","B") {
					for $s_memN (0..7) {
						push(@socketstr, "$s_cmu/CMP$s_cmp/MEM$s_cmp$s_memN$s_memAB");
					}
				}
			}
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "S7-2" || $ultra eq "S7-2L") {
	# SPARC S7-2 has 1 or 2 SPARC S7 processors at 4.267GHz
	# SPARC S7-2L has 2 SPARC S7 processors at 4.267GHz
	# Each SPARC S7 processor supports:
	#  8 cores, 8 threads.
	#  16 DIMM slots for up to 1TB memory (16 x 64GB).
	#  supports 16GB, 32GB & 64GB DDR4 DIMMs.
	#  Do not mix DIMMs sizes.
	#  Can be half populated (D0 white sockets), 4 DIMMs per CPU, or
	#   fully populated (D0 white & D1 black sockets), 8 DIMMs per CPU.
	$memtype="DDR4 DIMM";
	$showrange=0;
	@simmsizes=(16384,32768,65536);
	$untested=1;
	$untested=0 if ($ultra eq "S7-2");
	$cmp_range=0;
	$cmp_range=1 if ($ncpu eq 2 || $corecnt eq 2);
	# /SYS/MB/CMP0/MCU0/CH0/D0 - /SYS/MB/CMP1/MCU1/CH1/D1
	for $s_d (0,1) {
		for ($s_cmp=0; $s_cmp <= $cmp_range; $s_cmp++) {
			for $s_mcu (0,1) {
				for $s_ch (0,1) {
					push(@socketstr, "/SYS/MB/CMP$s_cmp/MCU$s_mcu/CH$s_ch/D$s_d");
				}
			}
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "T7-1") {
	# SPARC T7-1 has 1 SPARC M7 processors at 4.13GHz
	# SPARC M7 processor supports:
	#  32 cores, 8 threads
	#  16 DIMM slots for up to 1TB memory (16 x 64GB)
	# SPARC T7-1 supports:
	#  16GB, 32GB & 64GB DDR4 DIMMs
	#  Left Memory Riser:  /SYS/MB/CM/CMP/MR1/BOB[01]0/CH[01]
	#  Left Motherboard:   /SYS/MB/CM/CMP/BOB[13]1/CH[01]
	#  Right Motherboard:  /SYS/MB/CM/CMP/BOB[02]1/CH[01]
	#  Right Memory Riser: /SYS/MB/CM/CMP/MR0/BOB[23]0/CH[01]
	#  CH0 Black sockets, CH1 White sockets
	#  In base configuration, all DIMM slots on motherboard must be
	#   fully occupied (8 DIMMs).
	#  In upgrade configuration (16 DIMMs), both memory risers are
	#   added and must be fully occupied.
	$memtype="DDR4 DIMM";
	$showrange=0;
	@simmsizes=(16384,32768,65536);
	$untested=1;
	for $s_bob (0..3) {	# Motherboard
		for $s_ch (0,1) {
			push(@socketstr, "/SYS/MB/CM/CMP/BOB${s_bob}1/CH$s_ch");
		}
	}
	for $s_bob (0,1) {	# MR1
		for $s_ch (0,1) {
			push(@socketstr, "/SYS/MB/CM/CMP/MR1/BOB${s_bob}0/CH$s_ch");
		}
	}
	for $s_bob (2,3) {	# MR0
		for $s_ch (0,1) {
			push(@socketstr, "/SYS/MB/CM/CMP/MR0/BOB${s_bob}0/CH$s_ch");
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "T7-2") {
	# SPARC T7-2 has 2 SPARC M7 processors at 4.13GHz
	# SPARC M7 processor supports:
	#  32 cores, 8 threads
	#  16 DIMM slots for up to 1TB memory (16 x 64GB)
	# SPARC T7-2 supports:
	#  16GB, 32GB & 64GB DDR4 DIMMs
	#  /SYS/MB/CM[01]/CMP/MR[0-3]/BOB[01]/CH[01]/DIMM
	#    CH0 Black sockets, CH1 White sockets
	#    All 8 memory risers must be installed in all configurations
	#    Half-populated configurations populate CH0 Black sockets (16 DIMMs)
	#    Full-populated configurations fill CH0 and CH1 sockets (32 DIMMs)
	$memtype="DDR4 DIMM";
	$showrange=0;
	@simmsizes=(16384,32768,65536);
	$untested=1;
	for $s_ch (0,1) {
		for $s_cm (0,1) {
			for $s_mr (0..3) {
				for $s_bob (0,1) {
					push(@socketstr, "/SYS/MB/CM$s_cm/CMP/MR$s_mr/BOB$s_bob/CH$s_ch/DIMM");
				}
			}
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "T7-4") {
	# SPARC T7-4 has 2 or 4 SPARC M7 processors at 4.13GHz
	# SPARC M7 processor supports:
	#  32 cores, 8 threads
	#  16 DIMM slots for up to 1TB memory (16 x 64GB)
	# SPARC T7-4 supports:
	#  16GB, 32GB & 64GB DDR4 DIMMs
	#  /SYS/PM[0-3]/CM[01]/CMP/BOB[0-3][01]/CH[01]/DIMM
	#    CH0 Black sockets, CH1 White sockets
	#    Half-populated configurations populate CH0 Black sockets (16 DIMMs)
	#    Full-populated configurations fill CH0 and CH1 sockets (32 DIMMs)
	$memtype="DDR4 DIMM";
	$showrange=0;
	@simmsizes=(16384,32768,65536);
	$untested=0;
	for $s_pm (0..$npcpu-1) {
		for $s_ch (0,1) {
			for $s_cm (0,1) {
				for $s_boba (0..3) {
					for $s_bobb (0,1) {
						push(@socketstr, "/SYS/PM$s_pm/CM$s_cm/CMP/BOB$s_boba$s_bobb/CH$s_ch/DIMM");
					}
				}
			}
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "M7-8" || $ultra eq "M7-16") {
	# SPARC M7-8 has 2 to 8 SPARC M7 processors at 4.13GHz
	# SPARC M7-16 has 4 to 16 SPARC M7 processors at 4.13GHz
	# Each SPARC M7 processor has 32 cores, 8 threads
	# SPARC M7-8 & M7-16 supports:
	#  16 DIMM slots for up to 512GB memory (16 x 32GB)
	#  supports 16GB & 32GB DDR4 DIMMs
	#  SPARC M7-8, has CMIOU_0 to CMIOU_7
	#  SPARC M7-16, has CMIOU_0 to CMIOU_15
	#  /SYS/CMIOU[0-15]/CM/CMP/BOB[0-3][01]/CH[01]/DIMM
	#    CH0 Black sockets, CH1 White sockets
	#    Half-populated configurations populate CH0 Black sockets (8 DIMMs)
	#    Full-populated configurations fill CH0 and CH1 sockets (16 DIMMs)
	$memtype="DDR4 DIMM";
	$showrange=0;
	@simmsizes=(16384,32768);
	$untested=1;
	for $s_cmiou (0..$npcpu-1) {
		for $s_ch (0,1) {
			for $s_boba (0..3) {
				for $s_bobb (0,1) {
					push(@socketstr, "/SYS/CM$s_cmiou/CM/CMP/BOB$s_boba$s_bobb/CH$s_ch/DIMM");
				}
			}
		}
	}
	&check_for_LDOM;
}
if ($ultra eq "T8-2") {
	# SPARC T8-2 has 2 SPARC M8 processors at 5.0GHz
	# SPARC T8-2 supports:
	#  16GB, 32GB & 64GB DDR4 DIMMs
	#  /SYS/MB/CM[01]/CMP/MR[0-3]/BOB[01]/CH[01]/DIMM
	#    CH0 Black sockets, CH1 White sockets
	#    All 8 memory risers must be installed in all configurations
	#    Half-populated configurations populate CH0 Black sockets (16 DIMMs)
	#    Full-populated configurations fill CH0 and CH1 sockets (32 DIMMs)
	$memtype="DDR4 DIMM";
	$showrange=0;
	@simmsizes=(16384,32768,65536);
	$untested=0;
	for $s_ch (0,1) {
		for $s_cm (0,1) {
			for $s_mr (0..3) {
				for $s_bob (0,1) {
					push(@socketstr, "/SYS/MB/CM$s_cm/CMP/MR$s_mr/BOB$s_bob/CH$s_ch/DIMM");
				}
			}
		}
	}
	&check_for_LDOM;
}
if ($model eq "SPARC-Enterprise" || $ultra =~ /SPARC Enterprise M[34589]000 Server/) {
	# CPUs:  Dual-Core Dual-Thread SPARC64-VI or
	#        Quad-Core Dual-Thread SPARC64-VII, VII+, VII++
	# M3000: 2RU rack, single SPARC64-VII 2.52GHz cpu
	#        up to 32GB, uses DDR2-533 4GB or 8GB memory DIMMs
	# M4000: 6RU rack, up to 4 SPARC64-VI or SPARC64-VII cpus
	#        Up to 2 CPU (CMU), 2 CPUs per board
	#        Main memory Up to 128 GB per domain / system, up to 4 memory
	#        boards w/ maximum 32GB per board using 8 DDR2 4GB memory DIMMs
	# M5000: 10RU rack, up to 8 SPARC64-VI or SPARC64-VII cpus
	#        Up to 4 CPU (CMU), 2 CPUs per board
	#        Main memory Up to 256 GB per domain / system, up to 8 memory
	#        boards w/ maximum 32GB per board using 8 DDR2 4GB memory DIMMs
	# M8000: up to 16 SPARC64-VI or SPARC64-VII cpus
	#        Up to 4 CPU memory boards (CMU), Up to 4 processors and up to
	#        128 GB memory per board based on 32 4GB DIMMs
	#        Main memory Up to 512GB per domain / system
	# M9000: 32 or 64 SPARC64-VI or SPARC64-VII cpus
	#    32 CPU
	#        Up to 8 CPU memory boards (CMU), Up to 4 processors and up to
	#        128 GB memory per board based on 32 4GB DIMMs
	#        Main memory Up to 1TB per domain / system
	#    64 CPU
	#        Up to 16 CPU memory boards (CMU), Up to 4 processors and up to
	#        128 GB memory per board based on 32 4GB DIMMs
	#        Main memory Up to 2TB per domain / system
	$familypn="SEW" if ($ultra =~ /Sun SPARC Enterprise M3000 Server/);
	if ($ultra =~ /Sun SPARC Enterprise M4000 Server/) {
		$devname="OPL FF1";
		$familypn="SEE";
	}
	if ($ultra =~ /Sun SPARC Enterprise M5000 Server/) {
		$devname="OPL FF2";
		$familypn="SEF";
	}
	$familypn="SEG" if ($ultra =~ /Sun SPARC Enterprise M8000 Server/);
	$familypn="SEH/SEJ" if ($ultra =~ /Sun SPARC Enterprise M9000 Server/);
	$untested=1;
	$untested=0 if ($ultra =~ /SPARC Enterprise M[34589]000 Server/);
	$prtdiag_has_mem=1;
	@simmsizes=(1024,2048,4096);
}
if (($model =~ /-Enterprise/ || $ultra eq "e") && $model !~ /SPARC-Enterprise/) {
	# E3x00/E4x00/E5x00/E6x00 accepts 8MB, 32MB, 128MB or 256MB DIMMs on
	#  motherboard, 2 banks of 8 DIMMs per board.
	#  256MB DIMMs (2GB kit X7026A) can be used with OBP 3.2.24 or later and
	#  Solaris 2.5.1 11/97, Solaris 2.6 3/98 or later
	#   501-2652 (8MB), 501-2653 (32MB), 501-2654 (128MB), 501-5658 (256MB)
	#   168-pin 60ns 3.3V ECC
	# E10000 accepts 32MB or 128MB DIMMs on motherboard,
	#  using 2 or 4 banks of 8 DIMMs per board.
	#   501-2653 (32MB), 501-2654 (128MB)
	#   168-pin 60ns 3.3V ECC
	$devname="Duraflame" if ($banner =~ /\bE?3[05]00\b/);
	$devname="Campfire Rack" if ($banner =~ /\bE?5[05]00\b/);
	$devname="Campfire" if ($banner =~ /\bE?4[05]00\b/);
	$devname="Sunfire" if ($banner =~ /\bE?6[05]00\b/);
	$devname .= "+" if ($banner =~ /\bE?[3-6]500\b/);
	$devname="Starfire" if ($model =~ /-10000\b/);
	$familypn="E3000, A17" if ($banner =~ /\bE?3000\b/);
	$familypn="E3500" if ($banner =~ /\bE?3500\b/);
	$familypn="E4000, A18" if ($banner =~ /\bE?4000\b/);
	$familypn="E4500" if ($banner =~ /\bE?4500\b/);
	$familypn="E5000" if ($banner =~ /\bE?5000\b/);
	$familypn="E5500" if ($banner =~ /\bE?5500\b/);
	$familypn="E6000" if ($banner =~ /\bE?6000\b/);
	$familypn="E6500" if ($banner =~ /\bE?6500\b/);
	$familypn="E10000" if ($model =~ /-10000\b/);
	$untested=1;
	if ($banner =~ /\bE?[3-6][05]00\b/ || $model =~ /-Enterprise-E?[3-6][05]00/ || $model eq "Ultra-Enterprise") {
		$untested=0;
		@simmsizes=(8,32,128,256);
	}
	if ($model =~ /-Enterprise-10000\b/) {
		$untested=0;
		@simmsizes=(32,128);
	}
	$prtdiag_has_mem=1;
	@prtdiag=&run("$prtdiag_exec") if (! $filename);
	$i=0;
	$flag_cpu=0;
	$flag_mem=0;
	foreach $line (@prtdiag) {
		$line=&dos2unix($line);
		if ($line =~ /Memory Units:/) {
			# Start of memory section, Solaris 2.5.1 format
			$flag_mem=1;
			$format_mem=1;
			$flag_cpu=0;	# End of CPU section
		}
		if ($line =~ /====( | Physical )Memory /) {
			# Start of memory section, Solaris 2.6 and later format
			$flag_mem=1;
			$format_mem=2;
			$flag_cpu=0;	# End of CPU section
		}
		if ($line =~ /Factor/) {
			# No interleave factor on E10000
			$format_mem += 2 if ($format_mem == 1 || $format_mem == 2);
		}
		if ($line =~ /Failed Field Replaceable Unit/) {
			$tmp=$line;
			$tmp=~s/^\t/       /g;
			$failed_fru .= $tmp;
		}
		if ($line =~ /IO Cards/) {
			$flag_cpu=0;	# End of CPU section
			$flag_mem=0;	# End of memory section
		}
		if ($flag_cpu && $line !~ /^\s*\n$/) {
			push(@boards_cpu, "$line");
			$boardfound_cpu=1;
			$boardslot_cpu=($line =~ /Board/) ? substr($line,6,2) : substr($line,0,2);
			$boardslot_cpu=~s/[: ]//g;
			if ($flag_cpu == 2 && $boardslot_cpus !~ /\s$boardslot_cpu\s/ && $boardslot_cpu) {
				push(@boardslot_cpus, "$boardslot_cpu");
				$boardslot_cpus .= $boardslot_cpu . " ";
			}
		}
		if ($line =~ /CPU Units:/) {
			$flag_cpu=1;	# Start of CPU section
			$flag_mem=0;	# End of memory section
			$format_cpu=1;
		}
		if ($line =~ /====( | Virtual )CPUs ====/) {
			$flag_cpu=1;	# Start of CPU section
			$flag_mem=0;	# End of memory section
			$format_cpu=2;
		}
		if ($flag_mem == 2 && $line !~ /^\s*\n$/) {
			$memfrom="prtdiag";
			$boardslot_mem=($line =~ /Board/) ? substr($line,5,2) : substr($line,0,2);
			$boardslot_mem=~s/[: ]//g;
			if ($boardslot_mems !~ /\s$boardslot_mem\s/) {
				push(@boardslot_mems, "$boardslot_mem");
				$boardslot_mems .= $boardslot_mem . " ";
			}
			if ($format_mem == 1) {
				# Memory on each system board, E10000
				$mem0=substr($line,12,4);
				$mem0=0 if ($mem0 !~ /\d+/);
				$dimm0=$mem0 / 8;
				if ($dimm0) {
					$dimms0=sprintf("8x%3d", $dimm0);
					push(@simmsizesfound, "$dimm0");
				} else {
					$dimms0="     ";
					&found_empty_bank("Bank 0");
				}
				$mem1=substr($line,20,4);
				$mem1=0 if ($mem1 !~ /\d+/);
				$dimm1=$mem1 / 8;
				if ($dimm1) {
					$dimms1=sprintf("8x%3d", $dimm1);
					push(@simmsizesfound, "$dimm1");
				} else {
					$dimms1="     ";
					&found_empty_bank("Bank 1");
				}
				$mem2=substr($line,28,4);
				$mem2=0 if ($mem2 !~ /\d+/);
				$dimm2=$mem2 / 8;
				if ($dimm2) {
					$dimms2=sprintf("8x%3d", $dimm2);
					push(@simmsizesfound, "$dimm2");
				} else {
					$dimms2="     ";
					&found_empty_bank("Bank 2");
				}
				$mem3=substr($line,36,4);
				$mem3=0 if ($mem3 !~ /\d+/);
				$dimm3=$mem3 / 8;
				if ($dimm3) {
					$dimms3=sprintf("8x%3d", $dimm3);
					push(@simmsizesfound, "$dimm3");
				} else {
					$dimms3="     ";
					&found_empty_bank("Bank 3");
				}
				$newline=substr($line,0,10);
				$newline .= "  " . $mem0 . "  " . $dimms0;
				$newline .= "  " . $mem1 . "  " . $dimms1;
				$newline .= "  " . $mem2 . "  " . $dimms2;
				$newline .= "  " . $mem3 . "  " . $dimms3;
				$newline .= "\n";
				push(@boards_mem, "$newline");
				$boardfound_mem=1;
			}
			if ($format_mem == 2) {
				# Memory on each system board, E10000
				# untested ??? reporting of empty banks
				$untested=1;
				$bank_slot=substr($line,6,2);
				$mem=substr($line,12,4);
				$mem=0 if ($mem !~ /\d+/);
				$dimm=$mem / 8;
				if ($dimm) {
					$dimms=sprintf("8x3d", $dimm);
					push(@simmsizesfound, "$dimm");
					$newline=substr($line,0,18) . $dimms;
					$newline .= substr($line,16,47);
					push(@boards_mem, "$newline");
					$boardfound_mem=1;
					$failed_memory += $mem if ($newline =~ /\b\bFailed\b\b/);
					$spare_memory += $mem if ($newline =~ /\b\bSpare\b\b/);
				} else {
					$flag_mem=0;
					&found_empty_bank("Bank $bank_slot");
				}
				if ($bank_slot == 0) {
					$next_boardslot_mem=substr($prtdiag[$i + 1],0,2);
					$next_boardslot_mem=~s/[: ]//g;
					&found_empty_bank("Bank 1") if ($next_boardslot_mem ne $boardslot_mem);
				}
				if ($bank_slot == 1) {
					$prev_boardslot_mem=substr($prtdiag[$i - 1],0,2);
					$prev_boardslot_mem=~s/[: ]//g;
					&found_empty_bank("Bank 0") if ($prev_boardslot_mem ne $boardslot_mem);
				}
			}
			if ($format_mem == 3) {
				# Memory on each system board, E[3456]x00
				$mem0=substr($line,10,4);
				$mem0=0 if ($mem0 !~ /\d+/);
				$dimm0=$mem0 / 8;
				if ($dimm0) {
					$dimms0=sprintf("8x%3d", $dimm0);
					push(@simmsizesfound, "$dimm0");
				} else {
					$dimms0="     ";
					&found_empty_bank("Bank 0");
				}
				$memlength=length($line);
				$mem1=($memlength > 34) ? substr($line,34,4) : 0;
				$mem1=0 if ($mem1 !~ /\d+/);
				$dimm1=$mem1 / 8;
				if ($dimm1) {
					$dimms1=sprintf("8x%3d", $dimm1);
					push(@simmsizesfound, "$dimm1");
				} else {
					$dimms1="     ";
					&found_empty_bank("Bank 1");
				}
				$newline=substr($line,0,16) . $dimms0;
				$newline .= substr($line,16,24);
				if ($dimm1) {
					$newline .= $dimms1;
					$newline .= substr($line,39,16);
				}
				push(@boards_mem, "$newline");
				$boardfound_mem=1;
			}
			if ($format_mem == 4) {
				# Memory on each system board, E[3456]x00
				$bank_slot=substr($line,7,1);
				$mem=substr($line,12,4);
				$mem=0 if ($mem !~ /\d+/);
				$dimm=$mem / 8;
				if ($dimm) {
					$dimms=sprintf("8x%3d", $dimm);
					push(@simmsizesfound, "$dimm");
					$newline=substr($line,0,18) . $dimms;
					$newline .= substr($line,16,47);
					push(@boards_mem, "$newline");
					$boardfound_mem=1;
					$failed_memory += $mem if ($newline =~ /\b\bFailed\b\b/);
					$spare_memory += $mem if ($newline =~ /\b\bSpare\b\b/);
				} else {
					$flag_mem=0;
					&found_empty_bank("Bank $bank_slot");
				}
				if ($bank_slot == 0) {
					$next_boardslot_mem=substr($prtdiag[$i + 1],0,2);
					$next_boardslot_mem=~s/[: ]//g;
					&found_empty_bank("Bank 1") if ($next_boardslot_mem ne $boardslot_mem);
				}
				if ($bank_slot == 1) {
					$prev_boardslot_mem=substr($prtdiag[$i - 1],0,2);
					$prev_boardslot_mem=~s/[: ]//g;
					&found_empty_bank("Bank 0") if ($prev_boardslot_mem ne $boardslot_mem);
				}
			}
		}
		if ($flag_cpu == 1 && $line =~ /-----/) {
			# Next lines are the CPUs on each system board
			$flag_cpu=2;
		}
		if ($flag_mem == 1 && $line =~ /-----/) {
			# Next lines are the memory on each system board
			$flag_mem=2;
		}
		$i++;
	}
	&show_header;
	if ($boardfound_mem) {
		if ($boardfound_cpu) {
			foreach $board (@boardslot_cpus) {
				if ($boardslot_mems !~ /\s$board\s/) {
					$boardslot_mem=$board;
					if ($format_mem <= 2) {
						# E10000
						&found_empty_bank("Bank 0");
						&found_empty_bank("Bank 1");
						&found_empty_bank("Bank 2");
						&found_empty_bank("Bank 3");
					} else {
						# E3x00/E4x00/E5x00/E6x00
						&found_empty_bank("Bank 0");
						&found_empty_bank("Bank 1");
					}
				}
			}
		}
		if ($format_mem == 1) {
			# E10000 running Solaris 2.5.1
			print "               Bank 0       Bank 1       Bank 2       Bank 3\n";
			print "             MB   DIMMs   MB   DIMMs   MB   DIMMs   MB   DIMMs\n";
			print "            ----  -----  ----  -----  ----  -----  ----  -----\n";
			print @boards_mem;
		}
		if ($format_mem == 2) {
			# E10000 running Solaris 2.6 or later
			print "Brd   Bank   MB   DIMMs   Status   Condition  Speed\n";
			print "---  -----  ----  -----  -------  ----------  -----\n";
			print @boards_mem;
		}
		if ($format_mem == 3) {
			# E3x00/E4x00/E5x00/E6x00 running Solaris 2.5.1
			print "                   Bank 0                       Bank 1\n";
			print "          J3100-J3800   Interleave     J3101-J3801   Interleave\n";
			print "           MB   DIMMs  Factor  With     MB   DIMMs  Factor  With\n";
			print "          ----  -----  ------  ----    ----  -----  ------  ----\n";
			print @boards_mem;
		}
		if ($format_mem == 4) {
			# E3x00/E4x00/E5x00/E6x00 running Solaris 2.6 or later
			print "                                                     Intrlv.  Intrlv.\n";
			print "Brd   Bank   MB   DIMMs   Status   Condition  Speed   Factor   With\n";
			print "---  -----  ----  -----  -------  ----------  -----  -------  -------\n";
			print @boards_mem;
			print "Bank 0 uses sockets J3100-J3800, Bank 1 uses sockets J3101-J3801\n";
		}
		$empty_banks=" None" if (! $empty_banks);
		print "empty memory banks:$empty_banks\n";
	}
	$totmem=$installed_memory;
	&finish;
	&pdebug("exit");
	exit;
}

#
# Check to see if this system has memory defined in the prtdiag output
#
&check_prtdiag;
$model=$diagbanner if ($diagbanner && $isX86);
$untested=0 if ($boardfound_mem && $isX86 && ! $have_x86_devname);
&x86_devname;
# Don't use prtdiag data on this clone
$boardfound_mem=0 if ($manufacturer eq "AXUS");

#
# Check to see if this system has module information in prtconf output
# (Seen on Fujitsu GP7000, GP7000F, PrimePower)
#
if ($gotmodule || $gotmodulenames) {
	@simmslots=($gotmodulenames) ? split(/\./, $gotmodulenames) : split(/\./, $gotmodule);
	$totmem=0;
	for ($val=0; $val < scalar(@simmslots); $val += 2) {
		$socket=($gotmodulenames) ? $simmslots[$val] : "SLOT" . $val / 2;
		$simmsz=$simmslots[$val + 1];
		$simmsize=hex("0x$simmsz") / $meg;
		$perlhexbug=1 if ($simmsize <= 0 && $simmsz ne "00000000");
		$totmem += $simmsize;
		if ($simmsize) {
			push(@simmsizesfound, "$simmsize");
			if (! $boardfound_mem) {
				push(@memorylines, "$socket has a ${simmsize}MB");
				if ($simmsize > 1023) {
					push(@memorylines, " (");
					push(@memorylines, $simmsize/1024);
					push(@memorylines, "GB)");
				}
				push(@memorylines, " $memtype\n");
			}
			$sockets_used .= " $socket";
		}
	}
	&show_header;
	&pdebug("displaying memory from $memfrom") if ($memfrom);
	print (($boardfound_mem) ? @boards_mem : @memorylines);
	$totmem=$installed_memory;
	&finish;
	&pdebug("exit");
	exit;
}

#
# Check to see if this system has module information in ipmitool output
#
if ($have_ipmitool_data) {
	&check_ipmitool;
	$tmp=scalar(keys %ipmi_mem);
	if (defined($tmp)) {
		if ($tmp) {
			&pdebug("Memory found with ipmitool");
			&show_header;
			for (sort alphanumerically keys %ipmi_mem) {
				if ($ipmi_mem{$_}) {
					print "socket $_: $ipmi_mem{$_}\n";
					$simmsize=$ipmi_mem{$_};
					$simmsize=~s/^.*\b(\d+)M[Bb].*/$1/;
					$ipmi_memory += $simmsize if ($simmsize);
				} else {
					&add_to_sockets_empty($_);
				}
			}
			$totmem=$installed_memory;
			&print_empty_memory("memory sockets");
			&finish;
			&pdebug("exit");
			exit;
		}
	}
}

#
# Check to see if this system has cpu information in kstat output to recognize
# Hyper-Threaded Intel CPUs
#
&check_kstat if ($have_kstat_data);

#
# Check to see if this system has module information in smbios output
#
&check_smbios if ($have_smbios_data);

#
# Check to see if this system has module information in prtfru output
#
&check_prtfru;

#
# Display memory if found in prtdiag and/or prtfru output
#
if ($boardfound_mem) {
	&show_header;
	&pdebug("displaying memory from $memfrom") if ($memfrom);
	&pdebug("displaying memory from prtfru") if ($fru_details && $memfrom ne "prtfru");
	# Rewrite prtdiag output to exclude DIMM5-DIMM8 on W1100z
	if ($model =~ /W1100z\b/i && $model !~ /2100z\b/i) {
		@new_boards_mem="";
		foreach $line (@boards_mem) {
			push(@new_boards_mem, "$line") if ($line !~ /DIMM[5-8]/);
		}
		@boards_mem=@new_boards_mem;
	}
	print @boards_mem if (! &is_virtualmachine);
	if ($have_prtfru_details) {
		print "FRU Memory Data:\n-----------------------------------------------------------------------\n$fru_details";
		if ($missing_prtfru_details ne " ") {
			print "NOTICE: Not all memory modules reported detailed FRU data\n";
		}
		print "-----------------------------------------------------------------------\n";
	}
	$totmem=$installed_memory;
}
#
# Look for empty memory banks on Sun Fire 3800, 4800, 4810, 6800, 12K, 15K and
# Netra T12 systems. Also Sun Fire E2900, E4900, E6900, E20K and E25K.
#
if ($ultra eq "Sun Fire" || $ultra eq "Sun Fire 15K" || $ultra eq "Sun Fire 12K" || $ultra eq "Netra T12" || $ultra =~ /Sun Fire ([346]8[01]0|E[246]900|E2[05]K)\b/) {
	foreach $cpu (@boardslot_cpus) {
		$empty_banks .= " $cpu/B0" if ($boardslot_mems !~ /$cpu\/B0/);
		$empty_banks .= " $cpu/B1" if ($boardslot_mems !~ /$cpu\/B1/);
	}
	$empty_banks=" None" if (! $empty_banks);
	if ($boardslot_mems eq " ") {
		$empty_banks=" Unknown";
		$exitstatus=1;
	}
	print "empty memory banks:$empty_banks\n" if ($boardfound_mem);
}
if ($boardfound_mem) {
	&finish;
	&pdebug("exit");
	exit;
}

#
# OK, get ready to print out results
#
for ($val=$val0; $val < scalar(@slots); $val += $valinc) {
	$newaddrmsb=substr($slots[$val - $valaddr - 1],3,5);
	$newaddrlsb=substr($slots[$val - $valaddr],0,3);
	$newsizemsb=($valinc == 4) ? substr($slots[$val - 1],3,5) : "";
	$newsizelsb=substr($slots[$val],0,3);
	# Round up for DIMM value seen on US-T1 and US-T2 Niagara systems
	# Two Ranks of DIMMs appear as one in prtconf
	if ($newsizelsb eq "ff8") {
		if ($newsizemsb eq "00000") {
			$newsizemsb="00001";	# 512MB
			if ($ultra eq "T2000") {
				# Hack: 1 rank of smallest DIMMs
				$simmbanks=2;
				$simmsperbank=8;
			}
			# Hack: Could be 1 Rank of 1GB on T1000
			$recognized=-1 if ($ultra eq "T1000" && scalar(@slots) == 4);
		} elsif ($newsizemsb eq "00001") {
			$newsizemsb="00002";	# 1GB
			# Hack: Could be 1 Rank of 1GB on T2000
			$recognized=-1 if ($ultra eq "T2000" && scalar(@slots) == 4);
			# Hack: Could be 1 Rank of 2GB on T1000
			$recognized=-1 if ($ultra eq "T1000" && scalar(@slots) == 4);
		} elsif ($newsizemsb eq "00003") {
			$newsizemsb="00004";	# 2GB
			# Hack: Could be 1 Rank of 2GB on T2000
			$recognized=-1 if ($ultra eq "T2000" && scalar(@slots) == 4);
		} elsif ($newsizemsb eq "00007") {
			$newsizemsb="00008";	# Fully stuffed 2 Ranks of 2GB
		}
		$newsizelsb="000";
		$installed_memory += 8;
	} elsif ($newsizelsb eq "7f8" && $newsizemsb eq "00000") {
		if ($ultra eq "T1000") {
			# Hack: 1 rank of smallest DIMMs
			$newsizelsb="800";	# 512MB
			$simmbanks=2;
			$simmsperbank=4;
		} else {
			$newsizelsb="800";	# Hack: unsupported 256MB DIMM
		}
		$installed_memory += 8;
	} elsif ($newsizelsb eq "f80") {
		if ($newsizemsb eq "00001") {
			$newsizemsb="00002";	# 1GB
		} elsif ($newsizemsb eq "00003") {
			$newsizemsb="00004";	# 2GB
		} elsif ($newsizemsb eq "00007") {
			$newsizemsb="00008";	# 4GB
		} elsif ($newsizemsb eq "0000f") {
			$newsizemsb="00010";	# 8GB
		}
		$newsizelsb="000";
		$installed_memory += 128;
	}
	if ($sortslots) {
		$mods{"$newaddrmsb$newaddrlsb"}="$newsizemsb$newsizelsb";
	} else {
		push(@newslots, "$newaddrmsb$newaddrlsb");
		push(@newslots, "$newsizemsb$newsizelsb");
	}
}
if ($sortslots) {
	for (sort alphanumerically keys %mods) {
		push(@newslots, $_);
		push(@newslots, $mods{$_});
	}
}

# For Ultra-30, determine if interleaving of banks using four DIMMs
if ($model eq "Ultra-30" || $ultra eq 30) {
	$interleave=2;
	# pairs show up in odd numbered address ranges
	for ($val=0; $val < scalar(@newslots); $val += 2) {
		$interleave=1 if ($newslots[$val] =~ /00000[1357]00/);
	}
	if ($interleave eq 2) {
		$simmrangex="00000200";
		$simmbanks=4;
		$simmsperbank=4;
	} else {
		$simmrangex="00000100";
		$simmbanks=8;
		$simmsperbank=2;
	}
}

# Check if SPARCsystem-600 has VME memory expansion boards
if ($model eq "SPARCsystem-600" || $model =~ /Sun.4.600/) {
	for ($val=0; $val < scalar(@newslots); $val += 2) {
		if ($newslots[$val] =~ /00000[4-9ab]00/) {
			@simmsizes=(1,4,16);
			push(@socketstr, @socketstr_exp);
			push(@bankstr, @bankstr_exp);
			push(@bytestr, @bytestr_exp);
			$exp=($newslots[$val] =~ /00000[4-7]00/) ? "Expansion board 0 bank" : "Expansion board 1 bank";
			push(@banksstr, ("$exp B0","$exp B1", "$exp B2","$exp B3"));
		}
	}
}

# Hack: Rewrite interleaved memory line for Ultra-80 or Enterprise 420R
if (($model eq "Ultra-80" || $ultra eq 80 || $ultra eq "420R" || $ultra eq "Netra t140x") && $newslots[0] eq "00000000") {
	if ($newslots[1] eq "00001000" && $installed_memory eq 4096) {
		# 4GB of memory (maximum) using 16x256MB in Banks 0-3
		$newslots[1]="00000400";
		$newslots[2]="00000400";
		$newslots[3]="00000400";
		$newslots[4]="00000800";
		$newslots[5]="00000400";
		$newslots[6]="00000c00";
		$newslots[7]="00000400";
		$interleave=4;
	} elsif ($newslots[1] eq "00000800" && $installed_memory eq 2048) {
		# 2GB of memory using 8x256MB in Banks 0,1
		$newslots[1]="00000400";
		$newslots[2]="00000400";
		$newslots[3]="00000400";
		$interleave=2;
	} elsif ($newslots[1] =~ /00000[97653]00/) {
		# Early OBP releases showed total memory as a single bank
		$recognized=-1;
	} elsif ($newslots[1] eq "00000400" && $installed_memory eq 1024) {
		# 1GB of memory can be 4x256MB in Bank 0 or 16x64MB in Banks 0-3
		# so flag OBP bug
		$recognized=-1;
	} elsif ($newslots[1] eq "00000200" && $installed_memory eq 512) {
		# 512MB of memory using 8x64MB in Banks 0,1
		$newslots[1]="00000100";
		$newslots[2]="00000400";
		$newslots[3]="00000100";
		$interleave=2;
	}
}

# Hack: Fix address ranges for Tatung COMPstation U60 and U80D
if ($banner =~ /COMPstation_U(60|80D)_Series/) {
	# Tatung Science and Technology, http://www.tsti.com
	for ($val=0; $val < scalar(@newslots); $val += 2) {
		$simmbanks=4 if ($newslots[$val] =~ /00000[46]00/);
		# Check for 256MB DIMMs or 256MB address range per bank
		if ($newslots[$val + 1] =~ /00000400/ || $newslots[$val] =~ /00000c00/) {
			$simmrangex="00000400";
			$simmbanks=4;
		}
	}
	if ($simmbanks eq 6) {
		# Skipped address range similar to Sun Ultra 60
		@socketstr=("J17","J32","J36","J40","J18","J33","J37","J41","?","?","?","?","?","?","?","?","J19","J34","J38","J42","J20","J35","J39","J43");
		@slotstr=(1..8,"?","?","?","?","?","?","?","?",9..16);
		@bankstr=(0,0,0,0,1,1,1,1,"?","?","?","?","?","?","?","?",2,2,2,2,3,3,3,3);
	} else {
		@socketstr=("J17","J32","J36","J40","J18","J33","J37","J41","J19","J34","J38","J42","J20","J35","J39","J43");
		@slotstr=(1..16);
		@bankstr=(0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3);
	}
}

# Hack: Try to rewrite memory line for Sun Blade 1000 & 2000 if prtdiag output
#       did not show the memory. This does not expect 2GB DIMMs to be used.
if (($ultra eq "Sun Blade 1000" || $ultra eq "Sun Blade 2000" || $ultra eq "Sun Fire 280R") && ! $boardfound_mem) {
	# Assume 8GB is 8x1GB instead of 4x2GB
	if ($newslots[1] eq "00002000") {
		$newslots[1]="00001000";
		$newslots[2]="00001000";
		$newslots[3]="00001000";
		$recognized=-2;
	}
	# Assume 6GB is 4x1GB + 4x512MB instead of 4x1.5GB
	if ($newslots[1] eq "00001800") {
		$newslots[1]="00001000";
		$newslots[2]="00001000";
		$newslots[3]="00000800";
		$recognized=-1;
	}
	# Assume 5GB is 4x1GB + 4x256MB instead of 4x1280MB
	if ($newslots[1] eq "00001400") {
		$newslots[1]="00001000";
		$newslots[2]="00001000";
		$newslots[3]="00000400";
		$recognized=-1;
	}
	# Assume 4.5GB is 4x1GB + 4x128MB instead of 4x1152MB
	if ($newslots[1] eq "00001200") {
		$newslots[1]="00001000";
		$newslots[2]="00001000";
		$newslots[3]="00000200";
		$recognized=-1;
	}
	# Assume 3GB is 4x512MB + 4x256MB instead of 4x768MB
	if ($newslots[1] eq "00000c00") {
		$newslots[1]="00000800";
		$newslots[2]="00001000";
		$newslots[3]="00000400";
		$recognized=-1;
	}
	# Assume 2.5GB is 4x512MB + 4x128MB instead of 4x640MB
	if ($newslots[1] eq "00000a00") {
		$newslots[1]="00000800";
		$newslots[2]="00001000";
		$newslots[3]="00000200";
		$recognized=-1;
	}
	# Assume 1.5GB is 4x256MB + 4x128MB instead of 4x384MB
	if ($newslots[1] eq "00000600") {
		$newslots[1]="00000400";
		$newslots[2]="00001000";
		$newslots[3]="00000200";
		$recognized=-1;
	}
}

# for prtconf output only, or fully stuffed LDOM servers
if ($ultra eq "T5120" || $ultra eq "T5220" || $ultra eq "T6320" || $ultra eq "T5140") {
	# Hack: Rewrite fully stuffed memory line
	if ($installed_memory >= 130816) {
		$newslots[0]="00000000";
		$newslots[1]="00008000";
		$newslots[2]="00008000";
		$newslots[3]="00008000";
		$newslots[4]="00010000";
		$newslots[5]="00008000";
		$newslots[6]="00018000";
		$newslots[7]="00008000";
	}
}
if ($ultra eq "T5240" || $ultra eq "T6340") {
	# Hack: Rewrite fully stuffed memory line
	if ($installed_memory >= 261632) {
		$newslots[0]="00000000";
		$newslots[1]="00008000";
		$newslots[2]="00008000";
		$newslots[3]="00008000";
		$newslots[4]="00010000";
		$newslots[5]="00008000";
		$newslots[6]="00018000";
		$newslots[7]="00008000";
		$newslots[8]="00020000";
		$newslots[9]="00008000";
		$newslots[10]="00028000";
		$newslots[11]="00008000";
		$newslots[12]="00030000";
		$newslots[13]="00008000";
		$newslots[14]="00038000";
		$newslots[15]="00008000";
	}
}

# Check for dual bank DIMMs on Ultra AXmp+
if ($ultra eq "AXmp+") {
	if ($#newslots eq 1 && $newslots[0] eq "00000c00") {
		$simmsperbank=4;
		$dualbank=1;
	}
	if ($#newslots eq 3) {
		if ($newslots[2] =~ /00000[8c]00/) {
			$simmrangex="00000800";
			$dualbank=1 if ($newslots[1] eq $newslots[3]);
		}
	}
	if ($#newslots ge 5) {
		$dualbank=1 if ($newslots[4] =~ /00000[8c]00/);
	}
	if ($dualbank eq 1) {
		@bankstr=("0,2","0,2","0,2","0,2","0,2","0,2","0,2","0,2","1,3","1,3","1,3","1,3","1,3","1,3","1,3","1,3");
		# Rearrange slots if necessary
		if ($#newslots ge 5) {
			if ($newslots[4] eq "00000800") {
				$tmp=$newslots[2];
				$newslots[2]=$newslots[4];
				$newslots[4]=$tmp;
				$tmp=$newslots[3];
				$newslots[3]=$newslots[5];
				$newslots[5]=$tmp;
			}
		}
	}
}

$totmem=0;
for ($val=0; $val < scalar(@newslots); $val += 2) {
	&pdebug("displaying memory from $memfrom") if ($memfrom);
	$simmaddr=$newslots[$val];
	$simmsz=$newslots[$val + 1];
	$simmsize=hex("0x$simmsz");
	$simmsize=&roundup_memory($simmsize) if ($simmsize > 16384);
	$perlhexbug=1 if ($simmsize <= 0 && $simmsz ne "00000000");
	$totmem += $simmsize;

	if (($model eq "Sun 4/75" || $model eq "SS-2") && ($simmbanks < $bankcnt + 2)) {
		# SS2 SBus memory card
		$buffer=($simmaddr eq "00000080") ? "${buffer}SBus primary" : "${buffer}SBus secondary";
		$start1=hex("0x$simmaddr") * $meg;
		$perlhexbug=1 if ($start1 < 0);
		$simmrange=hex("0x$simmrangex") * $meg;
		$perlhexbug=1 if ($simmrange <= 0 && $simmrangex ne "00000000");
		$start1x=sprintf("%08lx", $start1);
		$stop1x=sprintf("%08lx", $start1 + (2 * $simmrange) - 1);
		$totmem += $simmsize;
		$simmsize *= 2;
		$val += 2;
		$buffer .= " contains ${simmsize}MB";
		$buffer .= " (address 0x${start1x}-0x$stop1x)" if ($verbose);
		$buffer .= "\n";
	} elsif ($simmbanks) {
		$start1=hex("0x$simmaddr") * $meg;
		$perlhexbug=1 if ($start1 < 0);
		if ($simmrangex ne "0") {
			$simmrange=hex("0x$simmrangex") * $meg;
			$perlhexbug=1 if ($simmrange <= 0 && $simmrangex ne "00000000");
			if ($simmrange < hex("0x00001000") * $meg) {
				$start1x=sprintf("%08lx", $start1);
				$stop1x=sprintf("%08lx", $start1 + ($simmsize * $meg) - 1);
			} else {
				# Systems with > 4GB of memory
				$start1x=$simmaddr . "00000";
				$start1x=~s/^0000//;
				$stop1x=sprintf("%08lx", ($start1 / $meg) + $simmsize - 1) . "fffff";
				$stop1x=~s/^0000//;
			}
		}
		$cnt=0;
		while ($cnt < $simmbanks * $simmsperbank) {
			if ($start1 >= $simmrange * $cnt && $start1 < $simmrange * ($cnt + 1)) {
				$bankcnt=$cnt;
				$cnt3=$bankcnt * $simmsperbank;
				if ($#socketstr) {
					$socket=$socketstr[$cnt3];
					if ($#socketlabelstr) {
						$socketlabel=" ($socketlabelstr[$cnt3])" if (defined($socketlabelstr[$cnt3]));
					}
					if ($found10bit && $newslots[$val] !~ /00000[0-3]00/) {
						$socket=$socketstr[$cnt3 + 4];
						if ($#socketlabelstr) {
							$socketlabel=" ($socketlabelstr[$cnt3 + 4])" if (defined($socketlabelstr[$cnt3 + 4]));
						}
					}
				}
				$order=$orderstr[$cnt3] if ($#orderstr);
				$group=$groupstr[$cnt3] if ($#groupstr);
				$slotnum=$slotstr[$cnt3] if ($#slotstr);
				if ($#bankstr) {
					$bank=$bankstr[$cnt3];
					$bank=$bankstr[$cnt3 + 4] if ($found10bit && $newslots[$val] !~ /00000[0-3]00/);
				}
				$banks=$banksstr[$cnt3/$simmsperbank] if ($#banksstr);
				$byte=$bytestr[$cnt3] if ($#bytestr);
			}
			$cnt++;
		}
		#
		# Check for stacked DIMMs. A 128MB DIMM is sometimes seen as 2
		# 64MB DIMMs with a hole in the address range. This may report
		# more slots than are really in a system. (i.e. a SS20 with
		# 8 32MB SIMMs reports 16 slots of 16MB each).
		# Special handling for $sortslots == 0 systems (Ultra 5/10,
		# Netra t1, Ultra CP 1400/1500, Ultra AXi/AXe/AXmp/AXmp+)
		#
		$stacked=0;
		if ($val < $#newslots - 2) {
			if ($sortslots == 0) {
				$start2=$start1 + ($simmrange * 2);
				$start2=$start1 + ($simmrange * 4) if ($banner =~ /Ultra CP 1400\b/ || $ultra eq "CP1400");
				$start2x=sprintf("%08lx", $start2 / $meg);
				$stacked=2 if ($stacked == 0 && $newslots[$val + 2] eq $start2x && $newslots[$val + 3] eq $simmsz);
				if ($memtype eq "memory card") {
					# Some 256MB mezzanine boards are seen
					# as 4 64MB memory blocks with holes in
					# the address range.
					$start3=$start1 + ($simmsize * 2 * $meg) if ($simmsize eq 64);
					# Some 512MB mezzanine boards are seen
					# as 4 128MB memory blocks.
					$start3=$start1 + ($simmsize * $meg) if ($simmsize eq 128 && $banner !~ /Ultra CP 1400\b/ && $ultra ne "CP1400");
					if ($banner =~ /\bCP2000\b/ || $ultra =~ /^CP2[01]\d0$/) {
						# 1GB mezzanine boards are seen
						# as 4 256MB memory blocks.
						$start3=$start1 + ($simmsize * $meg);
						$stacked=4;
					}
					$start3x=sprintf("%08lx", $start3 / $meg);
					if ($val < $#newslots - 6 && $stacked != 0) {
						$stacked=4 if ($newslots[$val + 4] eq $start3x && $newslots[$val + 5] eq $simmsz && $simmrange != $start3);
					}
				}
				if ($ultra eq "AXi") {
					# Check for 10-bit column address DIMMs
					if ($newslots[$val] =~ /00000[0-3]80/) {
						$found10bit=1;
					} elsif ($stacked == 0) {
						$found11bit=1;
					}
					if ($found10bit && $newslots[$val] !~ /00000[0-3]00/) {
						$socket=$socketstr[$cnt3 + 4];
						if ($#socketlabelstr) {
							$socketlabel=" ($socketlabelstr[$cnt3 + 4])" if (defined($socketlabelstr[$cnt3 + 4]));
						}
						$bank=$bankstr[$cnt3 + 4];
					}
				}
			} else {
				$start2=$start1 + ($simmrange / 2);
				$start2x=sprintf("%08lx", $start2 / $meg);
				$stacked=2 if ($newslots[$val + 2] eq $start2x && $newslots[$val + 3] eq $simmsz && ($simmsize ne 64));
			}
			#
			# Check for 32MB SIMMs in bank 1 on Classic or LX.
			# They look like 16MB SIMMs at 0x0000000 and 0x06000000
			# Also check for 8MB SIMMs in bank 1 on Classic or LX.
			# They look like 4MB SIMMs at 0x0000000 and 0x06000000
			#
			if ($model =~ /SPARCclassic|SPARCstation-LX/) {
				if ($start1 == 0 && ($simmsize == 32 || $simmsize == 8)) {
					if ($newslots[$#newslots - 1] eq "00000060") {
						$totmem += $simmsize;
						$start2=hex("0x$newslots[$#newslots - 1]") * $meg;
						$start2x=sprintf("%08lx", $start2);
						$stop2x=sprintf("%08lx", $start2 + ($simmsize * $meg) - 1);
						$stop1x .= ", 0x${start2x}-0x$stop2x";
						$simmsize *= 2;
						pop(@newslots);
						pop(@newslots);
					}
				}
			}
			if ($stacked == 2) {
				$totmem += $simmsize;
				$start2=hex("0x$newslots[$val + 2]") * $meg;
				if ($simmrange < hex("0x00001000") * $meg) {
					$start2x=sprintf("%08lx", $start2);
					$stop2x=sprintf("%08lx", $start2 + ($simmsize * $meg) - 1);
				} else {
					# Systems with > 4GB of memory
					$start2x=sprintf("%08lx", ($start2 / $meg)) . "00000";
					$start2x=~s/^0000//;
					$stop2x=sprintf("%08lx", ($start2 / $meg) + $simmsize - 1) . "fffff";
					$stop2x=~s/^0000//;
				}
				$stop1x .= ", 0x${start2x}-0x$stop2x";
				$simmsize *= 2;
				$val += 2;
			}
			if ($stacked == 4) {
				$totmem += $simmsize * 3;
				$start2=hex("0x$newslots[$val + 2]") * $meg;
				$start2x=sprintf("%08lx", $start2);
				$stop2x=sprintf("%08lx", $start2 + ($simmsize * $meg) - 1);
				$stop1x .= ", 0x${start2x}-0x$stop2x";
				$start3=hex("0x$newslots[$val + 4]") * $meg;
				$start3x=sprintf("%08lx", $start3);
				$stop3x=sprintf("%08lx", $start3 + ($simmsize * $meg) - 1);
				$stop1x .= ", 0x${start3x}-0x$stop3x";
				$start4=hex("0x$newslots[$val + 6]") * $meg;
				$start4x=sprintf("%08lx", $start4);
				$stop4x=sprintf("%08lx", $start4 + ($simmsize * $meg) - 1);
				$stop1x .= ", 0x${start4x}-0x$stop4x";
				$simmsize *= 4;
				$val += 6;
			}
		}
		#
		# Check for Voyager memory cards. A 32MB memory card is seen
		# as 4 8MB memory blocks with holes in the address range.
		#
		if ($model eq "S240" && $start1 && $simmsize == 16 && $val < $#newslots - 4) {
			$start=hex("0x$newslots[$val + 4]") - hex("0x$newslots[$val]");
			$perlhexbug=1 if ($start < 0);
			$startx=sprintf("%08lx", $start);
			if ($newslots[$val + 1] eq "008" && $newslots[$val + 3] eq "008" && $startx eq "00000040") {
				$totmem += $simmsize;
				$startx=$newslots[$val + 2];
				$start=hex("0x$startx") * $meg;
				$startx=sprintf("%08lx", $start);
				$perlhexbug=1 if ($start < 0);
				$stopx=sprintf("%08lx", $start + ($simmsize * $meg) - 1);
				$stop1x .= ", 0x${startx}-0x$stopx";
				$startx=$newslots[$val + 4];
				$start=hex("0x$startx") * $meg;
				$startx=sprintf("%08lx", $start);
				$perlhexbug=1 if ($start < 0);
				$stopx=sprintf("%08lx", $start + ($simmsize * $meg) - 1);
				$stop1x .= ", 0x${startx}-0x$stopx";
				$simmsize *= 2;
				$val += 4;
			}
		}
		$slot0=$simmsize if ($start1 == 0);
		$simmsizeperbank=$simmsize / $simmsperbank;
		$smallestsimm=$simmsizeperbank if ($simmsize < $smallestsimm);
		$largestsimm=$simmsizeperbank if ($simmsize > $largestsimm);
		$found8mb=1 if ($simmsizeperbank == 8);
		$found16mb=1 if ($simmsizeperbank == 16);
		$found32mb=1 if ($simmsizeperbank == 32);
		push(@simmsizesfound, "$simmsizeperbank");

		$cnt2=0;
		while ($cnt2 < $simmsperbank) {
			$socket='?' if (! defined($socket));
			$bank='' if (! defined($bank));
			$byte='' if (! defined($byte));
			$socket='?' if ($socket eq "");
			$recognized=0 if ($socket eq "?");
			$sockets_used .= " $socket";
			if ($socket eq "motherboard") {
				$buffer .= "$socket has ";
				$buffer .= $simmsize/$simmsperbank . "MB";
			} else {
				if ($model eq "SPARCsystem-600" || $model =~ /Sun.4.600/) {
					$exp="Expansion board 0" if ($newslots[$val] =~ /00000[4-7]00/);
					$exp="Expansion board 1" if ($newslots[$val] =~ /00000[89ab]00/);
					if ($newslots[$val] =~ /00000[4-9ab]00/) {
						$buffer .= "$exp ";
						$banks="$exp bank $bank";
					}
					$banks_used .= " $banks" if ($banks && $banks_used !~ /$banks/);
				}
				# prtconf-only data displayed here
				$buffer=($sockettype) ? "$buffer$sockettype $socket$socketlabel has a " : "$buffer$socket$socketlabel is a ";
				$buffer .= $simmsize/$simmsperbank . "MB";
				$buffer .= " (" . $simmsize/$simmsperbank/1024 . "GB)" if ($simmsize/$simmsperbank > 1023);
				$buffer .= " $memtype";
				push(@simmsizesfound, $simmsize/$simmsperbank);
			}
			if ($verbose) {
				$buf="";
				if ($order) {
					$buf .= "$order";
					$buf .= " $memtype" if ($memtype !~ /memory card/);
				}
				$slotnum="" if (! defined($slotnum));
				$buf .= "slot $slotnum" if ($slotnum ne "");
				$buf .= ", " if ($order || $slotnum ne "");
				$buf .= "group $group, " if ($group ne "");
				if ($bank ne "") {
					if ($bank =~ /Quad/) {
						$buf .= "$bank, ";
					} elsif ($dualbank eq 1) {
						$buf .= "banks $bank, ";
					} else {
						$buf .= "bank $bank, ";
					}
					$foundbank1or3=1 if ($bank eq 1 || $bank eq 3);
				}
				$buf .= "byte $byte, " if ($byte ne "");
				$buf .= "address 0x${start1x}-0x$stop1x" if ($start1x && $showrange eq 1);
				$buffer .= " ($buf)" if ($buf);
			}
			$buffer .= "\n";
			$cnt2++;
			$cnt3=($bankcnt * $simmsperbank) + $cnt2;
			if ($#socketstr) {
				$socket=$socketstr[$cnt3];
				if ($#socketlabelstr) {
					$socketlabel=" ($socketlabelstr[$cnt3])" if (defined($socketlabelstr[$cnt3]));
				}
				if ($found10bit && $newslots[$val] !~ /00000[0-3]00/) {
					$socket=$socketstr[$cnt3 + 4];
					if ($#socketlabelstr) {
						$socketlabel=" ($socketlabelstr[$cnt3 + 4])" if (defined($socketlabelstr[$cnt3 + 4]));
					}
				}
#				&pdebug("socketstr[$cnt3], bankcnt=$bankcnt, cnt2=$cnt2");
			}
			$order=$orderstr[$cnt3] if ($#orderstr);
			$group=$groupstr[$cnt3] if ($#groupstr);
			$slotnum=$slotstr[$cnt3] if ($#slotstr);
			if ($#bankstr) {
				$bank=$bankstr[$cnt3];
				$bank=$bankstr[$cnt3 + 4] if ($found10bit && $newslots[$val] !~ /00000[0-3]00/);
			}
			$banks=$banksstr[$cnt3/$simmsperbank] if ($#banksstr);
			$byte=$bytestr[$cnt3] if ($#bytestr);
		}
	} elsif ($ultra eq 1 || $ultra eq 5 || $ultra eq 10 || $ultra eq 30) {
		$buffer .= "bank $slot has a pair of " . $simmsize/2 . "MB DIMMs\n";
		push(@simmsizesfound, $simmsize/2);
	} elsif ($ultra eq 2 || $ultra eq 250 || $ultra eq 450 || $ultra eq 80 || $ultra eq "420R" || $ultra eq "Netra t140x" || $ultra eq "Netra ft1800") {
		$buffer .= "group $slot has four " . $simmsize/4 . "MB DIMMs\n";
		push(@simmsizesfound, $simmsize/4);
	} elsif ($ultra eq 60 || $ultra eq "220R") {
		$buffer .= "group $slot has four " . $simmsize/2 . "MB DIMMs\n";
		push(@simmsizesfound, $simmsize/2);
	} elsif ($ultra eq "e") {
		$buffer .= "group $slot has eight " . $simmsize/8 . "MB DIMMs\n";
		push(@simmsizesfound, $simmsize/8);
	} elsif ($socket eq "motherboard") {
		$buffer .= "$slot has ${simmsize}MB\n";
		push(@simmsizesfound, $simmsize);
	} else {
		$buffer .= "slot $slot has a ${simmsize}MB";
		$buffer .= " (" . $simmsize/1024 . "GB)" if ($simmsize > 1023);
		$buffer .= " $memtype\n";
		push(@simmsizesfound, $simmsize);
	}
	$slot++;
}

#
# Try to distinguish Ultra 5 from Ultra 10
# Cannot distinguish Ultra 5/333MHz from Ultra 10/333MHz (375-0066 motherboard)
# Cannot distinguish Ultra 5/440MHz from Ultra 10/440MHz (375-0079 motherboard)
#
if ($model eq "Ultra-5_10" || $ultra eq "5_10" || $ultra eq 5 || $ultra eq 10) {
	if ($motherboard =~ /375-0009/) {
		$ultra=($sysfreq > 91) ? 10 : 5;
		$realmodel=($ultra eq 5) ? "(Ultra 5)" : "(Ultra 10)";
	}
	# Determine if interleaving of banks using four identical sized DIMMs
	# Assume 1-way interleaving with mix of stacked and unstacked DIMMs
	$interleave=1;
	if ($#newslots == 3 && $stacked == 0) {
		$interleave=2 if ($newslots[1] eq $newslots[3]);
	}
	if ($#newslots == 7 && $stacked == 2) {
		$interleave=2 if ($newslots[1] eq $newslots[5]);
	}
}
&finish;
&pdebug("exit");
exit;

sub hpux_check {
	&pdebug("in hpux_check");
	$HPUX=1;
	$model=$machine;
	if ($filename) {
		$model="";
		$machine="";
		$platform="";
		$os="HP-UX";
	} else {
		$osmajor=$osrel;
		$osmajor=~s/[^.]*.[0B]*//;
		$osmajor=~s/\..*//;
		&hpux_osrelease;
		$model=&mychomp(`/usr/bin/model`) if (-x '/usr/bin/model');
		$cpuversion="";
		if (-x '/usr/bin/getconf') {
			$kernbit=&mychomp(`/usr/bin/getconf KERNEL_BITS`);
			$cpuversion=&mychomp(`/usr/bin/getconf CPU_VERSION`);
		}
		$kernbit=32 if ($osmajor <= 10);
		if (-x '/usr/contrib/bin/machinfo') {
			@machinfo=&run("/usr/contrib/bin/machinfo");
			&hpux_machinfo;
		} elsif (-x '/usr/sbin/ioscan') {
			$ncpu=&mychomp(`/usr/sbin/ioscan -kfnC processor | grep '^processor' | wc -l`);
			$cpucntfrom="ioscan";
		} else {
			# Get CPU count from kernel
			if ($machine eq "ia64") {
				$ncpu=&hpux_kernelval("active_processor_count");
			} else {
				$ncpu=&hpux_kernelval("processor_count");
			}
			$cpucntfrom="kernel";
		}
		$ncpu=1 if (! defined($ncpu));	# It has at least 1 CPU
		$cpubanner .= "$ncpu X " if ($ncpu > 1);
		if ($machine =~ /^9000\//) {
			$schedmodel=$model;
			$schedmodel=~s/^.*\/(.*$)/$1/;
			if (! $cputype && -r '/usr/sam/lib/mo/sched.models') {
				$cputype=&myawk('/usr/sam/lib/mo/sched.models',"^$schedmodel\\b",2);
			}
			if (! $cputype && -r '/opt/langtools/lib/sched.models') {
				$cputype=&myawk('/opt/langtools/lib/sched.models',"^$schedmodel\\b",2);
			}
			if (! $cputype && -r '/usr/lib/sched.models') {
				$cputype=&myawk('/usr/lib/sched.models',"^$schedmodel\\b",2);
			}
			if ($cputype) {
				$cpubanner .= "$cputype ";
				&pdebug(" cputype=$cputype");
			}
			if ($cpuversion == 768) {
				$cpubanner .= "Itanium[TM] 1";
			} elsif ($cpuversion == 524) {
				$cpubanner .= "Motorola MC68020";
			} elsif ($cpuversion == 525) {
				$cpubanner .= "Motorola MC68030";
			} elsif ($cpuversion == 526) {
				$cpubanner .= "Motorola MC68040";
			} else {
				$cpubanner .= "PA-RISC";
				if ($cpuversion == 532) {
					$cpubanner .= " 2.0";
				} elsif ($cpuversion == 529) {
					$cpubanner .= " 1.2";
				} elsif ($cpuversion == 528) {
					$cpubanner .= " 1.1";
				} elsif ($cpuversion == 523) {
					$cpubanner .= " 1.0";
				} elsif (&hpux_kernelval("cpu_arch_is_2_0")) {
					$cpubanner .= " 2.0";
				} elsif (&hpux_kernelval("cpu_arch_is_1_1")) {
					$cpubanner .= " 1.1";
				} elsif (&hpux_kernelval("cpu_arch_is_1_0")) {
					$cpubanner .= " 1.0";
				}
			}
		} elsif ($cputype) {
			$cpubanner .= "$cputype";
		} else {
			$cpubanner .= "$machine";
		}
		if (! defined($cfreq)) {
			# Get CPU speed from kernel
			$cfreq=&hpux_kernelval("itick_per_usec");
			if (! defined($cfreq)) {
				$cfreq=&hpux_kernelval("itick_per_tick");
				$cfreq /= 10000 if (defined($cfreq));
			}
			&pdebug(" cfreq=$cfreq found in kernel") if (defined($cfreq));
		}
		$cpubanner .= ", ${cfreq}MHz" if (defined($cfreq));
	}
	$model="HP $model" if ($model !~ /\bHP\b/i);
	$model=~s/ +$//;
	$is_hpvm=0;
	&hpux_machinfo if ($filename);
}

sub hpux_kernelval {
	return if (! -r '/dev/kmem');
	$_=shift;
	$kernel="/hp_ux";
	$kernel="/stand/vmunix" if (-f '/stand/vmunix');
	$adb="/usr/bin/adb";
	$adb .= " -o" if ($machine eq "ia64");
	$kernelval=`echo "$_/D" | $adb $kernel /dev/kmem 2>/dev/null | tail -1`;
	@linearr=split(' ', $kernelval);
	return $linearr[1];
}

sub hpux_machinfo {
	&pdebug("in hpux_machinfo");
	$flag_cpu=0;
	$flag_platform=0;
	$flag_os=0;
	# parse machinfo output for CPU and other information
	foreach $line (@machinfo) {
		$line=&dos2unix($line);
		$line=&mychomp($line);
		if (! $line || $line =~ /^ +$/) {
			# End of sections
			$flag_cpu=0;
			$flag_platform=0;
			$flag_os=0;
			next;
		}
		if ($line =~ /^CPU info:/) {
			$flag_cpu=1;	# Start of CPU section
			next;
		}
		if ($flag_cpu == 1) {
			# Parse CPU count, type and frequency for cpubanner
			if ($line =~ /^\s*\d*\s+.*[Pp]rocessor.* \(\d.*Hz,/) {
				$ncpu=$line;
				$ncpu=~s/^\s*(\d+)\s+.*/$1/;
				$ncpu=1 if ($ncpu eq $line);
				$cpucntfrom="machinfo 'CPU info'";
				$cputype=$line;
				$cputype=~s/^\s*\d*\s+(.*)$/$1/;
				$cputype=~s/ processors.*$//;
				$cputype=~s/^(.*)\s+\(\d.*Hz.*/$1/;
				$cputype=~s/\s+/ /g;
				$cfreq=$line;
				$cfreq=~s/^.*[Pp]rocessor.* \((\d.* [GM]Hz),/$1/;
				if ($cfreq =~ /GHz/) {
					$cfreq=~s/ GHz.*$//;
					$cfreq *= 1000;
				} else {
					$cfreq=~s/ MHz.*$//;
				}
				&pdebug(" cputype=$cputype, cfreq=$cfreq");
				next;
			} elsif ($line =~ /logical processors \(\d+ per socket/) {
				# Report multicore processors
				$tmp=$line;
				$tmp=~/(\d+) logical processors \((\d+) per socket/;
				$cputype=&multicore_cputype($cputype,$2) if (defined($2));
				next;
			} elsif ($line =~ /Number of CPUs = /) {
				@linearr=split('=', $line);
				$ncpu=$linearr[1];
				$ncpu=~s/^ *//;
				$cpucntfrom="machinfo 'Number of CPUs'";
				next;
			} elsif ($line =~ /^\s*\d+ sockets\s*$/) {
				$tmp=$line;
				$tmp=~/(\d+) sockets/;
				$ncpu=$1;
				$cpucntfrom="machinfo 'sockets'";
				next;
			} elsif ($line =~ /processor model: /) {
				@linearr=split(':', $line);
				$cputype=$linearr[1];
				$cputype=~s/^ *\d+ +//;
				$cputype=~s/ processor$//;
				&pdebug(" cputype=$cputype");
				next;
			} elsif ($line =~ /Clock speed = \d+ [GM]Hz/) {
				@linearr=split('=', $line);
				$cfreq=$linearr[1];
				$cfreq=~s/^ *//;
				if ($cfreq =~ /GHz/) {
					$cfreq=~s/ GHz//;
					$cfreq *= 1000;
				} else {
					$cfreq=~s/ MHz//;
				}
				next;
			} elsif ($line =~ /LCPU attribute is /) {
				$hyperthreadcapable=1;
				if ($line =~ /enabled/i) {
					$hyperthread=1;
					$cputype=~s/ Intel/ Hyper-Threaded Intel/ if ($cputype !~ /Hyper.Thread/i);
				}
				next;
			}
		}
		if ($line =~ /^Memory:\s/) {
			$installed_memory=$line;
			$installed_memory=~s/^Memory:\s*(\d*\s*[GM]*[Bb]*).*/$1/;
			if ($installed_memory =~ /GB/) {
				$installed_memory=~s/\s*GB//g;
				$installed_memory *= 1024;
			} else {
				$installed_memory=~s/MB//ig;
			}
			$totmem=&roundup_memory($installed_memory);
			next;
		}
		if ($line =~ /^Platform info:/) {
			$flag_platform=1;	# Start of Platform section
			next;
		}
		if ($flag_platform == 1 && $model eq "HP" && $line =~ /\bModel/i) {
			@linearr=split('[:=]', $line);
			$model=$linearr[1];
			$model=~s/^ +//;
			$model=~s/"//g;
			$model=~s/ +$//;
			if ($model =~ /^ia64/) {
				$machine="ia64";
				$platform="ia64";
				$kernbit=64;
			}
			$model="HP $model" if ($model !~ /\bHP\b/i);
			next;
		}
		if ($line =~ /^OS info:/) {
			$flag_os=1;		# Start of OS section
			next;
		}
		if ($flag_os == 1 && ! $osrel && $line =~ /\bRelease/i) {
			@linearr=split('[:=]', $line);
			$osrel=$linearr[1];
			$osrel=~s/^ +//;
			$osrel=~s/^HP-UX //;
			&hpux_osrelease;
			next;
		}
	}
	$is_hpvm=1 if ($model =~ /Virtual Machine/);
}

sub hpux_osrelease {
	if ($osrel eq "B.11.11") {
		$osrelease="11i v1";
	} elsif ($osrel eq "B.11.20") {
		$osrelease="11i v1.5";
	} elsif ($osrel eq "B.11.22") {
		$osrelease="11i v1.6";
	} elsif ($osrel eq "B.11.23") {
		$osrelease="11i v2";
	} elsif ($osrel eq "B.11.31") {
		$osrelease="11i v3";
	}
}

sub hpux_cprop {
	&pdebug("in hpux_cprop");
	$config_cmd="/opt/propplus/bin/cprop -summary -c Memory";
	$config_command="cprop";
	# Use HP-UX SysMgmtPlus software to attempt to report memory
	if ($filename) {
		$cprop_out="<$filename";
	} else {
		&show_header;
		$cprop_out="$config_cmd 2>&1 |";
	}
	$cnt=0;
	open(FILE, $cprop_out);
	while(<FILE>) {
		next if (/^[\s\*\-]+$/);
		next if (/(<OUT OF SPEC>| Unknown|: Other|: \.\.|: Not Specified|:\s*$)/i);
		($permission_error)=(/(.*)/) if (/Permission denied|does not have privileges|is not authorized to run/i);
		if (/not supported on HPVM guest/i) {
			$is_hpvm=1;
			last;
		}
		$memarr++ if (/^\[Instance\]:\s+\d+/);
		if ($memarr >= 0) {
			($Status[$memarr])=(/:\s+(.*)$/) if (/\[Status\]:\s+/);
			if (/\[Location\]:\s+/) {
				($Location[$memarr])=(/Location\]:\s+(.*)$/);
				$Location[$memarr]=~s/^.*details\s+://;
				$Location[$memarr]=~s/\s+:\s+/:/g;
				$Location[$memarr]=~s/\.$//;
			}
			($Size[$memarr])=(/:\s+(.*)$/) if (/\[Size\]:\s+/);
			($ModType[$memarr])=(/:\s+(.*)$/) if (/\[Module Type\]:\s+/);
			($MemType[$memarr])=(/:\s+(.*)$/) if (/\[Memory Type\]:\s+/);
			if (/\[Part Number\]:\s+/) {
				($PN[$memarr])=(/:\s+(.*)$/);
				$PN[$memarr]=&hex2ascii($PN[$memarr]);
			}
		}
	}
	close(FILE);
	$installed_memory=0;
	for ($cnt=0; $cnt <= $memarr; $cnt++) {
		$buffer="";
		if (defined($Size[$cnt])) {
			$buffer="$Location[$cnt]:" if (defined($Location[$cnt]));
			$buffer.=" $PN[$cnt]" if (defined($PN[$cnt]));
			$simmsize=$Size[$cnt];
			if ($simmsize =~ /GB/) {
				$simmsize=~s/GB//g;
				$simmsize *= 1024;
			} else {
				$simmsize=~s/MB//ig;
			}
			$installed_memory += $simmsize;
			$buffer.=" $Size[$cnt]";
			$buffer.=" $MemType[$cnt]" if (defined($MemType[$cnt]));
			$buffer.=" $ModType[$cnt]" if (defined($ModType[$cnt]));
			if (defined($Status[$cnt])) {
				if ($Status[$cnt] !~ /OK/i) {
					$buffer.=" - $Status[$cnt]";
					$failing_memory=1;
				}
			}
			$buffer=~s/^\s+//;
			if ("$buffer" ne "") {
				push(@boards_mem, "$buffer\n");
				$boardfound_mem=1;
				$memfrom="cprop";
			}
		} elsif (defined($Location[$cnt])) {
			# Empty socket
			$sockets_empty .= ";" if ($sockets_empty);
			$sockets_empty .= " $Location[$cnt]";
		}
	}
	$totmem=$installed_memory if (! $totmem);
	if ($installed_memory && $totmem && $installed_memory != $totmem) {
		print "ERROR: Total installed memory (${totmem}MB) does not ";
		print "match the total of the\n       memory modules found ";
		print "(${installed_memory}MB).\n";
	}
	&hpux_finish;
}

sub hpux_cstm {
	&pdebug("in hpux_cstm");
	$config_cmd="echo 'selclass qualifier memory;info;wait;infolog'|/usr/sbin/cstm 2>&1";
	if (! $filename && $verbose == 3) {
		# Include CPU information when E-mailing maintainer since this
		# data is used by memconf for regression testing.
		$config_cmd="echo 'selclass qualifier cpu;info;wait;selclass qualifier memory;info;wait;infolog'|/usr/sbin/cstm 2>&1";
	}
	$config_command="cstm";
	# Use HP-UX Support Tool Manager software to attempt to report memory
	if (! $filename) {
		&show_header;
		@config=&run("$config_cmd");
	}
	$flag_memerr=0;
	foreach $line (@config) {
		$line=&dos2unix($line);
		next if ($line eq "\n" || $line =~ /^ +$/ || $line =~ /^ +=+$/);
		if ($line =~ /Internal Application error/i) {
			$cstm_error=$line;
			$cstm_error=~s/^ *//;
			next;
		}
		if ($line =~ /=\-\+\-=/) {
			$flag_mem=0;	# End of section
			next;
		}
		if ($line =~ /\bPA [78]\d+.* CPU\b/) {
			$cputype=&mychomp($line);
			$cputype=~s/^.* (PA [78]\d+).*/$1/;
			$cputype=~s/ //g;
			&pdebug(" cputype=$cputype");
			$ncpu++;
		}
		if ($line =~ /^'9000\// && $model eq "HP" && ! $machine) {
			@linearr=split(' ', $line);
			$machine=$linearr[0];
			$machine=~s/\'//g;
			$platform=$machine;
			$model="HP $machine";
		}
		if ($flag_mem == 1) {
			next if ($line =~ /Log creation time/);
			if ($line =~ /^-- Information Tool Log for /) {
				$flag_mem=0;	# End of memory section
				next;
			}
			if ($line =~ /^Memory Error Log Summary/) {
				$flag_memerr=1;	# Start of memory error log
			}
			if ($line =~ / errors logged | memory error log |Last error /) {
				$flag_memerr=0;	# End of memory error log
			}
			if ($flag_memerr == 0 || $verbose) {
				push(@boards_mem, "$line");
			} elsif ($verbose == 0 && $line =~ /^Memory Error Log Summary| errors logged | memory error log |Last error /) {
				# Only display the memory errors if verbose
				push(@boards_mem, "$line");
			}
			$memory_error_logged=1 if ($line =~ / errors logged | Last error detected/);
			$boardfound_mem=1;
			$memfrom="cstm";
		}
		if ($line =~ /^-- Information Tool Log for .*MEMORY / && $flag_mem == 0) {
			$flag_mem=1;	# Start of memory section
		}
	}
	&hpux_finish;
}

sub hpux_finish {
	if ($machine =~ /^9000\/7/) {
		$modelmore="workstation";
	} elsif ($machine =~ /^9000\/8/) {
		$modelmore="server";
	}
	if ($filename) {
		if ($cputype) {
			$cpubanner="$ncpu X " if ($ncpu > 1);
			$cpubanner .= "$cputype";
		} else {
			$cpubanner="$ncpu cpus" if ($ncpu > 1);
		}
		if (defined($cfreq)) {
			$cpubanner .= ", ${cfreq}MHz";
		}
		&show_header;
	}
	if ($boardfound_mem) {
		&pdebug("displaying memory from $memfrom") if ($memfrom);
		print @boards_mem;
		&print_empty_memory("memory slots") if ($sockets_empty);
		&show_total_memory;
	} else {
		if ($filename) {
			&show_total_memory;
		} else {
			if (! $totmem) {
				# Get total memory from kernel
				if ($osmajor > 10) {
					$totmem=&hpux_kernelval("memory_installed_in_machine");
				} else {
					$totmem=&hpux_kernelval("physmem");
				}
				if (defined($totmem)) {
					$totmem /= 256;	# Convert pages to MB
				} else {
					$totmem=0;
				}
				if (-r '/var/adm/syslog/syslog.log' && $totmem == 0) {
					open(FILE, "</var/adm/syslog/syslog.log");
					@syslog=<FILE>;
					close(FILE);
					@physical=grep(/Physical:/,@syslog);
					foreach $line (@physical) {
						@linearr=split(' ', $line);
						$totmem=$linearr[6] / 1024;
						last;
					}
				}
			}
			&show_total_memory;
			# Check if on a virtual machine (HPVM guest)
			if (-x '/opt/hpvm/bin/hpvminfo') {
				&pdebug("Checking hpvminfo");
				$tmp=`/opt/hpvm/bin/hpvminfo 2>&1`;
				if ($tmp =~ /HPVM guest/i) {
					$is_hpvm=1;
				} elsif ($tmp =~ /Permission denied|does not have privileges|is not authorized to run/i) {
					print "ERROR: $tmp";
					print "    This user does not have permission to run '/opt/hpvm/bin/hpvminfo'.\n";
					print "    Run memconf as a privileged user like root on the HPVM host.\n";
				}
			}
		}
		if ($is_hpvm) {
			print "NOTICE: Details shown are for the configuration of this HPVM guest, not the\n        physical CPUs and memory of the HPVM host it is running on.\n";
		} elsif ($config_command eq "cstm") {
			print "ERROR: /usr/sbin/cstm $cstm_error" if (defined($cstm_error));
			print "ERROR: /usr/sbin/cstm did not report the memory installed in this HP-UX system.\n";
			print "       Cannot display detailed memory configuration. A newer version of\n";
			print "       Diagnostic and Support Tools for HP-UX may fix this issue. Aborting.\n";
		}
		$exitstatus=1;
	}
	#
	# Post notice if X86 machine is Hyper-Thread capable, but not enabled
	#
	&show_hyperthreadcapable;

	if ($permission_error) {
		print "ERROR: $permission_error\n";
		print "    This user does not have permission to run $config_command.\n";
		print "    Try running memconf as a privileged user like root.\n" if ($uid ne "0");
		$exitstatus=1;
	}
	# Flag untested CPU types (machine="" on regression test files)
	if (! $machine || $machine =~ /^9000\// || $machine eq "ia64") {
		# Tested HP-UX on PA-RISC and Itanium
		$untested=0;
	} else {
		$untested=1;
		$untested_type="CPU" if (! $untested_type);
	}
	&show_untested if ($untested);
	&show_errors;
	if ($memory_error_logged && $verbose == 0) {
		print "WARNING: Memory errors have been logged.\n";
		print "       Run 'memconf -v' to display the memory error log.\n";
	}
	&mailmaintainer if ($verbose == 3);
	&pdebug("exit $exitstatus");
	exit $exitstatus;
}

sub myawk {
	$awkfile=shift;
	$awksearch=shift;
	$awkfield=shift;
	open(FILE, "<$awkfile");
	@tmp=<FILE>;
	close(FILE);
	foreach $line (@tmp) {
		if ($line =~ /$awksearch/) {
			@linearr=split(' ', $line);
			return $linearr[$awkfield];
		}
	}
	return "";
}

sub x86_devname {
	return if ($have_x86_devname || $machine =~ /sun4|sparc/ || ! defined($model));
	# x86 Sun development names and family part number
	$m=(defined($manufacturer)) ? "$manufacturer $model" : $model;
	$m=~s/-/ /g;
	&pdebug("in x86_devname, model=$m");
	$untested=1 if ($m =~ /(Blade|Server) X\d/i);
	$untested=2 if ($m =~ /Sun |Netra /i);
	if ($m =~ /Sun .*W1100z.*2100z\b/i || $m =~ /Sun .*W[12]100z\b/i) {
		&cpubanner;
		# Check for Opteron 200 Series in case one CPU is disabled
		if ($cpubanner =~ /Opteron.* 2\d\d\b/i || $ncpu == 2) {
			# W2100z uses Opteron 200 Series 2-way processors.
			$devname="Metropolis 2P";
			$familypn="A59";
			$diagbanner="W2100z";
			@socketstr=("DIMM2 Bank 0","DIMM1 Bank 0","DIMM4 Bank 1","DIMM3 Bank 1","DIMM6 Bank 2","DIMM5 Bank 2","DIMM8 Bank 3","DIMM7 Bank 3");
			@reorder_decodedimms=(4,3,2,1,8,7,6,5);
		} elsif ($cpubanner) {
			# W1100z uses Opteron 100 Series 1-way processor.
			# W1100z is not upgradable to dual processors, so
			# don't show empty CPU2 or DIMM5-DIMM8 slots.
			$devname="Metropolis 1P";
			$familypn="A58";
			$diagbanner="W1100z";
			@socketstr=("DIMM2 Bank 0","DIMM1 Bank 0","DIMM4 Bank 1","DIMM3 Bank 1");
			@reorder_decodedimms=(4,3,2,1);
		}
		$model="Java Workstation $diagbanner";
		$diagbanner=$model;
		$untested=0;
	}
	if ($m =~ /Sun .*V20z.*40z\b/i) {
		$devname="Stinger";
		$familypn="A55 (V20z), A57 (V40z)";
	} elsif ($m =~ /Sun .*V20z\b/i) {
		$devname="Stinger 2P";
		$familypn="A55";
		$untested=0;
	} elsif ($m =~ /Sun .*V40z\b/i) {
		$devname="Stinger 4P";
		$familypn="A57";
		$untested=0;
	}
	if ($m =~ /\bX2100 M2\b/i) {
		$devname="Leo";
		$familypn="A84";
		$untested=0;
	} elsif ($m =~ /Sun .*X2100\b/i) {
		$devname="Aquarius";
		$familypn="A75";
		$untested=0;
	}
	if ($m =~ /Sun .*X2200 (speedbump|M2\b.*Quad.*Core)/i) {
		# AMD Quad-Core Barcelona processor
		$devname="Taurus2";
		$familypn="A85";
		$untested=0;
	} elsif ($m =~ /Sun .*X2200 M2\b/i) {
		$devname="Taurus";
		$familypn="A85";
		$untested=0;
	}
	if ($m =~ /Sun .*X2250\b/i) {
		$devname="Venus";
		$familypn="X2250";
		$untested=0;
	}
	if ($m =~ /Sun .*X2270 M2\b/i) {
		# X2270 has 1 or 2 CPUs
		$familypn="X2270M2";
		$untested=0 if ($os eq "SunOS");
	} elsif ($m =~ /Sun .*X2270\b/i) {
		# X2270 has 1 or 2 Quad-Core hyper-threaded CPUs
		$familypn="X227";
		$untested=0 if ($os eq "SunOS");
	}
	if ($m =~ /Sun .*X4100 M2\b/i) {
		$devname="Galaxy 1F";
		$familypn="A86";
		$untested=0;
	} elsif ($m =~ /Sun .*X4100\b/i) {
		$devname="Galaxy 1U";
		$familypn="A64";
		$untested=0;
	}
	if ($m =~ /Sun .*X4100E\b/i) {
		$devname="Galaxy 1E";	# Cancelled
		$familypn="A72";
	}
	if ($m =~ /Sun .*X4140\b/i) {
		$devname="Dorado 1U";
		$familypn="B12";
		$untested=0;
	}
	if ($m =~ /Sun .*X4150\b/i) {
		$devname="Doradi 1U";
		$familypn="B13";
		$untested=0;
	}
	if ($m =~ /Sun .*X4170\b/i) {
		# X4170 has 1 or 2 Quad-Core hyper-threaded CPUs
		$devname="Lynx 1U";
		$familypn="X4170";
		$untested=0;
	}
	if ($m =~ /Sun .*X4200 M2\b/i) {
		$devname="Galaxy 2F";
		$familypn="A87";
		$untested=0;
	} elsif ($m =~ /Sun .*X4200\b/i) {
		$devname="Galaxy 2U";
		$familypn="A65";
		$untested=0;
	}
	if ($m =~ /Netra .*X4200\b/i) {
		$devname="Draco";
		$familypn="N87";
	}
	if ($m =~ /Sun .*X4200E\b/i) {
		$devname="Galaxy 2E";	# Cancelled
		$familypn="A73";
	}
	if ($m =~ /Sun .*X4240\b/i) {
		$devname="Dorado 2U";
		$familypn="B14";
		$untested=0;
	}
	if ($m =~ /Netra .*X4250\b/i) {
		$devname="Aries";
		$familypn="NX425";
	}
	if ($m =~ /Sun .*X4250\b/i) {
		$devname="Doradi 2U";
		$familypn="X4250";
		$untested=0 if ($os eq "SunOS");
	}
	if ($m =~ /Sun .*X4270 M2\b/i) {
		# X4270 has 1 or 2 Quad-Core hyper-threaded CPUs
		$devname="Lynx 2U";
		$familypn="X4270M2";
		$untested=0;
	} elsif ($m =~ /Sun .*X4270\b/i) {
		$devname="Lynx 2U";
		$familypn="X4270";
		$untested=0;
	}
	if ($m =~ /Sun .*X4275\b/i) {
		# X4275 has 1 or 2 Quad-Core hyper-threaded CPUs
		$devname="Lynx 2U";
		$familypn="X4275";
	}
	if ($m =~ /Netra .*X4270\b/i) {
		$familypn="NX4270";
	}
	if ($m =~ /Sun .*X4440\b/i) {
		$devname="Tucana";
		$familypn="B16";
		$untested=0 if ($os eq "SunOS");
	}
	if ($m =~ /Sun .*X4450\b/i) {
		$devname="Tucani";
		$familypn="B15";
		$untested=0;
	}
	if ($m =~ /Netra .*X4450\b/i) {
		$devname="Argo";
	}
	if ($m =~ /Sun .*X4470 M2\b/i) {
		# X4470 has 4 CPU sockets
		$familypn="X4470M2";
		$untested=0 if ($os eq "SunOS");
	} elsif ($m =~ /Sun .*X4470\b/i) {
		$familypn="X4470";
		$untested=0 if ($os eq "SunOS");
	}
	if ($m =~ /Sun .*X4500\b/i) {
		$devname="Thumper";
		$familypn="A76";
		$untested=0;
	}
	if ($m =~ /Sun .*X4540\b/i) {
		$devname="Thor";
		$familypn="B24";
		$untested=0 if ($os eq "SunOS");
	}
	if ($m =~ /Sun .*X4600\b/i) {
		$devname="Galaxy 4U";
		$familypn="A67";	# Same for X4600 M2
		$devname="Galaxy 4F" if ($m =~ /Sun .*X4600 M2\b/);
		$untested=0;
	}
	if ($m =~ /Sun .*X4640\b/i) {
		# Replacement for Sun Fire X4600 M2
		$familypn="X4640";
		$untested=0 if ($os eq "SunOS");
	}
	if ($m =~ /Sun .*X4800 M2\b/i) {
		# X4800 has 8 CPU sockets
		$familypn="X4800M2";
	} elsif ($m =~ /Sun .*X4800\b/i) {
		# X4800 has 8 CPU sockets
		$familypn="X4800";
		$untested=0 if ($os eq "SunOS");
	}
	if ($m =~ /Sun .*X4950\b/i) {
		$devname="Streamstar StreamSwitch 2";
		$familypn="A91";
	}
	# The Sun Blade 8000 Modular System uses the Sun Blade
	# X8420/X8440/X8450 Server Modules
	if ($m =~ /Sun .*Blade 8000\b/i) {
		$devname="Andromeda 19";
		$familypn="A81";
		if ($m =~ /Sun .*Blade 8000 P\b/i) {
			$devname="Andromeda 14";
			$familypn="A82";
		}
		$untested=2;
	}
	if ($m =~ /Sun .*Fire V60x\b|Sun .*Fire\(tm\) V60\b/i) {
		$devname="Grizzly";
		$familypn="A48";
	}
	if ($m =~ /Sun .*Fire V65x\b|Sun .*Fire\(tm\) V65\b/i) {
		$devname="Grizzly 2U";
		$familypn="A48";
		$untested=0 if ($os eq "SunOS");
	}
	if ($m =~ /Sun .*Ultra *20 M2\b/i) {
		$devname="Munich";
		$familypn="A88";
		$untested=2;
		$untested=0 if ($os eq "SunOS");
	} elsif ($m =~ /Sun .*Ultra *20\b/i) {
		$devname="Marrakesh";
		$familypn="A63";
		$untested=2;
		$untested=0 if ($os eq "SunOS");
	}
	if ($m =~ /Sun .*Ultra *24\b/i) {
		$devname="Ursa";
		$familypn="B21";
		$untested=0;
	}
	if ($m =~ /Sun .*Ultra *27\b/i) {
		$familypn="B27";
		$untested=0;
	}
	if ($m =~ /Sun .*Ultra *40 M2\b/i) {
		$devname="Stuttgart";
		$familypn="A83";
		$untested=0;
	} elsif ($m =~ /Sun .*Ultra *40\b/i) {
		$devname="Sirius";
		$familypn="A71";
		$untested=0;
	}
	# The Sun Blade 6000 and 6048 Modular Systems use the Sun Blade
	# X6220, X6250 or T6300 Server Modules.
	if ($m =~ /Sun .*Blade 6000\b/i) {
		$devname="Constellation 10";
		$familypn="A90";
		$untested=2;
	}
	if ($m =~ /Sun .*Blade 6048\b/i) {
		$devname="Constellation 48";
		$familypn="B22";
		$untested=2;
	}
	if ($m =~ /Sun .*X6220\b/i) {
		$devname="Gemini";
		$familypn="A92";
	}
	if ($m =~ /Sun .*X6240\b/i) {
		$devname="Gemini+";
		$familypn="X6240";
		$untested=0 if ($os eq "SunOS");
	}
	if ($m =~ /Sun .*X6250\b/i) {
		$devname="Wolf";
		$familypn="A93";
		$untested=0;
	}
	if ($m =~ /Sun .*X6270 M2\b/i) {
		# X6270 has 1 or 2 CPUs
		$familypn="X6270M2";
		$untested=0;
	} elsif ($m =~ /Sun .*X6270\b/i) {
		# X6270 has 1 or 2 Quad-Core hyper-threaded CPUs
		$familypn="X6270";
		$untested=0;
	}
	if ($m =~ /Sun .*X6275 M2\b/i) {
		# X6275 M2 has 2 Quad-Core or Six-Core hyper-threaded CPUs
		$familypn="X6275M2";
	} elsif ($m =~ /Sun .*X6275\b/i) {
		# X6275 has 2 or 4 Quad-Core hyper-threaded CPUs
		$familypn="X6275";
	}
	if ($m =~ /Sun .*X6420\b/i) {
		$devname="Pegasus";
	}
	if ($m =~ /Sun .*X6440\b/i) {
		$devname="Pegasus+";
		$familypn="X6440";
	}
	if ($m =~ /Sun .*X6450\b/i) {
		$devname="Hercules2";
		$familypn="X6450";
	}
	if ($m =~ /Sun .*X8400\b/i) {
		$devname="Andromeda";
		$familypn="X8400";
	}
	if ($m =~ /Sun .*X8420\b/i) {
		$devname="Capella";
	}
	if ($m =~ /Sun .*X8440\b/i) {
		$devname="Mira";
		$familypn="A98";
	}
	if ($m =~ /Sun .*X8450\b/i) {
		# Quad-Core CPU for Sun Blade 8000 chassis
		$devname="Scorpio";
		$familypn="X8450";
	}
	if ($m =~ /Sun .*X8600\b/i) {
		$devname="Antares";
	}
	$untested=1 if ($m =~ /Netra Server X3.2\b/i);				# X3-2
	$untested=0 if ($m =~ /Sun Server X4.2\b/i && $os eq "SunOS");		# X4-2
	$untested=0 if ($m =~ /Sun Server X4.2L\b/i && $os eq "SunOS");		# X4-2L
	$untested=1 if ($m =~ /Sun Server X4.4\b/i);				# X4-4
	$untested=1 if ($m =~ /Sun Server X4.8\b/i);				# X4-8
	$untested=1 if ($m =~ /Netra Blade X3.2B\b/i);				# X3-2B
	$untested=1 if ($m =~ /Sun Blade X4.2B\b/i);				# X4-2B
	$untested=0 if ($m =~ /Oracle Server X5.2\b/i && $os eq "SunOS");	# X5-2
	$untested=0 if ($m =~ /Oracle Server X5.2L\b/i && $os eq "SunOS");	# X5-2L
	$untested=0 if ($m =~ /Oracle Server X6.2L\b/i && $os eq "SunOS");	# X6-2L
	$have_x86_devname=1 if ($devname);
}

sub releasefile {
	# Check file for release information
	$arg=shift;
	&pdebug("in releasefile, checking $arg");
	open(FILE, $arg);
	while(<FILE>) {
		$tmp=&mychomp($_);
		next if ($tmp =~ /^[\s\*\-\_\\\/\|]*$/);
		# Ignore line if it starts with Escape sequence
		next if ($tmp =~ /^\e\[/);
		$tmp=~s/\s*\\[nr].*//;
		$tmp=~s/^Welcome to //;
		$tmp=~s/\s+-\s+.*//;
		&pdebug("in releasefile $arg, found $tmp");
		return($tmp);
	}
	close(FILE);
	return("");
}

sub linux_distro {
	$release="";
	$osname="$os $osrel";
	$osname="$os" if ($osrel eq "");
	$kernbit="";
	$kernbit="32-bit kernel" if ($machine =~ /i.86|sparc/);
	$kernbit="64-bit kernel" if ($machine =~ /x86_64|sparc64|ia64|amd64/);
	if (-f '/etc/freebsd-update.conf') {
		# FreeBSD
		@linearr=split(' ', $kernver);
		$release="$linearr[0] $linearr[1], $kernbit";
		return;
	}
	$kernbit .= ", " if ($kernbit);
	foreach $relfile ('/etc/pclinuxos-release',
			  '/etc/centos-release',
			  '/etc/distro-release',
			  '/etc/enterprise-release',
			  '/etc/fedora-release',
			  '/etc/frugalware-release',
			  '/etc/kate-version',
			  '/etc/myah-version',
			  '/etc/pardus-release',
			  '/etc/parsix-version',
			  '/etc/sabayon-release',
			  '/etc/vector-version',
			  '/etc/whitebox-release',
			  '/etc/yellowdog-release',
			  '/etc/yoper-release',
			  '/etc/UnitedLinux-release',
			  '/etc/gentoo-release',
			  '/etc/mandriva-release',
			  '/etc/mandrakelinux-release','/etc/mandrake-release',
			  '/etc/slackware-version','/etc/slackware-release',
			  '/etc/redhat-release','/etc/redhat_version',
			  '/etc/SuSE-release') {
		if (-f "$relfile") {
			$release=&releasefile($relfile);
			$release .= ", $kernbit$osname";
			return;
		}
	}
	if (-d '/KNOPPIX') {
		if (-r '/cdrom/index.html') {
			open(FILE, "</cdrom/index.html");
			while(<FILE>) {
				if (/<TITLE>/) {
					$release=&mychomp($_);
					$release=~s/<TITLE>//;
					$release=~s/<\/TITLE.*//;
				}
			}
			close(FILE);
		} elsif (-r '/init') {
			open(FILE, "</init");
			while(<FILE>) {
				if (/DISTRO=/) {
					$release=&mychomp($_);
					$release=~s/.*DISTRO="*(.*)$/$1/;
					$release=~s/"//g;
				}
			}
			close(FILE);
		}
		$release="Knoppix" if (! $release);
		$release .= ", $kernbit$osname";
		$release .= ", " . &releasefile("/etc/issue") if (-f '/etc/issue');
		return;
	} elsif (-f '/gos/gOS/gos.html') {
		$release="gOS, $kernbit$osname";
		$release .= ", " . &releasefile("/etc/issue") if (-f '/etc/issue');
		return;
	} elsif (-f '/etc/motd.static') {
		$release=&releasefile("/etc/motd.static");
		$release .= ", $kernbit$osname";
		if (-f '/etc/issue') {
			$tmp=&releasefile("/etc/issue");
			if ($release =~ /Knoppix/i) {
				$release="Knoppix, $kernbit$osname, $tmp";
			} else {
				$release .= ", $tmp";
			}
		}
		return;
	} elsif (-d '/ffp/etc') {
		$release="fun_plug";
		if (-f '/ffp/etc/ffp-version') {
			$tmp=&mychomp(`grep FFP_VERSION= /ffp/etc/ffp-version`);
			$tmp=~s/^.*=//;
			$release .= " $tmp" if ($tmp);
		}
		if (-f '/etc/Alt-F') {
			$tmp=&releasefile('/etc/Alt-F');
			$release="Alt-F $tmp with $release";
		}
	} elsif (-f '/etc/Alt-F') {
		$tmp=&releasefile('/etc/Alt-F');
		$release="Alt-F $tmp";
	}
	# Debian, Ubuntu, BusyBox, etc.
	foreach $relfile ('/etc/issue.net','/etc/issue','/etc/motd') {
		$release=&releasefile("$relfile") if (! $release && -f "$relfile");
	}
	$release=(defined($release)) ? "$release, $kernbit$osname" : "";
	$release=~s/^, //;
}

sub check_mixedspeeds {
	$_=shift;
	return if ($_ !~ /(\dMHz|\dns)/);
	s/^.* (\d*)MHz.*$/$1/;
	s/^(\d*)MHz.*$/$1/;
	s/^.* (\d*)ns.*$/$1/;
	s/^(\d*)ns.*$/$1/;
	return if (! $_);
	&pdebug("in check_mixedspeeds, value=$_");
	# round some memory speeds
	$_=266 if ($_ >= 265 && $_ <= 285);	# DDR-266 PC-2100
	$_=667 if ($_ >= 665 && $_ <= 668);	# DDR2-667 PC2-5300
	$_=1066 if ($_ >= 1065 && $_ <= 1068);	# DDR2-1066 PC2-8500, DDR3-1066 PC3-8500
	$_=1866 if ($_ >= 1865 && $_ <= 1868);	# DDR3-1866 PC3-14900
	if ($foundspeed) {
		$mixedspeeds=1 if ($foundspeed ne $_);
	} else {
		$foundspeed=$_;
	}
}

sub roundup_memory {
	$newval=shift;
#	&pdebug("in roundup_memory $newval");
	# Round up memory (may have 128MB or more reserved)
	# Works for up to 16777216GB (16TB)
	for ($val=16; $val <= 64; $val += 16) {
		$newval=$val if ($newval >= $val-8 && $newval < $val);
	}
	for ($val=64; $val <= 1024; $val += 32) {
		$newval=$val if ($newval >= $val-16 && $newval < $val);
	}
	for ($val=1024; $val <= 4096; $val += 512) {
		$newval=$val if ($newval >= $val-128 && $newval < $val);
	}
	for ($val=4096; $val <= 14336; $val += 1024) {
		$newval=$val if ($newval >= $val-512 && $newval < $val);
	}
	for ($val=14336; $val <= 32768; $val += 2048) {
		$newval=$val if ($newval >= $val-1024 && $newval < $val);
	}
	for ($val=32768; $val <= 262144; $val += 4096) {
		$newval=$val if ($newval >= $val-2048 && $newval < $val);
	}
	for ($val=262144; $val <= 1048576; $val += 8192) {
		$newval=$val if ($newval >= $val-4096 && $newval < $val);
	}
	for ($val=1048576; $val <= 4194304; $val += 16384) {
		$newval=$val if ($newval >= $val-8192 && $newval < $val);
	}
	for ($val=4194304; $val <= 16777216; $val += 32768) {
		$newval=$val if ($newval >= $val-16384 && $newval < $val);
	}
	for ($val=16777216; $val <= 67108864; $val += 65536) {
		$newval=$val if ($newval >= $val-32768 && $newval < $val);
	}
	for ($val=67108864; $val <= 268435456; $val += 131072) {
		$newval=$val if ($newval >= $val-65536 && $newval < $val);
	}
	return($newval);
}

sub check_dmidecode_ver {
	$tmp=shift;
	@dmidecode_verarr=split(/\./, $dmidecode_ver);
	if (defined($tmp)) {
		@latest_dmidecode_verarr=split(/\./, $latest_dmidecode_ver);
		if (($dmidecode_verarr[0] < $latest_dmidecode_verarr[0]) ||
		    ($dmidecode_verarr[0] == $latest_dmidecode_verarr[0] &&
		     $dmidecode_verarr[1] < $latest_dmidecode_verarr[1])) {
			print "    Your dmidecode package is an old version";
			print " ($dmidecode_ver)" if ($dmidecode_ver);
			print ", so consider upgrading\n";
			print "    to dmidecode-$latest_dmidecode_ver or later.\n";
		} elsif ($dmidecode_ver) {
			print "    Your dmidecode version is $dmidecode_ver.\n" if (defined($tmp));
		}
	}
	@minimum_dmidecode_verarr=split(/\./, $minimum_dmidecode_ver);
	if (($dmidecode_verarr[0] < $minimum_dmidecode_verarr[0]) ||
	    ($dmidecode_verarr[0] == $minimum_dmidecode_verarr[0] &&
	     $dmidecode_verarr[1] < $minimum_dmidecode_verarr[1])) {
		return 1;
	} else {
		return 0;
	}
}

sub check_free {
	return if ($free_checked);
	&pdebug("in check_free");
	$free_checked=1;
	if (! $filename && $free_cmd) {
		# Check memory detected by OS
		@free=&run("$free_cmd");
		$have_free_data=1;
	}
	if (! $filename && $meminfo_cmd) {
		# Check memory detected by kernel
		@meminfo=&run("$meminfo_cmd");
		$have_meminfo_data=1;
	}
	if ($have_meminfo_data) {
		foreach $line (@meminfo) {
			$line=&dos2unix($line);
			if ($line =~ /MemTotal:\s+\d+ kB/) {
				@linearr=split(' ', $line);
				$freephys=int($linearr[1] / 1024);
				$totmem=&roundup_memory($freephys) if ($totmem == 0);
				last;
			}
		}
	}
	if ($have_free_data && ! $freephys) {
		foreach $line (@free) {
			$line=&dos2unix($line);
			if ($line =~ /Mem:/) {
				@linearr=split(' ', $line);
				$freephys=$linearr[1];
				$totmem=&roundup_memory($freephys) if ($totmem == 0);
				last;
			}
		}
	}
}

sub check_for_decodedimms {
	return if (&is_virtualmachine);
	# Need root permissions to load eeprom kernel module
	return if ($uid ne "0" && ! $filename);
	&pdebug("in check_for_decodedimms");
	if (! $filename && $decodedimms_cmd) {
		$flag=1;
		# Some systems lockup when loading eeprom module, avoid them
		# Avoid running on systems with PIIX4 like Dell PowerEdge 2650
		@tmp=&run("/sbin/modprobe i2c_dev");
		@tmp=&run("/usr/sbin/i2cdetect -l | grep -w PIIX4");
		$flag=0 if (@tmp);
		# See if eeprom module is already loaded in kernel
		@tmp=&run("/sbin/lsmod | grep -w eeprom");
		$flag=2 if (@tmp);
		if ($flag) {
			# Check memory SPD data from EEPROM
			@tmp=&run("$modprobe_eeprom_cmd") if ($flag == 1);
			@decodedimms=&run("$decodedimms_cmd");
			$have_decodedimms_data=1;
		}
	}
}

sub check_topology {
	# Stoutland Platform (SGI Blade Chassis) topology command 
	return if (&is_virtualmachine);
	&pdebug("in check_topology");
	if ($filename) {
		@topology=@config;
	} else {
		@topology=&run("$topology_cmd");
	}
	$flag_mem=0;
	$partition_cnt=0;
	foreach (@topology) {
		$_=&dos2unix($_);
		$_=&mychomp($_);
		if (/^System type: /) {
			push(@topology_header, "$_\n");
			$topology_mfg="SGI.COM" if (/ UV/);
		}
		if (/^Serial number: /) {
			push(@topology_header, "$_\n");
			$topology_mfg="SGI.COM" if (/ UV/);
		}
		if (/^Partition number: /) {
			push(@topology_header, "$_\n");
			$partition_cnt++;
		}
		push(@topology_header, "$_\n") if (/^\s*\d+ Blades$/);
		push(@topology_header, "$_\n") if (/^\s*\d+ CPUs$/);
		push(@topology_header, "$_\n") if (/^\s*\d+.* GB Memory Total/i);
		push(@topology_header, "$_\n") if (/^\s*\d+.* GB Max Memory.*/i);
		$flag_mem=1 if (/(Idx|Index)\s.*\sNASID\s+CPUS\s+Memory/);
		$flag_mem=0 if (/^\s*$/);
		push(@topology_data, "$_\n") if ($flag_mem);
	}
}

sub check_decodedimms {
	return if ($decodedimms_checked);
	return if (&is_virtualmachine);
	&pdebug("in check_decodedimms");
	$decodedimms_checked=1;
# TLS - uncomment to not use decode-dimms.pl data - 19-Apr-2012
#	$have_decodedimms_data=0;
# TLS - If decode-dimms.pl is not available, suggest that it can be installed
#       with lmsensors to get more detailed memory information.
	if ($have_decodedimms_data) {
		$flag_mem=0;
		$flag_unknown=0;
		$mem_mfg="";
		$pn="";
		$simmsize=0;
		$memtype="";
		$dimmspeed="";
		$cnt=0;
		foreach $line (@decodedimms) {
			$line=&dos2unix($line);
			$line=&mychomp($line);
			if ($line =~ /^Guessing DIMM is in/i) {
				$tmp=$line;
				$tmp=~s/^.*\s+(\d+)\s*$/$1/;
				$cnt=($tmp - 1) if ($tmp);
				$flag_mem=1;
			}
			$flag_mem=0 if ($line =~ /^(Decoding EEPROM|EEPROM Checksum of bytes.*Bad|Number of SDRAM DIMMs detected and decoded)/i);
			if ($flag_mem) {
				if ($line =~ /^Fundamental Memory type/i) {
					# Required data from SPD EEPROM
					$memtype=$line;
					$memtype=~s/^Fundamental Memory type\s+(.*\S)\s*$/ $1/;
					&pdebug("in check_decodedimms, cnt=$cnt, memtype=$memtype");
					$flag_unknown=($memtype =~ /^ *Unknown/i) ? 1 : 0;
					if ($flag_unknown) {
						&pdebug("in check_decodedimms, cnt=$cnt, Unknown memtype detected - failing DIMM");
					}
				}
				if ($line =~ /^Maximum module speed/i) {
					$dimmspeed=$line;
					$dimmspeed=~s/^Maximum module speed\s+\D+\s+(.*\S)\s*$/ $1/;
					&check_mixedspeeds($dimmspeed);
					&pdebug("in check_decodedimms, cnt=$cnt, dimmspeed=$dimmspeed");
				}
				$simmsize=$sizearr[$cnt] if (defined($sizearr[$cnt]) && ! $simmsize);
				if ($line =~ /^Size\s+.*MB/i) {
					$simmsize=$line;
					$simmsize=~s/^Size\s+(\d+)\s*MB.*$/$1/;
					&pdebug("in check_decodedimms, cnt=$cnt, simmsize=$simmsize");
				}
				if ($line =~ /^Manufacturer\s+/i) {
					$mem_mfg=$line;
					$mem_mfg=~s/^Manufacturer\s+(.*\S)\s*$/ $1/;
					$mem_mfg=&get_mfg($mem_mfg);
					$mem_mfg="" if ($mem_mfg =~ /^\s+(FFFFFFFFFFFF|000000000000|Undefined)/i);
					$mem_mfg=" $mem_mfg" if ($mem_mfg);
					&pdebug("in check_decodedimms, cnt=$cnt, mem_mfg=$mem_mfg");
				}
				if ($line =~ /^Part Number\s+/i) {
					$pn=$line;
					$pn=~s/^Part Number\s+(.*\S)\s*$/ $1/;
					$pn="" if ($pn =~ /^\s+(FFFFFFFFFFFF|000000000000|Undefined)/i);
					&pdebug("in check_decodedimms, cnt=$cnt, pn=$pn");
				}
			} elsif ($simmsize && $memtype) {
				if ($reorder_decodedimms[$cnt]) {
					$tmp=$reorder_decodedimms[$cnt]-1;
					&pdebug("in check_decodedimms, reorder cnt=$tmp");
				} else {
					$tmp=$cnt;
				}
				if (defined($socketlabelarr[$tmp])) {
					$socket=$socketlabelarr[$tmp];
					$offset=-1;
					$incr=0;
					foreach (@boards_mem) {
						if (/\b$socket\b/) {
							if ($MemPartNum[$incr-1]) {
								# make sure pn matches
								$offset=$incr if (" $MemPartNum[$incr-1]" eq "$pn");
							} else {
								$offset=$incr;
							}
						}
						$incr++;
					}
					if ($offset >= 0) {
						($old)=grep(/$socket/,@boards_mem);
						chop($old);
						if ($flag_unknown) {
							$tmp="$old - FAILING";
							$failing_memory=1;
						} else {
							$tmp="$socket: ${simmsize}MB$dimmspeed$memtype";
							$tmp .= ",$mem_mfg$pn" if ($mem_mfg || $pn);
						}
						@tmp=("$tmp\n");
						# Replace socket data from dmidecode
						# with socket data from decode-dimms.pl
						&pdebug("in check_decodedimms, replace socket data '$old' with '$tmp'");
						splice(@boards_mem, $offset, 1, @tmp);
						$memfrom="decode-dimms.pl" if ($memfrom !~ /decode-dimms.pl/);
					}
				} else {
					$memfrom="dmidecode and decode-dimms.pl";
				}
				$mem_mfg="";
				$pn="";
				$simmsize=0;
				$memtype="";
				$dimmspeed="";
				$cnt++;
			}
		}
	}
}

sub check_dmidecode {
	&pdebug("in check_dmidecode");
	$DMI6=0;
	$DMI6cnt=0;
	$DMI6totmem=0;
	$DMI17=0;
	$DMI17totmem=0;
	$DMI17end=0;
	$DMItype=0;
	$platform="";
	$FoundEnd=0;
	$BrokenTable="";
	$unknown_JEDEC_ID=0;
	$ECCDIMM=0;
	$config_command="dmidecode";
	if ($filename) {
		$DmiFile="<$filename";
	} else {
		$DmiFile="$config_cmd 2>&1 |";
		&linux_distro if (! $release);
		if ($ipmitool_cmd && ! $have_ipmitool_data) {
			@ipmitool=&run("$ipmitool_cmd fru");
			$have_ipmitool_data=1;
		}
	}
	$cpu_membank=-1;
	$physmemarray="";
	$memfrom="dmidecode";
	&check_for_decodedimms;
	&check_topology;
	open(FILE, $DmiFile);
	while(<FILE>) {
		next if (/(<OUT OF SPEC>| Unknown|: Other|: \.\.|: Not Specified|:\s*$)/i);
		# for regression tests
		$have_decodedimms_data=1 if (/^Guessing DIMM is in/i);
		($dmidecode_ver)=(/.* dmidecode (.*)/i) if (/ dmidecode /i);
		($permission_error)=(/(.*)/) if (/Permission denied/i);
		($dmidecode_error)=(/# *(.*)/) if (/No SMBIOS nor DMI entry point found/i && ! &is_xen_vm);
		# Detect end of DMI type 17 blocks
#		&pdebug("In DMI type 17, $_") if ($DMItype == 17);
		if (/(^Handle|^\s*$)/i && $DMItype == 17 && $memarr >= 0 && ! $DMI17end) {
			$DMI17end=1;
			$DMItype=0;
			# Ignore Flash chips for DMI17totmem
			$Size17[$memarr]=0 if (! defined($Size17[$memarr]));
			$Type17[$memarr]="" if (! defined($Type17[$memarr]));
			&pdebug("End of DMI type 17 block, $Size17[$memarr] $Type17[$memarr] detected") if ($Type17[$memarr] =~ /Flash/i);
			if ($Size17[$memarr] !~ /Not Installed/i && $Size17[$memarr] !~ /No Module Installed/i && $Type17[$memarr] !~ /Flash/i) {
				&pdebug("End of DMI type 17 block, adding $Size17[$memarr] memory to total");
				$simmsize=$Size17[$memarr];
				if ($simmsize =~ / *GB.*/i) {
					$simmsize=~s/ *GB.*//ig;
					$simmsize *= 1024;
				} else {
					$simmsize=~s/ *MB.*//ig;
				}
				$DMI17totmem += $simmsize if ($simmsize);
			}
		}
		($DMItype)=(/DMI type (\d+)/i) if (/\bDMI type /i);
		if (/Handle .* DMI type 16,/i) {
			($tmp)=(/Handle (.*), DMI type 16,/i);
			$cpu_membank++ if ($physmemarray ne $tmp);
			$physmemarray=$tmp;
		}
		$DMI17end=0 if ($DMItype != 17);

		# Type  Information
		# ----------------------------------------
		#   0   BIOS
		#   1   System
		#   2   Base Board
		#   3   Chassis
		#   4   Processor
		#   5   Memory Controller
		#   6   Memory Module
		#   7   Cache
		#   8   Port Connector
		#   9   System Slots
		#  10   On Board Devices
		#  11   OEM Strings
		#  12   System Configuration Options
		#  13   BIOS Language
		#  14   Group Associations
		#  15   System Event Log
		#  16   Physical Memory Array
		#  17   Memory Device
		#  18   32-bit Memory Error
		#  19   Memory Array Mapped Address
		#  20   Memory Device Mapped Address
		#  21   Built-in Pointing Device
		#  22   Portable Battery
		#  23   System Reset
		#  24   Hardware Security
		#  25   System Power Controls
		#  26   Voltage Probe
		#  27   Cooling Device
		#  28   Temperature Probe
		#  29   Electrical Current Probe
		#  30   Out-of-band Remote Access
		#  31   Boot Integrity Services
		#  32   System Boot
		#  33   64-bit Memory Error
		#  34   Management Device
		#  35   Management Device Component
		#  36   Management Device Threshold Data
		#  37   Memory Channel
		#  38   IPMI Device
		#  39   Power Supply
		#  40   Additional Information
		#  41   Onboard Device
		# Additionally, type 126 is used for disabled entries and type
		# 127 is an end-of-table marker. Types 128 to 255 are for
		# OEM-specific data.

		# Keep walking the dmidecode output for more about the system

		# Check system information
		if ($DMItype == 0) {
			($biosvendor)=(/: +(.*\S) *$/) if (/^\s*Vendor: /i);
		}
		if ($DMItype == 1) {
			($systemmanufacturer)=(/: +(.*\S) *$/) if (/^\s*(Manufacturer|Vendor): /i);
			($systemmodel)=(/: +(.*\S) *$/) if (/^\s*Product( Name|): /i);
		}
		if ($DMItype == 2) {
			($boardmanufacturer)=(/: +(.*\S) *$/) if (/^\s*(Manufacturer|Vendor): /i);
			($boardmodel)=(/: +(.*\S) *$/) if (/^\s*Product( Name|): /i);
			$boardmodel=~s/^$boardmanufacturer // if ($boardmanufacturer && $boardmodel);
			# use DMItype2 manufacturer if Oracle (for VirtualBox)
			($systemmanufacturer)=(/: +(.*\S) *$/) if (/^\s*(Manufacturer|Vendor): *Oracle */i);
		}

		# Check CPU information
		if ($DMItype == 4) {
			if (/^\s*Processor( Information|)$/i) {
				$cpuarr++;
				$ncpu++;
			}
			if (/^\s*Socket Designation: /i) {
				($CPUSocketDesignation[$cpuarr])=(/: +(.*\S) *$/);
				$CPUSocketDesignation[$cpuarr]="CPU $cpuarr" if ($CPUSocketDesignation[$cpuarr] eq "Microprocessor");
			}
			($CPUFamily[$cpuarr])=(/: +(.*\S) *$/) if (/^\s*(Processor |)Family: /i);
			if (/^\s*(Processor |)Manufacturer: /i) {
				($CPUManufacturer[$cpuarr])=(/: +(.*\S) *$/);
				$CPUManufacturer[$cpuarr]=~s/GenuineIntel/Intel/;
			}
			($CPUVersion[$cpuarr])=(/: +(.*\S) *$/) if (/^\s*(Processor |)Version: /i);
			($ExtSpeed[$cpuarr])=(/: +(.*\S) *$/) if (/^\s*External Clock: /i);
			($CPUSpeed[$cpuarr])=(/: +(.*\S) *$/) if (/^\s*Current Speed: /i);
			if (/^\s*Status: /i) {
				($CPUStatus[$cpuarr])=(/: +(.*\S) *$/);
				if ($CPUStatus[$cpuarr] =~ /(Unpopulated|Disabled By BIOS)/i) {
					$ncpu--;
					$necpu++;
					$CPUVersion[$cpuarr]="";
				}
			}
		}

		# Check memory controller information
		if ($DMItype == 5) {
			($ECCBIOS)=(/: +(.*\S) *$/) if (/^\s*Error Detecting Method: /i && ! $ECCBIOS);
			($interleave)=(/: +(.*\S) *$/) if (/^\s*Current Interleave: /i && $interleave eq "0");
			($MAXMEM)=(/: +(.*\S) *$/) if (/^\s*Maximum Total Memory Size: /i && ! $MAXMEM);
		}

		# Check each memory device
		if ($DMItype == 6) {
			$DMI6=1;
			$memarr++ if (/^\s*Memory (Module Information|Bank)$/i);
			($Locator6[$memarr])=(/: +(.*\S) *$/) if (/^\s*Socket( Designation|): /i);
			($Speed6[$memarr])=(/: +(.*\S) *$/) if (/^\s*Current Speed: /i);
			($Type6[$memarr])=(/: +(.*\S) *$/) if (/^\s*Type: /i);
			if (/^\s*Installed Size: /i) {
				($Size6[$memarr])=(/: +(.*\S) *$/);
				if ($Size6[$memarr] !~ /Not Installed/i && $Size6[$memarr] !~ /No Module Installed/i) {
					$simmsize=$Size6[$memarr];
					$simmsize=~s/ *MB.*//ig;
					$DMI6totmem += $simmsize if ($simmsize);
					$SizeDetail[$memarr]=$Size6[$memarr];
					$Size6[$memarr]=$simmsize . "MB";
					$SizeDetail[$memarr]=~s/\d+ *MBy*t*e* *//i;
				}
			}
			($BankConnections6[$memarr])=(/: +(.*\S) *$/) if (/^\s*Bank Connections: /i);
			$DMI6cnt=$memarr + 1;
		}

		# SMBIOS 2.1 added DMI Types 16 & 17, obsoleting Types 5 & 6
		# Check physical memory array
		if ($DMItype == 16) {
			($ECCBIOS)=(/: +(.*\S) *$/) if (/^\s*Error Correction Type: /i && ! $ECCBIOS);
			($MAXMEM)=(/: +(.*\S) *$/) if (/^\s*Maximum Capacity: /i && ! $MAXMEM);
			($NUMMOD)=(/: +(.*\S) *$/) if (/^\s*Number Of Devices: /i && ! $NUMMOD);
		}

		# Check each memory device
		if ($DMItype == 17) {
			if ($DMI6) {
				# Prefer DMI type 17 information over DMI type 6
				$memarr=-1 if (! $DMI17);
			}
			$DMI17=1;
			$memarr++ if (/^\s*Memory Device$/i);
			($FormFactor[$memarr])=(/: +(.*\S) *$/) if (/^\s*Form Factor: /i);
			($TotalWidth[$memarr])=(/: +(\d*) */) if (/^\s*Total Width: /i);
			($DataWidth[$memarr])=(/: +(\d*) */) if (/^\s*Data Width: /i);
			if (/^\s*Locator: /i) {
				($Locator17[$memarr])=(/: +(.*\S) *$/);
				$Locator17[$memarr]=~s/  */ /g;
				# Add CPU to X4170/X4270/X4275/X6270/X6275
				if ($systemmodel =~ /Sun .*X(4[12]7[05]|627[05])\b/i && $Locator17[$memarr] !~ /CPU/) {
					$cpu_number=$CPUSocketDesignation[$cpu_membank];
					$cpu_number=~s/\s*//g;
					$Locator17[$memarr]="${cpu_number}_$Locator17[$memarr]";
				}
			}
			($BankLocator[$memarr])=(/: +(.*\S) *$/) if (/^\s*Bank Locator: /i);
			($Type17[$memarr])=(/: +(.*\S) *$/) if (/^\s*Type: /i);
			($TypeDetail[$memarr])=(/: +(.*\S) *$/) if (/^\s*Type Detail: /i);
			($Size17[$memarr])=(/: +(.*\S) *$/) if (/^\s*Size: /i);

			($Speed17[$memarr])=(/: +(.*\S) *$/) if (/^\s*Speed: /i);
			($MemManufacturer[$memarr])=&get_mfg(/: +(.*\S) *$/) if (/^\s*Manufacturer: /i && $Size17[$memarr] =~ /( MB|GB)/);
			if (/^\s*Part Number: /i && ! /PartNum/i && ! /NOT AVAILABLE/i) {
				($MemPartNum[$memarr])=(/: +(.*\S) *$/);
				$MemPartNum[$memarr]=&hex2ascii($MemPartNum[$memarr]);
				# Hack: Ballistic modules may have mfg Undefined
				$MemManufacturer[$memarr]="Crucial Technology" if (! $MemManufacturer[$memarr] && $MemPartNum[$memarr] =~ /^BL/);
			}
		}
		$BrokenTable=&mychomp($_) if (/DMI table is broken/i);
		$FoundEnd=1 if (/End.Of.Table/i);
	}
	close(FILE);

	# Determine best manufacturer and model to display (or both) from
	# DMI type 1 (System) or DMI type 2 (Base Board)
	$baseboard="$boardmanufacturer $boardmodel" if ("$boardmanufacturer$boardmodel" ne "");
	$baseboard="" if ($boardmanufacturer eq $systemmanufacturer && ($boardmodel eq $systemmodel || $boardmodel eq ""));
	if ($systemmanufacturer) {
		$manufacturer=$systemmanufacturer;
	} else {
		$manufacturer=$boardmanufacturer;
		$baseboard="";
	}
	if ($systemmodel) {
		$model=$systemmodel;
	} else {
		$model=$boardmodel;
	}
	if ($manufacturer =~ /To Be Filled|System Manufacturer/i) {
		$manufacturer=$boardmanufacturer;
		$baseboard="";
	}
	if ($model =~ /To Be Filled|System .*Name|XXXX/i) {
		$model=$boardmodel;
		$baseboard="";
	}
	$baseboard="" if (&is_virtualmachine);

	# Check kernel to see how many processors it sees (for multi-core and
	# hyper-threaded CPUs)
	&check_cpuinfo;

	# Check Xen hardware for processors it sees (for multi-core and
	# hyper-threaded CPUs)
	&check_xm_info;

	# Check topology for manufacturer
	$manufacturer=$topology_mfg if ($topology_mfg);

	# Check Xenstore for manufacturer and model if not known
	if (&is_xen_vm && ! -f $filename && -x '/usr/bin/xenstore-ls' && -x '/usr/bin/xenstore-read') {
		$domid=&mychomp(`/usr/bin/xenstore-read domid 2>/dev/null`);
		if ($domid) {
			@xenstore=`/usr/bin/xenstore-ls /local/domain/$domid 2>/dev/null`;
			foreach (@xenstore) {
				if ($manufacturer eq "" && /\bsystem-manufacturer = */) {
					($manufacturer)=(/= *"(.*)"$/);
				}
				if ($model eq "" && /\bsystem-product-name = */) {
					($model)=(/= *"(.*)"$/);
				}
			}
		}
	}

	# hash CPUs
	$range=$ncpu;
	# Only display allocated CPUs on Virtual Machines
	$range=$cpuinfo_cpucnt if ($cpuinfo_cpucnt && &is_virtualmachine);
	for ($val=0; $val < $range; $val++) {
		$cputype="";
		$cpufreq="";
		if ($CPUVersion[$val]) {
			if ($CPUVersion[$val] eq "AMD" && $cpuinfo_cputype && ! &is_virtualmachine) {
				$cputype .= "$CPUManufacturer[$val] " if ($CPUManufacturer[$val] && $cpuinfo_cputype !~ /$CPUManufacturer[$val]/i);
				&pdebug("Adding AMD \$cpuinfo_cputype=$cpuinfo_cputype to cputype");
				$cputype .= "$cpuinfo_cputype ";
			} else {
				$cputype .= "$CPUManufacturer[$val] " if ($CPUManufacturer[$val] && $CPUVersion[$val] !~ /$CPUManufacturer[$val]/i);
				$CPUVersion[$val]=&cleanup_cputype($CPUVersion[$val]);
				&pdebug("Adding \$CPUVersion[$val]=$CPUVersion[$val] to cputype");
				$cputype .= "$CPUVersion[$val] ";
			}
		} elsif ($cpuinfo_cputype && ! &is_virtualmachine) {
			if ($CPUManufacturer[$val]) {
				$cputype .= "$CPUManufacturer[$val] " if ($cpuinfo_cputype !~ /$CPUManufacturer[$val]/i);
			}
			&pdebug("Adding \$cpuinfo_cputype=$cpuinfo_cputype to cputype");
			$cputype .= "$cpuinfo_cputype ";
		} else {
			$cputype .= "$CPUManufacturer[$val] " if ($CPUManufacturer[$val]);
			$cputype .= "$CPUFamily[$val] " if ($CPUFamily[$val]);
		}
		if (! $machine && $CPUFamily[$val]) {
			$machine="ia64" if ($CPUFamily[$val] eq "Itanium");
		}
		$cputype=~s/^\s+//;
		$cputype=~s/\s+$//;
		$cputype=~s/ +/ /g;
		if ($ncpu < $cpuinfo_cpucnt && $cpuinfo_cpucnt && $foundGenuineIntel) {
			# Distinguish Multi-Core from hyper-threading
			if ($cpuinfo_cpucores && $cpuinfo_physicalidcnt && $cpuinfo_cpucnt) {
				if ($cpuinfo_cpucnt / ($cpuinfo_cpucores * $cpuinfo_physicalidcnt) == 2) {
					$hyperthread=1;
					$ncpu=$cpuinfo_physicalidcnt;
					$range=$ncpu;	# Adjust the range of this "for" loop
					&pdebug("hyperthread=1: from cpuinfo physical id, ncpu=$ncpu, cpuinfo_cpucnt=$cpuinfo_cpucnt, cpuinfo_physicalidcnt=$cpuinfo_physicalidcnt, cpuinfo_cpucores=$cpuinfo_cpucores, cputype=$cputype");
				}
			} elsif ($cpuinfo_cpucores && $cpuinfo_coreidcnt > 1) {
				if ($cpuinfo_coreidcnt != $ncpu * $cpuinfo_cpucores) {
					if ($cpuinfo_cpucnt == $cpuinfo_coreidcnt && $cpuinfo_cpucores == 1 && $cpuinfo_cpucnt / $ncpu > 2) {
						$cpuinfo_cpucores=$cpuinfo_cpucnt / $ncpu;
					} else {
						$hyperthread=1;
						&pdebug("hyperthread=1: from cpuinfo, cputype=$cputype");
					}
				} elsif ($cpuinfo_siblings) {
					if ($cpuinfo_coreidcnt / ($ncpu * $cpuinfo_siblings) == 2) {
						$hyperthread=1;
						&pdebug("hyperthread=1: from cpuinfo siblings, ncpu=$ncpu, cpuinfo_cpucnt=$cpuinfo_cpucnt, cpuinfo_coreidcnt=$cpuinfo_coreidcnt, cpuinfo_siblings=$cpuinfo_siblings, cputype=$cputype");
					}
				}
			} elsif ($cpuinfo_siblings && ! ($cpuinfo_cpucores == 0 && $cputype =~ /Pentium.* 4\b/)) {
				if ($cpuinfo_cpucores == 0 && $cpuinfo_cpucnt / $cpuinfo_siblings == 2) {
					$hyperthread=1;
					if ($cpuinfo_physicalidcnt) {
						$ncpu=$cpuinfo_physicalidcnt;
						$cpuinfo_cpucores=$cpuinfo_cpucnt / $cpuinfo_physicalidcnt / 2;
						$range=$ncpu;	# Adjust the range of this "for" loop
						&pdebug("hyperthread=1: from cpuinfo physical id, ncpu=$ncpu, cpuinfo_cpucnt=$cpuinfo_cpucnt, cpuinfo_physicalidcnt=$cpuinfo_physicalidcnt, cpuinfo_siblings=$cpuinfo_siblings, cputype=$cputype");
					} else {
						&pdebug("hyperthread=1: from cpuinfo siblings, ncpu=$ncpu, cpuinfo_cpucnt=$cpuinfo_cpucnt, cpuinfo_physicalidcnt=$cpuinfo_physicalidcnt, cpuinfo_siblings=$cpuinfo_siblings, cputype=$cputype");
					}
				}
			} elsif ($cpuinfo_cpucores == 0 && $cputype =~ /Pentium.* 4\b/) {
				# Can't tell RHEL3 Hyper-Threaded Pentium 4
				# from Dual-Core Pentium D
				$hyperthread=1;
				&pdebug("hyperthread=1: hack in cpuinfo, cputype=$cputype");
			}
			if ($xen_cores_per_socket) {
				$cputype=&multicore_cputype($cputype,$xen_cores_per_socket);
			} elsif ($cpuinfo_cpucores) {
				$cputype=&multicore_cputype($cputype,$cpuinfo_cpucores);
			} elsif ($hyperthread && $cpuinfo_siblings) {
				$cputype=&multicore_cputype($cputype,$cpuinfo_physicalidcnt);
			} else {
				$cputype=&multicore_cputype($cputype,$cpuinfo_cpucnt / $ncpu);
			}
		}
		if ($CPUSpeed[$val]) {
			$cpufreq="$CPUSpeed[$val]";
			$cpufreq=~s/ *MHz$//;
			$CPUSpeed[$val]=~s/ *MHz$/MHz/;
		}
		&x86multicorecnt($cputype);
		$cpucnt{"$cputype $cpufreq"}++ if (! $xen_ncpu || $val < $xen_ncpu);
		$cpucntfrom="dmidecode" if ($cpucntfrom !~ /cpuinfo/ && $cpucntfrom ne "xm_info");
		$ExtSpeed[$val]=~s/ *MHz$/MHz/ if ($ExtSpeed[$val]);
	}
	@cputypecnt=keys(%cpucnt);
	$x=0;
	while (($cf,$cnt)=each(%cpucnt)) {
		$x++;
		$cf=~/^(.*) (\d*)$/;
		$ctype=$1;
		$cfreq=$2;
		if ($cpucntflag == 0 && $cpucntfrom !~ /cpuinfo/ && $cpucntfrom ne "xm_info") {
			for $tmp (2,3,4,6,8,10,12,16) {
				$cnt /= $tmp if ($corecnt == $tmp && $cnt % $tmp == 0);
			}
			$cpucntflag=1;
		}
		$ctype="" if ($ctype =~ /^\S*-Core $/);
		if ($ctype) {
			$ctype=&multicore_cputype($ctype,$corecnt) if (&is_xen_hv);
			$cpubanner .= "$cnt X " if ($cnt > 1);
			$cpubanner .= "$ctype";
			$cpubanner .= " ${cfreq}MHz" if ($cfreq && $ctype !~ /Hz$/);
			$cpubanner .= ", " if ($x < scalar(@cputypecnt));
		}
	}
	if (&is_virtualmachine && $cpubanner eq "") {
		$cpubanner .= "$cpuinfo_cpucnt X " if ($cpuinfo_cpucnt > 1);
		$_=$cpuinfo_cputype;
		($vcpu_type)=(/^(\w*)/);
		($vcpu_freq)=(/(\d[\d\.]*[GM]Hz)/);
		$cpubanner .= "$vcpu_type $vcpu_freq";
	}
	$machine="x86" if (! $machine);
	&x86_devname;

	#
	# Print information
	#
	&show_header;

	if (@topology_data) {
		print @topology_header;
		print @topology_data;
		$untested=0 if ($partition_cnt == 1 && $topology_mfg); # SGI UV
		$totmem=$installed_memory;
		&finish;
		&pdebug("exit");
		exit;
	}

	# CPU information
	if ($verbose) {
		print "WARNING: CPU Information Unknown\n" if ($cpuarr < 0 && $cpucntfrom !~ /cpuinfo/);
		$range=$cpuarr;
 		$range=$cpuinfo_cpucnt - 1 if ($cpucntfrom =~ /cpuinfo/ && ! $permission_error && &is_virtualmachine);
		# Second CPU doesn't exist on W1100z
		$range=0 if ($model =~ /W1100z\b/i);
		# Third & fourth CPUs don't exist on Ultra 40
		$range=1 if ($familypn eq "A71");
		for ($cnt=0; $cnt <= $range; $cnt++) {
			# Only display allocated CPUs on Virtual Machines
			next if ($CPUStatus[$cnt] && &is_virtualmachine && $CPUStatus[$cnt] =~ /(Unpopulated|Disabled By BIOS)/i);
			if ($CPUSocketDesignation[$cnt]) {
				print "$CPUSocketDesignation[$cnt]: ";
			} else {
				print "v" if (&is_virtualmachine);
				print "CPU $cnt: ";
			}
 			if ($cpucntfrom =~ /cpuinfo/ && &is_virtualmachine) {
				$_=$cpuinfo_cputype;
				($vcpu_type)=(/^(\w*)/);
				($vcpu_freq)=(/(\d[\d\.]*[GM]Hz)/);
				print "$vcpu_type $vcpu_freq cpu\n";
				next;
			}
			if ($CPUStatus[$cnt]) {
				if ($CPUStatus[$cnt] =~ /(Unpopulated|Disabled By BIOS)/i) {
					print "$CPUStatus[$cnt]\n";
					next;
				}
			}
			$ctype="";
			if ($CPUVersion[$cnt]) {
				$ctype .= "$CPUManufacturer[$cnt] " if ($CPUManufacturer[$cnt] && $CPUVersion[$cnt] !~ /$CPUManufacturer[$cnt]/i);
				$ctype .= "$CPUVersion[$cnt] ";
			} else {
				$ctype .= "$CPUManufacturer[$cnt] " if ($CPUManufacturer[$cnt]);
				$ctype .= "$CPUFamily[$cnt] " if ($CPUFamily[$cnt]);
			}
			$ctype=~s/ +/ /g;
			print "$ctype";
			if ($CPUSpeed[$cnt]) {
				print "$CPUSpeed[$cnt] " if ($ctype !~ /Hz $/);
			}
			print "cpu";
			print ", system freq: $ExtSpeed[$cnt]" if ($ExtSpeed[$cnt]);
			print "\n";
		}
	}
	if ($ncpu > 1 && $foundGenuineIntel && $cpucntfrom =~ /cpuinfo/ && ! $permission_error && ! &is_xen_vm) {
		print "WARNING: Cannot detect if Hyper-Threading is enabled, ";
		print "CPU count may be half of\n    what is shown if ";
		print "Hyper-Threading is enabled.\n";
	}

	# Memory information
	if ($permission_error) {
		print "ERROR: $permission_error\n";
		print "    This user does not have permission to run $config_command.\n";
		print "    Try running memconf as a privileged user like root.\n" if ($uid ne "0");
		&pdebug("exit 1");
		exit 1;
	}
	$max=0;
	if ($MAXMEM) {
		if ($MAXMEM =~ /\d+ MB/) {
			$max=$MAXMEM;
			$max=~s/ MB//g;
		} elsif ($MAXMEM =~ /\d+ GB/) {
			$max=$MAXMEM;
			$max=~s/ GB//g;
			$max *= 1024;
		} elsif ($MAXMEM =~ /\d+ TB/) {
			$max=$MAXMEM;
			$max=~s/ TB//g;
			$max *= $meg;
		}
	}
	$DMItypeshown=0;
	$memarr=3 if ($model =~ /W1100z\b/i);	# DIMM5-DIMM8 don't exist on W1100z
	for ($cnt=0; $cnt <= $memarr; $cnt++) {
		$buf="";
		# Prefer DMI type 17 information over DMI type 6
		$DMI=17;
		$DMI=6 if ($DMI6 && ! $DMI17);
		# Prefer DMI type 6 information if DMI type 6 reports different
		# total memory than DMI type 17 (BIOS bug)
		$DMI=6 if ($DMI6 && $DMI17 && $DMI6totmem > $DMI17totmem && &roundup_memory($freephys) == $DMI6totmem && ! &is_virtualmachine);
		&pdebug("using DMI type $DMI data for memory: DMI6totmem=$DMI6totmem, DMI17totmem=$DMI17totmem") if (! $DMItypeshown);
		$DMItypeshown=1;

		if ($DMI == 6) {
			next if (! $Size6[$cnt]);
			if ($Type6[$cnt]) {next if ($Type6[$cnt] =~ /Flash/i);}
			if (defined($Locator6[$cnt]) && defined($BankLocator[$cnt])) {
				$BankLocator[$cnt]="" if ($Locator6[$cnt] eq $BankLocator[$cnt]);
				if ($Locator6[$cnt] =~ /:/ && $BankLocator[$cnt] =~ /:/) {
					$Loc1=$Locator6[$cnt];
					$Loc1=~s/.*://;
					$Loc2=$BankLocator[$cnt];
					$Loc2=~s/.*://;
					$Locator6[$cnt]=~s/:.*// if ($Loc1 eq $Loc2);
				}
			}
			if ($#socketstr && ! $have_decodedimms_data) {
				$socketlabelarr[$cnt]="$socketstr[$cnt]";
			} else {
				$socketlabelarr[$cnt]=$Locator6[$cnt];
			}
			if ($Size6[$cnt] =~ /Not Installed|No Module Installed|^0 *MB.*/i) {
				&add_to_sockets_empty($socketlabelarr[$cnt]);
			} else {
				$buf="$socketlabelarr[$cnt]";
				$simmsize=$Size6[$cnt];
				$simmsize=~s/ *MB.*//ig;
				$sizearr[$cnt]=$simmsize;
				$Size6[$cnt]=~s/MByte/ MB/ig;
				$Size6[$cnt]=~s/ +MB/MB/g;
				if (defined($BankConnections6[$cnt])) {
					if ($Locator6[$cnt] =~ /BANK *\d/i && $BankConnections6[$cnt] =~ / /) {
						$tmp=$simmsize / 2;
						$buf .= ": 2 X ${tmp}MB";
					} else {
						$buf .= ": $Size6[$cnt]";
					}
				} else {
					$buf .= ": $Size6[$cnt]";
				}
				$buf .= " $SizeDetail[$cnt]" if ($SizeDetail[$cnt]);
				if ($Speed6[$cnt]) {
					$Speed6[$cnt]=~s/ +MHz/MHz/;
					$Speed6[$cnt]=~s/ +ns/ns/;
					$buf .= " $Speed6[$cnt]";
					&check_mixedspeeds($Speed6[$cnt]);
				} elsif ($Speed17[$cnt]) {
					$Speed17[$cnt]=~s/ +MHz/MHz/;
					$Speed17[$cnt]=~s/ +ns/ns/;
					$buf .= " $Speed17[$cnt]";
					&check_mixedspeeds($Speed17[$cnt]);
				}
				if ($TypeDetail[$cnt]) {
					$buf .= " $TypeDetail[$cnt]" if ($TypeDetail[$cnt] !~ /None/i);
				}
				if ($FormFactor[$cnt] && defined($Type17[$cnt])) {
					$buf .= " $Type17[$cnt]";
					$buf .= " $FormFactor[$cnt]" if ($Type17[$cnt] !~ /$FormFactor[$cnt]/);
				} elsif ($Type6[$cnt]) {
					$buf .= " $Type6[$cnt]";
				}
				if ($MemManufacturer[$cnt]) {
					$buf .= ", $MemManufacturer[$cnt]" if ($MemManufacturer[$cnt] !~ /None/i);
					if ($MemPartNum[$cnt]) {
						$buf .= " $MemPartNum[$cnt]" if ($MemPartNum[$cnt] !~ /None/i);
					}
				} elsif ($MemPartNum[$cnt]) {
					$buf .= ", $MemPartNum[$cnt]" if ($MemPartNum[$cnt] !~ /None/i);
				}
			}
			$totmem=$DMI6totmem;
		} else {
			next if (! $Size17[$cnt]);
			if ($Type17[$cnt]) {next if ($Type17[$cnt] =~ /Flash/i);}
			if (defined($Locator17[$cnt]) && defined($BankLocator[$cnt])) {
				$BankLocator[$cnt]="" if ($Locator17[$cnt] eq $BankLocator[$cnt]);
				if ($Locator17[$cnt] =~ /:/ && $BankLocator[$cnt] =~ /:/) {
					$Loc1=$Locator17[$cnt];
					$Loc1=~s/.*://;
					$Loc2=$BankLocator[$cnt];
					$Loc2=~s/.*://;
					$Locator17[$cnt]=~s/:.*// if ($Loc1 eq $Loc2);
				}
			}
			if ($BankLocator[$cnt]) {
				$bank_label="$BankLocator[$cnt]";
				# Don't include bank label if memory label also
				# includes the CPU
				$bank_label="" if ($Locator17[$cnt] =~ /CPU/ && $BankLocator[$cnt] =~ /\/P\d+$/);
			}
			if ($#socketstr && ! $have_decodedimms_data) {
				$socketlabelarr[$cnt]="$socketstr[$cnt]";
			} else {
				$socketlabelarr[$cnt]=$Locator17[$cnt];
				$socketlabelarr[$cnt] .= " $bank_label" if ($bank_label);
			}
			if ($Size17[$cnt] =~ /Not Installed|No Module Installed|^0 *MB.*/i) {
				&add_to_sockets_empty($socketlabelarr[$cnt]);
			} else {
				$buf="$socketlabelarr[$cnt]";
				$simmsize=$Size17[$cnt];
				if ($simmsize =~ / *GB.*/i) {
					$simmsize=~s/ *GB.*//ig;
					$simmsize *= 1024;
				} else {
					$simmsize=~s/ *MB.*//ig;
				}
				$sizearr[$cnt]=$simmsize;
				$Size17[$cnt]=~s/MByte/ MB/ig;
				$Size17[$cnt]=~s/ +MB/MB/g;
				$buf .= ": $Size17[$cnt]";
				$buf .= " $SizeDetail[$cnt]" if ($SizeDetail[$cnt]);
				if ($Speed17[$cnt]) {
					$Speed17[$cnt]=~s/ +MHz/MHz/;
					$Speed17[$cnt]=~s/ +ns/ns/;
					$buf .= " $Speed17[$cnt]";
					&check_mixedspeeds($Speed17[$cnt]);
				} elsif ($Speed6[$cnt]) {
					$Speed6[$cnt]=~s/ +MHz/MHz/;
					$Speed6[$cnt]=~s/ +ns/ns/;
					$buf .= " $Speed6[$cnt]";
					&check_mixedspeeds($Speed6[$cnt]);
				}
				if ($TypeDetail[$cnt]) {
					$buf .= " $TypeDetail[$cnt]" if ($TypeDetail[$cnt] !~ /None/i);
				}
				$buf .= " $Type17[$cnt]" if ($Type17[$cnt]);
				if ($FormFactor[$cnt]) {
					if ($Type17[$cnt]) {
						$buf .= " $FormFactor[$cnt]" if ($Type17[$cnt] !~ /$FormFactor[$cnt]/);
					} else {
						$buf .= " $FormFactor[$cnt]";
					}
				}
				if ($TotalWidth[$cnt] && $DataWidth[$cnt]) {
					$ECCDIMM=1 if ($TotalWidth[$cnt] > $DataWidth[$cnt]);
				}
				if ($MemManufacturer[$cnt]) {
					$buf .= ", $MemManufacturer[$cnt]" if ($MemManufacturer[$cnt] !~ /None/i);
					if ($MemPartNum[$cnt]) {
						# Don't repeat MFG if it is in Partnumber
						$MemPartNum[$cnt]=~s/$MemManufacturer[$cnt] //;
						$buf .= " $MemPartNum[$cnt]" if ($MemPartNum[$cnt] !~ /None/i);
					}
				} elsif ($MemPartNum[$cnt]) {
					$buf .= ", $MemPartNum[$cnt]" if ($MemPartNum[$cnt] !~ /None/i);
				}
			}
			$totmem=$DMI17totmem;
		}
		push(@boards_mem, "$buf\n") if ($buf);
	}

	# Check memory SPD data from EEPROM if available, it can be more
	# accurate and detailed than the dmidecode data
	&check_decodedimms;

	&pdebug("displaying memory from $memfrom") if ($memfrom);
	if (! &is_virtualmachine) {
		# Only show ECC enabled in BIOS if ECC memory is installed
		if ($ECCBIOS) {
			$ECCBIOS="None" if (! $ECCDIMM);
			print "Memory Error Correction: $ECCBIOS\n";
		}
		print "Maximum Memory: ";
		if (! $MAXMEM || $max < $totmem || $max == 0) {
			$MAXMEM="Unknown";
			$MAXMEM .= " (DMI incorrectly reports ${max}MB)" if ($max < $totmem && $max);
			print "$MAXMEM\n";
		} else {
			&show_memory($max);
		}
		print "Maximum Memory Bus Speed: $maxmembusspeed\n" if ($maxmembusspeed);
		print @boards_mem if (@boards_mem);
	}

	#
	# Print total memory
	#
	$sockettype="sockets";
	$sockettype="banks" if ($sockets_empty =~ /BANK *\d/i && $sockets_empty !~ /DIMM/);
	if ($memarr < 0 || $totmem == 0) {
		if (&is_virtualmachine) {
			if ($totmem) {
				print "total memory = ";
				&show_memory($totmem);
			} else {
				$exitstatus=1;
			}
			&check_virtualmachine;
		} else {
			&print_empty_memory("memory $sockettype") if ($sockets_empty);
			print "ERROR: Memory Information Unknown\n";
			if ((! $FoundEnd || $BrokenTable ne "") && $dmidecode_ver) {
				print "WARNING: dmidecode output is truncated\n" if (! $FoundEnd);
				if ($BrokenTable ne "") {
					print "ERROR: $BrokenTable\n";
					print "    Your BIOS may be corrupted or have an invalid checksum.\n";
				}
			}
			&print_bios_error;
			$exitstatus=1;
		}
	} else {
		&print_empty_memory("memory $sockettype");
		print "total memory = ";
		&show_memory($totmem);
	}
	if ($ECCBIOS) {
		if ($ECCBIOS eq "None" && $ECCDIMM) {
			print "WARNING: ECC memory detected, but ECC is not enabled in the BIOS.\n";
			$exitstatus=1;
		}
	}
	print "WARNING: Mixed speeds of memory modules found.\n" if ($mixedspeeds);
	print "ERROR: $dmidecode_error\n" if ($dmidecode_error);
	if ($freephys > $totmem && $totmem && ! &is_virtualmachine) {
		print "ERROR: Total physical memory (${freephys}MB) is ";
		print "greater than the total memory found.\n    The total ";
		print "physical memory reported by 'free -m' does not match ";
		print "the\n    memory reported by 'dmidecode'.\n";
		&print_bios_error;
	}
	# See if half of the memory is unused due to missing a second CPU
	if ($totmem && $totmem == &roundup_memory($freephys) * 2 && $ncpu == 1 && $necpu == 1) {
		print "WARNING: Half of the installed memory is not being ";
		print "used due to only having a\n         single CPU ";
		print "installed in this dual-CPU capable system.\n";
	}
	if ($os =~ /Linux|FreeBSD/ && &roundup_memory($freephys) < $totmem && $totmem > 4096) {
		$tmp=0;
		@tmp=("");
		if (-r '/var/log/dmesg' && ! $filename) {
			open(FILE, "</var/log/dmesg");
			@tmp=<FILE>;
			close(FILE);
		} elsif ($filename) {
			@tmp=@config;
		}
		foreach $line (@tmp) {
			if ($line =~ /Warning only \d.*B will be used/) {
				$line=~s/Warning o/WARNING: O/;
				print $line;
				$tmp=1;
			}
			if ($line =~ /Use a PAE enabled kernel/) {
				print "WARNING: " . $line;
				if (-r '/etc/grub.conf' && $osrel) {
					$tmp=`grep ${osrel}PAE /etc/grub.conf`;
					$tmp=($tmp) ? 2 : 1;
				} else {
					$tmp=1;
				}
			}
		}
		if ($tmp) {
			print "WARNING: Total memory available to the OS is ";
			print "less than the total memory found.\n";
			$recognized=0;
			$exitstatus=1;
		}
		if ($tmp >=1 && $osrel) {
			$osrelk=$osrel;
			$osrelk=~s/smp//;
			$osrelk=~s/hugemem//;
			if ($tmp == 1) {
				if ($osrel =~ /smp$/) {
					if (`grep ${osrelk}hugemem /etc/grub.conf 2>/dev/null`) {
						print "WARNING: Boot the ${osrelk}hugemem kernel to use the full memory.\n";
					} else {
						print "WARNING: Using a 'hugemem' kernel may fix this issue (supports up to 64GB).\n";
					}
				} elsif ($osrel =~ /hugemem$/) {
					print "WARNING: An upgraded BIOS may fix this issue.\n";
					print "WARNING: This is not a bug in memconf.\n";
				} else {
					if ($totmem < 16384) {
						if (`grep ${osrelk}smp /etc/grub.conf 2>/dev/null`) {
							print "WARNING: Boot the ${osrelk}smp kernel to use the full memory.\n";
						} elsif (`grep ${osrelk}hugemem /etc/grub.conf 2>/dev/null`) {
							print "WARNING: Boot the ${osrelk}hugemem kernel to use the full memory.\n";
						} else {
							print "WARNING: Using an 'smp' or 'hugemem' kernel may fix this issue ('smp' supports\n";
							print "         up to 16GB, 'hugemem' supports up to 64GB).\n";
						}
					} else {
						if (`grep ${osrelk}hugemem /etc/grub.conf 2>/dev/null`) {
							print "WARNING: Boot the ${osrelk}hugemem kernel to use the full memory.\n";
						} else {
							print "WARNING: Using a 'hugemem' kernel may fix this issue (supports up to 64GB).\n";
						}
					}
				}
			}
			if ($tmp == 2) {
				print "WARNING: Boot the ${osrelk}PAE kernel ";
				print "to use the full memory.\n";
			}
		} elsif ($tmp == 1) {
			if ($totmem < 16384) {
				print "WARNING: Using an 'smp' or 'hugemem' kernel may fix this issue ('smp' supports\n";
				print "         up to 16GB, 'hugemem' supports up to 64GB).\n";
			} else {
				print "WARNING: Using a 'hugemem' kernel may fix this issue (supports up to 64GB).\n";
			}
		}
	}
	# Flag untested CPU types (machine="" or "x86" on regression test files)
	# Tested so far on x86, i86pc, x86_64, Itanium ia64, and amd64
	if (! $machine || $machine eq "x86" || $machine =~ /i.86/ || $machine eq "x86_64" || $machine eq "ia64" || $machine eq "amd64") {
		$untested=0 if ($untested == 1);
	# Linux on SPARC with dmidecode
#	} elsif ($machine eq "sparc64" || $machine eq "sun4u") {
#		$untested=0 if ($untested == 1);
	} else {
		$untested=1;
		$untested_type="CPU" if (! $untested_type);
	}
	&check_virtualmachine;
	&show_untested if ($untested);
	&show_errors;
	&mailmaintainer if ($verbose == 3);
	&pdebug("exit $exitstatus");
	exit $exitstatus;
}

sub show_total_memory {
	return if ($totalmemshown || ! $totmem);
	$totalmemshown=1;
	#
	# Print total memory
	#
	print "total memory = ";
	&show_memory($totmem);
	print "$permission_error\n" if ($permission_error && ! $HPUX);
	if ($prtconf_warn) {
		print "WARNING: $prtconf_warn\n";
		print "         This may be corrected by installing ";
		print "a Sun patch on this system.\n";
	}
}

sub show_control_LDOM_message {
	return if ($controlLDOMshown);
	$controlLDOMshown=1;
	#
	# Post notice if on control LDOM
	#
	print "NOTICE: Control Logical Domain (LDOM) detected.  ";
	$picl_bank_cnt=scalar(keys %picl_mem_bank);
	if ($picl_foundmemory || $picl_bank_cnt) {
		print "The cpus and memory modules\n";
		print "    reported are for the system, not necessarily the control LDOM.\n";
	} else {
		print "The SUNWldm software package\n";
		print "    may need updated for prtpicl to be able to report the installed cpus and\n";
		print "    memory for the system.\n";
	}
}

sub is_virtualmachine {
	if ($uid ne "0") {
		# In case non-root user is running memconf
		$tmp=($os =~ /Linux|FreeBSD/ && ! $filename) ? `lspci 2>/dev/null | egrep -i '(VMware|VirtualBox|VirtualPC)'` : "";
		# Include special case for regression testing VM files
		if ((! $filename && $tmp =~ /VMware/i) || $filename =~ /VMware/i) {
			$manufacturer="VMware, Inc." if (! $manufacturer);
			$model="VMware Virtual Platform" if (! $model);
			return(1);
		} elsif ((! $filename && $tmp =~ /VirtualBox|VBox/i) || $filename =~ /VirtualBox/i) {
			$manufacturer="Oracle Corporation" if (! $manufacturer);
			$model="VirtualBox" if (! $model);
			return(1);
		} elsif ((! $filename && $tmp =~ /VirtualPC/i) || $filename =~ /VirtualPC/i) {
			$manufacturer="Microsoft Corporation" if (! $manufacturer);
			$model="Virtual Machine" if (! $model);
			return(1);
		}
	}
	return(1) if ($manufacturer =~ /VMware/ || $model =~ /VMware|Virtual Platform|Virtual Machine|VirtualBox|VBox/ || $diagbanner =~ /Virtual Machine/);
	return(1) if (&is_xen_vm);
	return(0);
}

sub is_xen_hv {
	return(1) if (-d '/proc/xen' && -f '/proc/xen/xsd_port'); # Linux Hypervisor
	# Special case for regression testing Xen files
	return(1) if ($filename =~ /Xen_dom0/i);
}

sub is_xen_vm {
	return(1) if (-d '/proc/xen' && ! -f '/proc/xen/xsd_port'); # Linux
	return(1) if ($model =~ /HVM domU/); # Linux
	return(1) if ($model eq "i86xpv" || $machine eq "i86xpv" || $model eq "i86xen" || $machine eq "i86xen"); # Solaris
	# Special case for regression testing Xen files
	return(1) if ($filename =~ /Xen_domU/i);
}

sub check_virtualmachine {
	return if ($vmshown);
	$vmshown=1;
	if (&is_virtualmachine) {
		if (&is_xen_vm) {
			$vmh="Xen dom0 hypervisor";
			$vms="Xen server";
			$vmg="Xen domU guest";
		} else {
			$vmh="VM hypervisor";
			$vms="VM server";
			$vmg="Virtual Machine (VM)";
		}
		print "NOTICE: Details shown may be for the configuration of this $vmg,\n        not the physical CPUs and memory of the $vms it is running on.\n";
		print "WARNING: More details can be reported if memconf is run on the $vmh.\n";
		print "        $vms CPU: $cpuinfo_cputype\n" if ($cpuinfo_cputype);
	}
}

sub check_xm_info {
	if ($have_xm_info_data) {
		&pdebug("in check_xm_info");
		foreach $line (@xm_info) {
			$line=&dos2unix($line);
			$_=$line;
			($xen_nr_nodes)=(/: (\d*) */) if (/^nr_nodes\s*: \d+/);
			($xen_sockets_per_node)=(/: (\d*) */) if (/^sockets_per_node\s*: \d+/);
			($xen_cores_per_socket)=(/: (\d*) */) if (/^cores_per_socket\s*: \d+/);
			$hyperthread=1 if (/^threads_per_core\s*: 2/);
		}
		$xen_ncpu=$xen_nr_nodes * $xen_sockets_per_node;
		&pdebug("xen_ncpu=$xen_ncpu, ncpu=$ncpu, xen_nr_nodes=$xen_nr_nodes, xen_sockets_per_node=$xen_sockets_per_node, xen_cores_per_socket=$xen_cores_per_socket, hyperthread=$hyperthread");
		if ($xen_ncpu) {
			$cpucntfrom="xm_info";
			$corecnt=$xen_cores_per_socket;
			$nvcpu=$xen_cores_per_socket;
			$nvcpu=$nvcpu * 2 if ($hyperthread);
		}
	}
}
sub check_cpuinfo {
	if ($have_cpuinfo_data) {
		return if ($cpuinfo_checked);
		&pdebug("in check_cpuinfo");
		$cpuinfo_checked=1;
		foreach $line (@cpuinfo) {
			$line=&dos2unix($line);
			$_=$line;
			$cpuinfo_cpucnt++ if (/^processor\s*: \d+/);
			$cpuinfo_coreidcnt++ if (/^core id\s*: \d+/);
			if (/^physical id\s*: \d+/) {
				($physicalid)=(/: (\d*) */);
				$cpuinfo_physicalid{$physicalid}++;
			}
			($cpuinfo_cpucores)=(/: (\d*) */) if (/^cpu cores\s*: \d+/);
			($cpuinfo_siblings)=(/: (\d*) */) if (/^siblings\s*: \d+/);
			# Only GenuineIntel x86 has hyper-threading capability
			$foundGenuineIntel=1 if (/^vendor_id\s*: GenuineIntel/);
			# Linux on x86 or ARM CPU model
			if (/^model name\s*: /) {
				($cpuinfo_cputype)=(/: (.*)$/);
				$cpuinfo_cputype=&cleanup_cputype($cpuinfo_cputype);
				if (/.*(ARM|Feroceon|Marvell)/) {
					if ($filename) {
						# Special case for regression testing
						$machine="arm";
						$platform=$machine;
						$os="Linux";
					}
					$cpucnt{"$cpuinfo_cputype"}=$corecnt;
				}
			}
			# Linux on SPARC CPU model
			if (/^cpu\s+: \D/) {
				($cpuinfo_cputype)=(/: (.*)$/);
				$cpuinfo_cputype=&cleanup_cputype($cpuinfo_cputype);
				$machine="sparc" if ($cpuinfo_cputype =~ /sparc/i);
				$os="Linux";
			}
			# Linux on SPARC OBP version
			if (/^prom\s+: /) {
				($romver)=(/: (.*)$/);
				@romverarr=split(/\s/, $romver);
				$romvernum=$romverarr[1];
			}
			# Linux on SPARC CPU type
			($machine)=(/: (.*)$/) if (/^type\s+: sun/);
			# Linux on SPARC
			if (/^ncpus active\s*: \d+/) {
				($cpuinfo_cpucnt)=(/: (.*)$/);
				# Assume single core
				$cpuinfo_cpucores=1;
			}
			# Linux on SPARC CPU freq
			if (/^Cpu\dClkTck\s*: \d+/ && $cpufreq == 0) {
				($freq)=(/: (.*)$/);
				$cpufreq=&convert_freq($freq);
				$cpuinfo_cputype.= " ${cpufreq}MHz" if ($cpuinfo_cputype !~ /MHz/ && $cpufreq);
			}
			# Linux on unsupported CPU models (arm, mips, etc.)
			if (($machine !~ /.86|ia64|amd64|sparc/ && ! $filename) || $filename) {
				if (/^Processor\s+: /) {
					($cpuinfo_cputype)=(/: (.*)$/);
					if ($filename && /^Processor\s+: .*(ARM|Feroceon|Marvell)/) {
						# Special case for regression testing
						$machine="arm";
						$platform=$machine;
					}
					$os="Linux";
					$cpucnt{"$cpuinfo_cputype"}=$corecnt;
				} elsif (/^cpu model\s+: /) {
					($cpuinfo_cputype)=(/: (.*)$/);
					if ($filename && /^cpu model\s+: .*MIPS/) {
						# Special case for regression testing
						$machine="mips";
						$platform=$machine;
					}
					$os="Linux";
					$cpucnt{"$cpuinfo_cputype"}=$corecnt;
				}
			}
			if ($filename) {
				($hostname)=(/: (.*)$/) if (/^host\s*: / && $hostname eq "");
				if (/^machine\s*: /) {
					($machine)=(/: (.*)$/);
					if (! defined($kernbit)) {
						$kernbit=32 if ($machine =~ /i.86|sparc/);
						$kernbit=64 if ($machine =~ /x86_64|sparc64|ia64|amd64/);
					}
				}
				if (/^release\s*: / && $release eq "") {
					($release)=(/: (.*)$/);
					$release="Linux $release";
				}
			}
		}
		$cpuinfo_physicalidcnt=keys %cpuinfo_physicalid;
		$cpuinfo_physicalidcnt=0 if (! defined($cpuinfo_physicalidcnt));
		if ($cpuinfo_cpucnt > $ncpu && (! $foundGenuineIntel || $foundGenuineIntel && ! $ncpu)) {
			# Prefer cpuinfo over dmidecode for CPU info
			$cpucntfrom=$config_command if (! $cpucntfrom);
			&pdebug("Preferring CPU count from cpuinfo ($cpuinfo_cpucnt) over $cpucntfrom ($ncpu)");
			if ($ncpu) {
				$cpucntfrom="dmidecode and cpuinfo";
			} else {
				$cpucntfrom="cpuinfo";
			}
			if ($cpuinfo_cpucores) {
				$ncpu=$cpuinfo_cpucnt / $cpuinfo_cpucores;
			} else {
				$ncpu=$cpuinfo_cpucnt;
			}
		}
		&pdebug("cpuinfo_cputype=$cpuinfo_cputype, ncpu=$ncpu, cpuinfo_cpucnt=$cpuinfo_cpucnt, cpuinfo_coreidcnt=$cpuinfo_coreidcnt, cpuinfo_cpucores=$cpuinfo_cpucores, cpuinfo_physicalidcnt=$cpuinfo_physicalidcnt, cpuinfo_siblings=$cpuinfo_siblings, foundGenuineIntel=$foundGenuineIntel");
	}
}

sub finish {
	&show_header;
	#print "newslots=@newslots\n" if ($#newslots && $verbose > 1);
	# Large memory system like SPARC T7-4 can mismatch memory in prtconf and ipmitool
	if ($isX86 || $ultra =~ /^T7-/) {
		# smbios and ipmitool memory data is more accurate than prtconf
		if ($smbios_memory && $smbios_memory > $installed_memory) {
			$installed_memory=$smbios_memory;
			$totmem=$installed_memory;
		} elsif ($ipmi_memory && $ipmi_memory > $installed_memory) {
			$installed_memory=$ipmi_memory;
			$totmem=$installed_memory;
		}
	}
	# Cannot accurately determine installed memory unless information is
	# is in prtpicl output, or if system is fully stuffed
	$picl_bank_cnt=scalar(keys %picl_mem_bank);
	if ($ldm_memory && ! ($picl_foundmemory || $picl_bank_cnt)) {
		$totmem=&roundup_memory($installed_memory);
		&show_total_memory;
		&show_control_LDOM_message;
		return;
	}
	print $buffer if ($buffer);
	#
	# Special memory options
	#
	if ($sxmem) {
		# Currently assumes only one VSIMM is installed.
		# Auxiliary Video Board 501-2020 (SS10SX) or 501-2488 (SS20)
		# required if two VSIMMs are installed.
		if ($model eq "SPARCstation-20" || $model eq "SuperCOMPstation-20S") {
			# SS20 1st VSIMM in J0304/J0407, 2nd in J0305/J0406
			print "sockets J0304/J0407 have";
			$sockets_used .= " J0304";
		} elsif ($model =~ /COMPstation-20A\b/) {
			# 1st VSIMM in J0202, 2nd in J0301
			print "socket J0202 has";
			$sockets_used .= " J0202";
		} else {
			# SS10SX 1st VSIMM in J0301/J1203, 2nd in J0202/J1201
			print "sockets J0301/J1203 have";
			$sockets_used .= " J0301";
		}
		print " a ${sxmem}MB VSIMM installed for SX (CG14) graphics\n";
	}
	if ($nvmem) {
		# NVSIMMs for Prestoserve
		if ($model eq "SPARCstation-20" || $model eq "SuperCOMPstation-20S") {
			# SS20 1st 2MB NVSIMM in J0305/J0406, 2nd in J0304/J0407
			if ($nvmem1) {
				$sockets_used .= " J0305";
				print "sockets J0305/J0406 have a 2MB NVSIMM";
				print " installed for Prestoserve\n";
			}
			if ($nvmem2) {
				$sockets_used .= " J0304";
				print "sockets J0304/J0407 have a 2MB NVSIMM";
				print " installed for Prestoserve\n";
			}
		} elsif ($model =~ /COMPstation-20A\b/) {
			# 1st 2MB NVSIMM in J0301, 2nd in J0202
			if ($nvmem1) {
				$sockets_used .= " J0301";
				print "socket J0301 has a 2MB NVSIMM";
				print " installed for Prestoserve\n";
			}
			if ($nvmem2) {
				$sockets_used .= " J0202";
				print "socket J0202 has a 2MB NVSIMM";
				print " installed for Prestoserve\n";
			}
		} elsif ($model =~ /SPARCstation-10/ || $model eq "Premier-24") {
			# SS10 1st 2MB NVSIMM in J0202/J1201, 2nd in J0301/J1203
			if ($nvmem1) {
				$sockets_used .= " J0202";
				print "sockets J0202/J1201 have a 2MB NVSIMM";
				print " installed for Prestoserve\n";
			}
			if ($nvmem2) {
				$sockets_used .= " J0301";
				print "sockets J0301/J1203 have a 2MB NVSIMM";
				print " installed for Prestoserve\n";
			}
		} else {
			# SS1000 supports two banks of four 1MB NVSIMMs
			# SC2000 supports one bank of eight 1MB NVSIMMs
			print "Has ${nvmem}MB of NVSIMM installed for Prestoserve ";
			if ($model eq "SPARCserver-1000") {
				print "(1 bank of 4" if ($nvmem == 4);
				print "(2 banks of 4" if ($nvmem == 8);
			} else {
				print "(1 bank of 8";
			}
			print " 1MB NVSIMMs$nvsimm_banks)\n";
		}
	}

	#
	# Check for empty banks or sockets
	#
	if ($#banksstr) {
		foreach $banks (@banksstr) {
			if ($banks ne "?") {
				if ($banks_used !~ /\b$banks\b/ &&
				    $sockets_empty !~ /\b$banks\b/) {
					&add_to_sockets_empty($banks);
				}
			}
		}
		&print_empty_memory($bankname);
	} elsif ($#socketstr) {
		foreach $socket (@socketstr) {
			if ($socket ne "?") {
				# strip leading slash for matching
				$tmp=$socket;
				$tmp=~s/^\///;
				if ($sockets_used !~ /$tmp/ &&
				    $sockets_empty !~ /$tmp/) {
					&add_to_sockets_empty($socket);
				}
			}
		}
		if ($sockettype) {
			&print_empty_memory("${sockettype}s");
		} else {
			&print_empty_memory("memory slots");
		}
	} elsif ($verbose > 1 && $sockets_used) {
		print "memory sockets used: $sockets_used\n";
	}
	# Look for duplicate sockets
	if ($sockets_used && $have_prtdiag_data) {
		$dup_sockets="";
		if ($sockets_used =~ /;/) {
			$sep=';';
		} elsif ($sockets_used =~ /,/) {
			$sep=',';
		} else {
			$sep=' ';
		}
		foreach $socket (sort split($sep, $sockets_used)) {
			next if ($socket eq "board" || $socket eq "mezzanine");
			next if ($model eq "SPARCsystem-600" || $model =~ /Sun.4.600/);
			$pos=-1;
			$cnt=0;
			while (($pos=index(" $sockets_used ", " $socket ", $pos)) > -1) {
				$pos++;
				$cnt++;
				if ($cnt == 2 && $socket ne "-" && $socket ne "?") {
					# strip leading slash for matching
					$tmp=$socket;
					$tmp=~s/^\///;
					if ($dup_sockets !~ /$tmp/) {
						$dup_sockets .= " $socket";
						print "ERROR: Duplicate socket $socket found\n";
						$exitstatus=1;
					}
				}
			}
		}
		if ($dup_sockets) {
			print "WARNING: Memory was not properly reported by";
			print " the 'prtdiag' command.\n";
			&recommend_prtdiag_patch;
		}
	}
	# Look for unlabeled sockets
	if ($sockets_used =~ /\s-\s|^-\s|\s-$|^-$/) {
		print "WARNING: Unlabeled socket found";
		print " in the 'prtdiag' command output" if ($have_prtdiag_data);
		print ".\n         This may cause the reported empty sockets";
		print " to be incorrect.\n";
		&recommend_prtdiag_patch;
	}
	# Make sure Sun Fire V480/V490/V880/V890 is fully stuffed if >= 1050MHz
	if ($ultra =~ /Sun Fire V[48][89]0\b/) {
		print "ERROR: System should not have any empty banks since CPU is >= 1050MHz.\n" if ($cpufreq >= 1050 && $banks_used ne "A0 A1 B0 B1");
	}

	if ($machine eq "sun4v") {
		# Round up Solaris memory (may have 128MB or more reserved)
		$installed_memory=&roundup_memory($installed_memory);
		$totmem=$installed_memory;
	}

	#
	# Print total memory
	#
	&show_total_memory;

	#
	# Post notice if on control LDOM
	#
	&show_control_LDOM_message if ($ldm_memory);

	#
	# Post notice if on a virtual machine
	#
	&check_virtualmachine;

	#
	# Post notice if X86 machine is Hyper-Thread capable, but not enabled
	#
	&show_hyperthreadcapable;

	#
	# Check for illegal memory stuffings
	#
	if ($model eq "Sun 4/50" || $model eq "Sun 4/25") {	# IPX, ELC
		if ($slot0 != 16 && $largestsimm == 16 && $osrel =~ /4.1.1/) {
			print "ERROR: Install the highest capacity 16MB SIMM";
			print " in socket $socketstr[0] under SunOS 4.1.1.\n";
			$exitstatus=1;
		}
	}
	if ($model =~ /SPARCclassic|SPARCstation-LX/) {
		if ($found32mb) {
			# Reportedly can accept 32MB SIMMs in bank 1, allowing
			# 128MB total (2x32, 4x16)
			print "NOTICE: The 32MB SIMM is not supported in the";
			print " $model according to\n    Sun. However it does";
			print " appear to work in bank 1 only, allowing a";
			print " maximum of\n    128MB of total memory (2x32MB";
			print " bank 1 + 4x16MB banks 2 & 3).\n";
		}
		if ($found8mb) {
			# Possibly can accept 8MB SIMMs in bank 1
			print "NOTICE: The 8MB SIMM is not supported in the";
			print " $model according to\n    Sun. However it does";
			print " appear to work in bank 1 only.\n";
		}
	}
	if ($model =~ /SPARCstation-10/ || $model eq "Premier-24") {
		if ($slot0 < $largestsimm && $BSD) {
			print "ERROR: Install the highest capacity SIMM in";
			print " socket $socketstr[0] under Solaris 1.X.\n";
			$exitstatus=1;
		}
		if (! $found32mb && $found16mb && ($romvermajor eq 2) && ($romverminor < 19)) {
			print "WARNING: The 32MB SIMM is not supported in the";
			print " SS10 or SS10SX according to\n    Sun. However";
			print " it does work correctly depending on the Open";
			print " Boot PROM\n    version. This system is running";
			print " OBP $romvernum, so 32MB SIMMs will only be\n";
			print "    recognized as 16MB SIMMs. You should";
			print " upgrade to OBP 2.19 or later in order\n    to";
			print " be able to detect and utilize 32MB SIMMs.\n";
			# OBP 2.14 and earlier see the 32MB SIMM as 16MB.
			# OBP 2.15 on a SS20 does see the 32MB SIMM as 32MB.
			# Have not tested 32MB SIMMs on SS10 with OBP 2.15-2.18
			if ($romverminor > 14) {
				$untested=1;
				$untested_type="OBP";
			}
		}
		if ($found32mb && ($romvermajor eq 2) && ($romverminor < 19)) {
			print "NOTICE: The 32MB SIMM is not supported in the";
			print " SS10 or SS10SX according to\n    Sun. However";
			print " it does work correctly depending on the Open";
			print " Boot PROM\n    version. This system is running";
			print " OBP $romvernum, and 32MB SIMMs were properly\n";
			print "    recognized.\n";
			@simmsizes=(16,32,64);
			if ($romvernum ne "2.X") {
				$untested=1;
				$untested_type="OBP";
			}
		}
		if (! $nvmem1 && $nvmem2) {
			print "ERROR: First NVSIMM should be installed in";
			print " socket J0202, not socket J0301\n";
			$exitstatus=1;
		}
	}
	if ($model eq "SPARCstation-20" || $model eq "SuperCOMPstation-20S") {
		if (! $nvmem1 && $nvmem2) {
			print "ERROR: First NVSIMM should be installed in";
			print " socket J0305, not socket J0304\n";
			$exitstatus=1;
		}
	}
	if ($model eq "SPARCstation-5") {
		if ($slot0 < $largestsimm && $BSD) {
			print "ERROR: Install the highest capacity SIMM in";
			print " socket $socketstr[0] under Solaris 1.X.\n";
			$exitstatus=1;
		}
		if ($osrel eq "4.1.3_U1" && $found32mb) {
			# Look to see if patch 101508-07 or later is installed
			# for 32MB SIMMs to work properly (bug 1176458)
			$what=&mychomp(`/usr/ucb/what /sys/sun4m/OBJ/module_vik.o`);
			if ($what !~ /module_vik.c 1.38 94\/08\/22 SMI/) {
				print "WARNING: Install SunOS 4.1.3_U1 patch";
				print " 101508-07 or later in order for 32MB\n";
				print "    SIMMs to work reliably on the";
				print " SPARCstation 5.\n";
			}
		}
	}
	if ($model eq "Ultra-5_10" || $ultra eq "5_10" || $ultra eq 5 || $ultra eq 10) {
		if ($smallestsimm == 16 && $largestsimm > 16) {
			print "ERROR: 16MB DIMMs cannot be mixed with larger";
			print " DIMMs on Ultra 5/10 systems.\n";
			$exitstatus=1;
		}
	}
	if ($ultra eq 5) {
		if ($largestsimm == 256) {
			print "NOTICE: The 256MB DIMM is not supported in the";
			print " Ultra 5 according to\n    Sun. However it does";
			print " work correctly as long as you use low-profile";
			print "\n    DIMMs or take out the floppy drive.\n";
		}
	}
	if ($ultra eq "AXi") {
		# DIMMs should be chosen as all 10-bit or all 11-bit column
		# address type. If using 11-bit, then only use Bank 0 & 2.
		if ($found10bit && $found11bit) {
			print "ERROR: You should not mix 10-bit and 11-bit";
			print " column address type DIMMs in the\n    ";
			print "SPARCengine Ultra AXi.\n";
			$exitstatus=1;
		}
		if ($found11bit) {
			if ($foundbank1or3) {
				print "ERROR";
				$exitstatus=1;
			} else {
				print "WARNING";
			}
			print ": Do not use Bank 1 (sockets U0402 & U0401) &";
			print " Bank 3 (sockets U0302 &\n    U0301) since";
			print " 11-bit column address type DIMMs are";
			print " installed. You should\n    only use Bank 0";
			print " (sockets U0404 & U0403) & Bank 2 (sockets";
			print " U0304 & U0303).\n";
		}
	}
	if ($model eq "Ultra-4" || $ultra eq 450 || $model eq "Ultra-4FT" || $ultra eq "Netra ft1800") {
		if ($found16mb) {
			print "WARNING: 16MB DIMMs are not supported and may";
			print " cause correctable ECC errors.\n";
		}
	}

	#
	# Check for unsupported memory sizes
	#
	foreach $i (@simmsizesfound) {
		$smallestsimm=$i if ($i < $smallestsimm);
		$largestsimm=$i if ($i > $largestsimm);
		$simmsizelegal=0;
		foreach $j (@simmsizes) {
			$simmsizelegal=1 if ($i == $j);
		}
		if (! $simmsizelegal && $simmsizes[0]) {
			print "ERROR: Unsupported ${i}MB $memtype found (supported ";
			if ($#simmsizes == 0) {
				print "size is @{simmsizes}MB)\n";
			} else {
				print "MB sizes are: @simmsizes)\n";
			}
			$exitstatus=1;
		}
	}
	if ($smallestsimm < $simmsizes[0]) {
		print "ERROR: Smaller than expected $memtype found ";
		print "(found ${smallestsimm}MB, smallest expected ";
		print "${simmsizes[0]}MB)\n";
		$exitstatus=1;
	}
	if ($largestsimm > $simmsizes[$#simmsizes]) {
		print "ERROR: Larger than expected $memtype found ";
		print "(found ${largestsimm}MB, largest expected ";
		print "${simmsizes[$#simmsizes]}MB)\n";
		$exitstatus=1;
	}

	#
	# Check for buggy perl version
	#
	if ($perlhexbug) {
		print "ERROR: This Perl V$PERL_VERSION is buggy in hex number";
		print " conversions.\n";
		$exitstatus=1;
	}
	if ($PERL_VERSION == 5.001) {
		print "WARNING: Perl V5.001 is known to be buggy in hex number";
		print " conversions.\n";
	}
	if ($PERL_VERSION < 5.002) {
		print "WARNING: Perl V5.002 or later is recommended for best";
		print " results.\n";
		print "         You are running Perl V$PERL_VERSION\n";
	}

	#
	# Check for bad eeprom banner-name. This happens sometimes when OBP 3.23
	# or later is installed on Ultra-60/E220R and Ultra-80/E420R systems.
	#
	if ($banner =~ /^ \(/) {
		print "ERROR: banner-name not set in EEPROM (BugID 4257412).";
		print " Cannot distinguish an\n       ";
		print "Ultra 60 from an Enterprise 220R" if ($model eq "Ultra-60");
		print "Ultra 80 from an Enterprise 420R or Netra t 1400/1405" if ($model eq "Ultra-80");
		print "Sun Blade 1000/2000 from a Sun Fire 280R or Netra 20" if ($ultra eq "Sun Blade 1000" || $ultra eq "Sun Blade 2000" || $ultra eq "Sun Fire 280R" || $ultra eq "Netra 20");
		print ".\n       To correct this problem, please run one of ";
		print "the following commands as\n       root depending on ";
		print "the system you have:\n";
		if ($model eq "Ultra-60") {
			print "            eeprom banner-name='Sun Ultra 60 UPA/PCI'\n";
			print "            eeprom banner-name='Sun Enterprise 220R'\n";
			print "Note: Netra t1120/1125 systems may also use the 'Sun Ultra 60 UPA/PCI' banner\n";
		}
		if ($model eq "Ultra-80") {
			print "            eeprom banner-name='Sun Ultra 80 UPA/PCI'\n";
			print "            eeprom banner-name='Sun Enterprise 420R'\n";
			print "            eeprom banner-name='Netra t 1400/1405'\n";
			print "Note: Netra t1400/1405 systems may also use the 'Sun Ultra 80 UPA/PCI' banner\n";
		}
		if ($ultra eq "Sun Blade 1000" || $ultra eq "Sun Blade 2000" || $ultra eq "Sun Fire 280R" || $ultra eq "Netra 20") {
			print "            eeprom banner-name='Sun-Blade-1000'\n";
			print "            eeprom banner-name='Sun Fire 280R'\n";
			print "            eeprom banner-name='Netra 20'\n";
			print "Note: Netra 20 systems may also use the 'Sun-Blade-1000' banner\n";
		}
		$exitstatus=1;
	}

	#
	# Check for possible memory detection errors by this program
	#
	if ($prtdiag_failed == 2) {
		&found_nonglobal_zone;
		$prtdiag_has_mem=0;
	}
	# prtdiag only available on SunOS
	$prtdiag_has_mem=0 if ($os ne "SunOS");
	if (! $boardfound_mem && $prtdiag_has_mem) {
		print "WARNING: Memory should have been reported in the output from";
		if ($prtdiag_cmd) {
			print "\n       $prtdiag_cmd";
		} else {
			if (-d '/usr/platform') {
				print " prtdiag,\n       which was not found in /usr/platform/$machine/sbin";
			} else {
				print " prtdiag.";
			}
		}
		print "\nERROR: prtdiag failed!" if ($prtdiag_failed);
		print "\n       This system may be misconfigured, or may be";
		print " missing software packages\n       like SUNWpiclr,";
		print " SUNWpiclu and SUNWpiclx, or may need the latest\n";
		print "       recommended Sun patches installed from";
		print " http://sunsolve.sun.com/\n";
		if ($ultra eq "Sun Fire V880") {
			print "       This may be corrected by installing ";
			print "Sun patch 112186-19 or 119231-01 or later.\n";
		}
		print "       Check my website at $URL\n";
		print "       to get the latest version of memconf.\n";
		$exitstatus=1;
	}
	if ($recognized == 0) {
		print "ERROR: Layout of memory ${sockettype}s not completely ";
		print "recognized on this system.\n";
		$exitstatus=1;
	}
	if ($recognized < 0 && $os eq "SunOS") {
		if ($have_prtfru_details && $recognized == -3) {
			print "ERROR: Memory manufacturer not recognized.\n";
			print "       This is a bug in the Sun OBP or prtfru";
			print " command, not a bug in memconf.\n";
		} else {
			print "WARNING: Layout of memory ${sockettype}s not";
			print " completely recognized on this system.\n";
		}
		if ($model eq "Ultra-80" || $ultra eq 80 || $ultra eq "420R" || $ultra eq "Netra t140x") {
			if ($recognized == -1) {
				print "       The memory configuration displayed is a guess which may be incorrect.\n";
				if ($totmem eq 1024) {
					print "       The 1GB of memory installed may be 4 256MB DIMMs populating bank 0,\n";
					print "       or 16 64MB DIMMs populating all 4 banks.\n";
				}
			}
			print "       This is a known bug due to Sun's 'prtconf', 'prtdiag' and 'prtfru'\n";
			print "       commands not providing enough detail for the memory layout of this\n";
			print "       SunOS $osrel $platform system to be accurately determined.\n";
			print "       This is a bug in Sun's OBP, not a bug in memconf.  The latest OBP\n";
			print "       release (OBP 3.33.0 2003/10/07 from patch 109082-06) ";
			print (($totmem eq 1024) ? "still has this bug" : "should fix this");
			print ".\n       This system is using $romver\n";
			$exitstatus=1;
		}
		if ($ultra eq "Sun Blade 1000" || $ultra eq "Sun Blade 2000" || $ultra eq "Sun Fire 280R" || $ultra eq "Netra 20") {
			# Do this if memory was not in the output of prtdiag
			if ($recognized == -2) {
				# Hack: If Sun Blade 1000 has 8GB of memory (maximum
				# allowed), then memory line was rewritten to show
				# memory stuffing.
				print "       The memory configuration displayed should be";
				print " correct though since this\n";
				print "       is a fully stuffed system.\n";
			} else {
				print "       The memory configuration displayed is a guess which may be incorrect.\n";
			}
		}
		if ($ultra eq "T2000" || $ultra eq "T1000") {
			# Do this if memory was not in the output of prtdiag
			# Hack: If Sun Fire T2000 has 8GB or 16GB of memory or
			# if Sun Fire T1000 has 4GB or 8GB of memory, then it
			# may be 1 rank of DIMMs instead of default 2 ranks.
			print "       The memory configuration displayed is a guess which may be incorrect.\n";
			print "       Base Sun configurations ship with two ranks of modules installed.\n";
			print "       This system may have one rank of " . $simmsizesfound[0]*2 . "MB DIMMs installed instead\n";
			print "       of two ranks of " . $simmsizesfound[0] . "MB DIMMs as shown.\n";
			print "       This is a known bug due to Sun's 'prtconf', 'prtdiag' and 'prtfru'\n";
			print "       commands not providing enough detail for the memory layout of this\n";
			print "       SunOS $osrel $platform system to be accurately determined.\n";
			print "       This is a Sun bug, not a bug in memconf.\n";
			$exitstatus=1;
		}
	}
	if ($banner =~ /Netra t1\b/ || $ultra eq "Netra t1" || $model eq "Netra t1") {
		if ($totmem eq 1024) {
			print "WARNING: Cannot distinguish between four";
			print " 370-4155 256MB mezzanine boards and\n";
			print "         two 512MB mezzanine boards.\n";
		}
		if ($totmem eq 768) {
			print "WARNING: Cannot distinguish between three";
			print " 370-4155 256MB mezzanine boards and\n";
			print "         one 512MB and one 256MB mezzanine boards.\n";
		}
	}
	if ($installed_memory) {
		if ($installed_memory != $totmem) {
			print "ERROR: Total memory installed (${installed_memory}MB) ";
			print "does not match total memory found.\n";
			$recognized=0;
			$exitstatus=1;
		}
	}
	if ($failed_memory) {
		print "ERROR: Failed memory (${failed_memory}MB) was detected.\n";
		print "       You should consider replacing the failed memory.\n";
		$exitstatus=1;
	}
	if ($spare_memory) {
		print "NOTICE: Spare memory (${spare_memory}MB) was detected.\n";
		print "        You can configure the spare memory using the 'cfgadm' command.\n";
	}
	&show_errors;
	if ($failed_fru) {
		print "ERROR: $failed_fru";
		print "       You should consider replacing the failed FRUs.\n";
		$exitstatus=1;
	}
	&show_unrecognized if ($recognized == 0);
	if (! &is_virtualmachine) {
		if ($smbios_memory && &roundup_memory($smbios_memory) != $installed_memory) {
			print "ERROR: Memory found by smbios (${smbios_memory}MB) does not match memory found in $config_command (${installed_memory}MB).\n";
			print "       This may be corrected by installing a Sun BIOS patch on this system.\n";
			$exitstatus=1;
		}
		if ($ipmi_memory && $ipmi_memory != $installed_memory && ! $ldm_memory) {
			print "ERROR: Memory found by ipmitool (${ipmi_memory}MB) does not match memory found in $config_command (${installed_memory}MB).\n";
			print "       This may be corrected by installing a Sun BIOS patch on this system.\n";
			$exitstatus=1;
		}
	}
	# Tested on SunOS 4.X - 5.11 (Solaris 1.0 through Solaris 11)
	# Flag Future/Beta SunOS releases as untested
	if ($osrel =~ /^5.1[2-9]|^[6-9]/) {
		$untested=1;
		$untested_type="OS" if (! $untested_type);
	}
	# Flag untested CPU types:
	# US-IIIi+ (Serrano)
	if ($cputype =~ /UltraSPARC-IIIi\+/) {
		$untested=1;
		$untested_type="CPU" if (! $untested_type);
	}
	# SPARC-T4+, SPARC-T6 or newer
	if ($cputype =~ /SPARC-T([4-9]\+|[6-9])/) {
		$untested=1;
		$untested_type="CPU" if (! $untested_type);
	}
	# SPARC-M5, SPARC-M6 or other SPARC-M*
	if ($cputype =~ /SPARC.M\d\+/) {
		$untested=1;
		$untested_type="CPU" if (! $untested_type);
	}
	# SPARC-S* excluding SPARC-S7
	if ($cputype =~ /SPARC.S\d\+/ && $cputype !~ /SPARC.S7\b/) {
		$untested=1;
		$untested_type="CPU" if (! $untested_type);
	}
	# SPARC64-VII++ or newer other than SPARC64-X
	if ($cputype =~ /SPARC64-(VII\+\+|VIII|IX|X)/ && $cputype !~ /SPARC64-X\b/) {
		$untested=1;
		$untested_type="CPU" if (! $untested_type);
	}
	# Dual-Core, Triple-Core, Quad-Core, Six-Core, Eight-Core, Ten-Core,
	# Twelve-Core, Fourteen-Core, Sixteen-Core, Eighteen-Core x86 CPUs
	# have been tested. Don't flag as untested CPU as of V3.14.
#	if ($isX86 && $corecnt !~ /^(1|2|3|4|6|8|10|12|14|16|18)$/) {
#		$untested=1;
#		$untested_type="CPU" if (! $untested_type);
#	}
	&show_untested if ($untested);
	&mailmaintainer if ($verbose == 3);
	&pdebug("exit $exitstatus");
	exit $exitstatus;
}

sub createfile {
	$s=shift;
	push(@filelist, "$s");
	open(OUTFILE, ">/tmp/$s") || die "can't open /tmp/$s: $!";
	$tmp=0;
	foreach $line (@_) {
		print OUTFILE "$line";
		print OUTFILE "\n" if ($line !~ /\n$/);
		$tmp++;
	}
	close(OUTFILE);
	print STDERR time . " created $tmp lines in $s\n" if ($debug);
}

sub b64encodefile {
	local($file)=@_;
	local($res)="";
	local($chunk)="";
	$base64_alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ' .
			 'abcdefghijklmnopqrstuvwxyz' .
			 '0123456789+/';
	$uuencode_alphabet=q|`!"#$%&'()*+,-./0123456789:;<=>?| .
			 '@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_';
	# Build some strings for use in tr/// commands.
	# Some uuencodes use " " and some use "`", so we handle both.
	# We also need to protect backslashes and other special characters.
	$tr_uuencode=" " . $uuencode_alphabet;
	$tr_uuencode=~s/(\W)/\\$1/g;
	$tr_base64="A" . $base64_alphabet;
	$tr_base64=~s/(\W)/\\$1/g;
	$base64_pad='=';
	if (open(INFILE, "<$file")) {
		# break into chunks of 45 input chars, use perl's builtin
		# uuencoder to convert each chunk to uuencode format,
		# then kill the leading "M", translate to the base64 alphabet,
		# and finally append a newline.
		while (read(INFILE, $_, 45)) {
			if (length($_) == 45) {
				$chunk=substr(pack("u", $_), $[+1, 60);
				eval qq{
					\$chunk =~ tr|$tr_uuencode|$tr_base64|;
				};
			} else {
				# any leftover chars go onto a shorter line with
				# uuencode padding converted to base64 padding
				$chunk=substr(pack("u", $_), $[+1, int((length($_)+2)/3)*4 - (45-length($_))%3);
				eval qq{
					\$chunk =~ tr|$tr_uuencode|$tr_base64|;
				};
				$res .= $chunk . ($base64_pad x ((60 - length($chunk)) % 4));
			}
			$res .= $chunk . "\n";
		}
		close(INFILE);
		return($res);
	} else {
		return("");
	}
}

sub mailmaintainer {
	# E-mail information of system to maintainer. Use system call to
	# sendmail instead of Mail::Send module so that this works for perl4
	if (-x '/usr/sbin/sendmail') {
		$sendmail='/usr/sbin/sendmail';
	} elsif (-x '/usr/lib/sendmail') {
		$sendmail='/usr/lib/sendmail';
	} else {
		$sendmail="";
	}
	if ($sendmail) {
		print "\nSending E-mail to memconf maintainer tom\@4schmidts.com";
		print " with output of:\n            memconf -d  (seen above)\n";
		&show_helpers("            ");
		print "\nIf this system cannot send E-mail to the internet, then please E-mail the\n";
		print "following file to tom\@4schmidts.com as an attachment from a system that can:\n";
	} else {
		print "\nPlease E-mail the following file as an attachment to tom\@4schmidts.com\n";
	}
	# Rewrite fully-qualified hostnames so that attachment filename has
	# only one extension.
	$newhostname=$hostname;
	$newhostname=~s/\./_/g;
	$outfile="memconf_$newhostname";
	print ("            /tmp/${outfile}.tar\n");
	if ($filename) {
		$mail_subj=($SUNWexplo) ? "Sun/Oracle Explorer directory $filename" : "filename $filename";
	} else {
		$mail_subj="$hostname";
	}
	$mail_subject="memconf output from $mail_subj";
	close(STDOUT);
	rename("/tmp/memconf.output","/tmp/${outfile}.txt");
	push(@filelist, "${outfile}.txt");
	if ($config_cmd) {
		@config=&run("$config_cmd") if (! $config[0]);
		&createfile("${outfile}_${config_command}.txt",@config);
	}
	if ($os eq "SunOS") {
		&createfile("${outfile}_prtdiag.txt",@prtdiag) if ($prtdiag_exec);
		&createfile("${outfile}_prtfru.txt",@prtfru) if ($prtfru_cmd);
		&createfile("${outfile}_prtpicl.txt",@prtpicl) if ($prtpicl_cmd);
		&createfile("${outfile}_psrinfo.txt",@psrinfo) if ($psrinfo_cmd);
		&createfile("${outfile}_virtinfo.txt",@virtinfo) if ($virtinfo_cmd);
		&createfile("${outfile}_cfgadm.txt",@cfgadm) if ($cfgadm_cmd);
		&createfile("${outfile}_smbios.txt",@smbios) if ($smbios_cmd);
		&createfile("${outfile}_kstat.txt",@kstat) if ($kstat_cmd);
		&createfile("${outfile}_ldm.txt",@ldm) if ($ldm_cmd);
	}
	&createfile("${outfile}_cpuinfo.txt",@cpuinfo) if (-r '/proc/cpuinfo');
	&createfile("${outfile}_meminfo.txt",@meminfo) if (-r '/proc/meminfo');
	&createfile("${outfile}_free.txt",@free) if ($free_cmd);
	&createfile("${outfile}_xm_info.txt",@xm_info) if ($xm_info_cmd);
	if (-x '/usr/bin/xenstore-ls') {
		$domid=&mychomp(`/usr/bin/xenstore-read domid 2>/dev/null`);
		if ($domid) {
			@xenstore=`/usr/bin/xenstore-ls /local/domain/$domid 2>/dev/null`;
			&createfile("${outfile}_xenstore-ls.txt",@xenstore);
		}
	}
	&createfile("${outfile}_decodedimms.txt",@decodedimms) if ($decodedimms_cmd);
	&createfile("${outfile}_ipmitool.txt",@ipmitool) if ($ipmitool_cmd);
	if ($os eq "HP-UX") {
		&createfile("${outfile}_machinfo.txt",@machinfo) if (-x '/usr/contrib/bin/machinfo');
	}
	`cd /tmp; tar cf /tmp/${outfile}.tar @filelist 2>/dev/null`;
	if ($sendmail) {
		# Make MIME attachment using sendmail
		open(MAIL, "|$sendmail -t");
		print MAIL "To: tom\@4schmidts.com\n";
		print MAIL "Subject: $mail_subject\n";
		print MAIL "MIME-Version: 1.0\n";
		print MAIL "Content-Type: multipart/mixed; boundary=\"memconf_UNIQUE_LINE\"\n";
		print MAIL "\n";
		print MAIL "This is a multi-part message in MIME format.\n";
		print MAIL "--memconf_UNIQUE_LINE\n";
		print MAIL "Content-Type: text/plain; charset=\"ISO-8859-1\"; format=flowed\n";
		print MAIL "\n";
		print MAIL "Attached is output and regression test files from memconf $version $version_date from $mail_subj\n\n";
		open(FILE, "/tmp/${outfile}.txt");
		@tmp=<FILE>;
		close(FILE);
		print MAIL @tmp;
		print MAIL "\n--memconf_UNIQUE_LINE\n";
		print MAIL "Content-Type: application/octet-stream; name=\"${outfile}.tar\"\n";
		print MAIL "Content-Transfer-Encoding: base64\n";
		print MAIL "Content-Disposition: attachment; filename=\"${outfile}.tar\"\n";
		print MAIL "\n";
		print MAIL &b64encodefile("/tmp/${outfile}.tar");
		print MAIL "--memconf_UNIQUE_LINE--\n";
		close(MAIL);
	}
	foreach $tmp (@filelist) {
		unlink "/tmp/$tmp";
	}
}

