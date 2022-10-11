#!/bin/sh
# This script was generated using Makeself 2.4.3
# The license covering this archive and its contents, if any, is wholly independent of the Makeself license (GPL)

ORIG_UMASK=`umask`
if test "n" = n; then
    umask 077
fi

CRCsum="1811307207"
MD5="b13db8056bc0c9d2bb29758af2adb081"
SHA="0000000000000000000000000000000000000000000000000000000000000000"
TMPROOT=${TMPDIR:=/tmp}
USER_PWD="$PWD"
export USER_PWD
ARCHIVE_DIR=`dirname "$0"`
export ARCHIVE_DIR

label="keyboard_firmware"
script="./flash.sh"
scriptargs=""
cleanup_script=""
licensetxt=""
helpheader=''
targetdir="stm32duino_bootloader_upload"
filesizes="104476"
totalsize="104476"
keep="n"
nooverwrite="n"
quiet="n"
accept="n"
nodiskspace="n"
export_conf="n"
decrypt_cmd=""
skip="678"

print_cmd_arg=""
if type printf > /dev/null; then
    print_cmd="printf"
elif test -x /usr/ucb/echo; then
    print_cmd="/usr/ucb/echo"
else
    print_cmd="echo"
fi

if test -d /usr/xpg4/bin; then
    PATH=/usr/xpg4/bin:$PATH
    export PATH
fi

if test -d /usr/sfw/bin; then
    PATH=$PATH:/usr/sfw/bin
    export PATH
fi

unset CDPATH

MS_Printf()
{
    $print_cmd $print_cmd_arg "$1"
}

MS_PrintLicense()
{
  if test x"$licensetxt" != x; then
    if test x"$accept" = xy; then
      echo "$licensetxt"
    else
      echo "$licensetxt" | more
    fi
    if test x"$accept" != xy; then
      while true
      do
        MS_Printf "Please type y to accept, n otherwise: "
        read yn
        if test x"$yn" = xn; then
          keep=n
          eval $finish; exit 1
          break;
        elif test x"$yn" = xy; then
          break;
        fi
      done
    fi
  fi
}

MS_diskspace()
{
	(
	df -kP "$1" | tail -1 | awk '{ if ($4 ~ /%/) {print $3} else {print $4} }'
	)
}

MS_dd()
{
    blocks=`expr $3 / 1024`
    bytes=`expr $3 % 1024`
    # Test for ibs, obs and conv feature
    if dd if=/dev/zero of=/dev/null count=1 ibs=512 obs=512 conv=sync 2> /dev/null; then
        dd if="$1" ibs=$2 skip=1 obs=1024 conv=sync 2> /dev/null | \
        { test $blocks -gt 0 && dd ibs=1024 obs=1024 count=$blocks ; \
          test $bytes  -gt 0 && dd ibs=1 obs=1024 count=$bytes ; } 2> /dev/null
    else
        dd if="$1" bs=$2 skip=1 2> /dev/null
    fi
}

MS_dd_Progress()
{
    if test x"$noprogress" = xy; then
        MS_dd "$@"
        return $?
    fi
    file="$1"
    offset=$2
    length=$3
    pos=0
    bsize=4194304
    while test $bsize -gt $length; do
        bsize=`expr $bsize / 4`
    done
    blocks=`expr $length / $bsize`
    bytes=`expr $length % $bsize`
    (
        dd ibs=$offset skip=1 count=0 2>/dev/null
        pos=`expr $pos \+ $bsize`
        MS_Printf "     0%% " 1>&2
        if test $blocks -gt 0; then
            while test $pos -le $length; do
                dd bs=$bsize count=1 2>/dev/null
                pcent=`expr $length / 100`
                pcent=`expr $pos / $pcent`
                if test $pcent -lt 100; then
                    MS_Printf "\b\b\b\b\b\b\b" 1>&2
                    if test $pcent -lt 10; then
                        MS_Printf "    $pcent%% " 1>&2
                    else
                        MS_Printf "   $pcent%% " 1>&2
                    fi
                fi
                pos=`expr $pos \+ $bsize`
            done
        fi
        if test $bytes -gt 0; then
            dd bs=$bytes count=1 2>/dev/null
        fi
        MS_Printf "\b\b\b\b\b\b\b" 1>&2
        MS_Printf " 100%%  " 1>&2
    ) < "$file"
}

MS_Help()
{
    cat << EOH >&2
${helpheader}Makeself version 2.4.3
 1) Getting help or info about $0 :
  $0 --help   Print this message
  $0 --info   Print embedded info : title, default target directory, embedded script ...
  $0 --lsm    Print embedded lsm entry (or no LSM)
  $0 --list   Print the list of files in the archive
  $0 --check  Checks integrity of the archive

 2) Running $0 :
  $0 [options] [--] [additional arguments to embedded script]
  with following options (in that order)
  --confirm             Ask before running embedded script
  --quiet               Do not print anything except error messages
  --accept              Accept the license
  --noexec              Do not run embedded script (implies --noexec-cleanup)
  --noexec-cleanup      Do not run embedded cleanup script
  --keep                Do not erase target directory after running
                        the embedded script
  --noprogress          Do not show the progress during the decompression
  --nox11               Do not spawn an xterm
  --nochown             Do not give the target folder to the current user
  --chown               Give the target folder to the current user recursively
  --nodiskspace         Do not check for available disk space
  --target dir          Extract directly to a target directory (absolute or relative)
                        This directory may undergo recursive chown (see --nochown).
  --tar arg1 [arg2 ...] Access the contents of the archive through the tar command
  --ssl-pass-src src    Use the given src as the source of password to decrypt the data
                        using OpenSSL. See "PASS PHRASE ARGUMENTS" in man openssl.
                        Default is to prompt the user to enter decryption password
                        on the current terminal.
  --cleanup-args args   Arguments to the cleanup script. Wrap in quotes to provide
                        multiple arguments.
  --                    Following arguments will be passed to the embedded script
EOH
}

MS_Check()
{
    OLD_PATH="$PATH"
    PATH=${GUESS_MD5_PATH:-"$OLD_PATH:/bin:/usr/bin:/sbin:/usr/local/ssl/bin:/usr/local/bin:/opt/openssl/bin"}
	MD5_ARG=""
    MD5_PATH=`exec <&- 2>&-; which md5sum || command -v md5sum || type md5sum`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which md5 || command -v md5 || type md5`
    test -x "$MD5_PATH" || MD5_PATH=`exec <&- 2>&-; which digest || command -v digest || type digest`
    PATH="$OLD_PATH"

    SHA_PATH=`exec <&- 2>&-; which shasum || command -v shasum || type shasum`
    test -x "$SHA_PATH" || SHA_PATH=`exec <&- 2>&-; which sha256sum || command -v sha256sum || type sha256sum`

    if test x"$quiet" = xn; then
		MS_Printf "Verifying archive integrity..."
    fi
    offset=`head -n "$skip" "$1" | wc -c | tr -d " "`
    fsize=`cat "$1" | wc -c | tr -d " "`
    if test $totalsize -ne `expr $fsize - $offset`; then
        echo " Unexpected archive size." >&2
        exit 2
    fi
    verb=$2
    i=1
    for s in $filesizes
    do
		crc=`echo $CRCsum | cut -d" " -f$i`
		if test -x "$SHA_PATH"; then
			if test x"`basename $SHA_PATH`" = xshasum; then
				SHA_ARG="-a 256"
			fi
			sha=`echo $SHA | cut -d" " -f$i`
			if test x"$sha" = x0000000000000000000000000000000000000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded SHA256 checksum." >&2
			else
				shasum=`MS_dd_Progress "$1" $offset $s | eval "$SHA_PATH $SHA_ARG" | cut -b-64`;
				if test x"$shasum" != x"$sha"; then
					echo "Error in SHA256 checksums: $shasum is different from $sha" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " SHA256 checksums are OK." >&2
				fi
				crc="0000000000";
			fi
		fi
		if test -x "$MD5_PATH"; then
			if test x"`basename $MD5_PATH`" = xdigest; then
				MD5_ARG="-a md5"
			fi
			md5=`echo $MD5 | cut -d" " -f$i`
			if test x"$md5" = x00000000000000000000000000000000; then
				test x"$verb" = xy && echo " $1 does not contain an embedded MD5 checksum." >&2
			else
				md5sum=`MS_dd_Progress "$1" $offset $s | eval "$MD5_PATH $MD5_ARG" | cut -b-32`;
				if test x"$md5sum" != x"$md5"; then
					echo "Error in MD5 checksums: $md5sum is different from $md5" >&2
					exit 2
				elif test x"$quiet" = xn; then
					MS_Printf " MD5 checksums are OK." >&2
				fi
				crc="0000000000"; verb=n
			fi
		fi
		if test x"$crc" = x0000000000; then
			test x"$verb" = xy && echo " $1 does not contain a CRC checksum." >&2
		else
			sum1=`MS_dd_Progress "$1" $offset $s | CMD_ENV=xpg4 cksum | awk '{print $1}'`
			if test x"$sum1" != x"$crc"; then
				echo "Error in checksums: $sum1 is different from $crc" >&2
				exit 2
			elif test x"$quiet" = xn; then
				MS_Printf " CRC checksums are OK." >&2
			fi
		fi
		i=`expr $i + 1`
		offset=`expr $offset + $s`
    done
    if test x"$quiet" = xn; then
		echo " All good."
    fi
}

MS_Decompress()
{
    if test x"$decrypt_cmd" != x""; then
        { eval "$decrypt_cmd" || echo " ... Decryption failed." >&2; } | eval "gzip -cd"
    else
        eval "gzip -cd"
    fi
    
    if test $? -ne 0; then
        echo " ... Decompression failed." >&2
    fi
}

UnTAR()
{
    if test x"$quiet" = xn; then
		tar $1vf -  2>&1 || { echo " ... Extraction failed." > /dev/tty; kill -15 $$; }
    else
		tar $1f -  2>&1 || { echo Extraction failed. > /dev/tty; kill -15 $$; }
    fi
}

MS_exec_cleanup() {
    if test x"$cleanup" = xy && test x"$cleanup_script" != x""; then
        cleanup=n
        cd "$tmpdir"
        eval "\"$cleanup_script\" $scriptargs $cleanupargs"
    fi
}

MS_cleanup()
{
    echo 'Signal caught, cleaning up' >&2
    MS_exec_cleanup
    cd "$TMPROOT"
    rm -rf "$tmpdir"
    eval $finish; exit 15
}

finish=true
xterm_loop=
noprogress=n
nox11=n
copy=none
ownership=n
verbose=n
cleanup=y
cleanupargs=

initargs="$@"

while true
do
    case "$1" in
    -h | --help)
	MS_Help
	exit 0
	;;
    -q | --quiet)
	quiet=y
	noprogress=y
	shift
	;;
	--accept)
	accept=y
	shift
	;;
    --info)
	echo Identification: "$label"
	echo Target directory: "$targetdir"
	echo Uncompressed size: 312 KB
	echo Compression: gzip
	if test x"n" != x""; then
	    echo Encryption: n
	fi
	echo Date of packaging: Sun Dec 19 12:48:17 CST 2021
	echo Built with Makeself version 2.4.3
	echo Build command was: "/usr/local/bin/makeself.sh \\
    \"stm32duino_bootloader_upload\" \\
    \"DevTerm_keyboard_firmware_v0.21_utils.sh\" \\
    \"keyboard_firmware\" \\
    \"./flash.sh\""
	if test x"$script" != x; then
	    echo Script run after extraction:
	    echo "    " $script $scriptargs
	fi
	if test x"" = xcopy; then
		echo "Archive will copy itself to a temporary location"
	fi
	if test x"n" = xy; then
		echo "Root permissions required for extraction"
	fi
	if test x"n" = xy; then
	    echo "directory $targetdir is permanent"
	else
	    echo "$targetdir will be removed after extraction"
	fi
	exit 0
	;;
    --dumpconf)
	echo LABEL=\"$label\"
	echo SCRIPT=\"$script\"
	echo SCRIPTARGS=\"$scriptargs\"
    echo CLEANUPSCRIPT=\"$cleanup_script\"
	echo archdirname=\"stm32duino_bootloader_upload\"
	echo KEEP=n
	echo NOOVERWRITE=n
	echo COMPRESS=gzip
	echo filesizes=\"$filesizes\"
    echo totalsize=\"$totalsize\"
	echo CRCsum=\"$CRCsum\"
	echo MD5sum=\"$MD5sum\"
	echo SHAsum=\"$SHAsum\"
	echo SKIP=\"$skip\"
	exit 0
	;;
    --lsm)
cat << EOLSM
No LSM.
EOLSM
	exit 0
	;;
    --list)
	echo Target directory: $targetdir
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | UnTAR t
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
	--tar)
	offset=`head -n "$skip" "$0" | wc -c | tr -d " "`
	arg1="$2"
    if ! shift 2; then MS_Help; exit 1; fi
	for s in $filesizes
	do
	    MS_dd "$0" $offset $s | MS_Decompress | tar "$arg1" - "$@"
	    offset=`expr $offset + $s`
	done
	exit 0
	;;
    --check)
	MS_Check "$0" y
	exit 0
	;;
    --confirm)
	verbose=y
	shift
	;;
	--noexec)
	script=""
    cleanup_script=""
	shift
	;;
    --noexec-cleanup)
    cleanup_script=""
    shift
    ;;
    --keep)
	keep=y
	shift
	;;
    --target)
	keep=y
	targetdir="${2:-.}"
    if ! shift 2; then MS_Help; exit 1; fi
	;;
    --noprogress)
	noprogress=y
	shift
	;;
    --nox11)
	nox11=y
	shift
	;;
    --nochown)
	ownership=n
	shift
	;;
    --chown)
        ownership=y
        shift
        ;;
    --nodiskspace)
	nodiskspace=y
	shift
	;;
    --xwin)
	if test "n" = n; then
		finish="echo Press Return to close this window...; read junk"
	fi
	xterm_loop=1
	shift
	;;
    --phase2)
	copy=phase2
	shift
	;;
	--ssl-pass-src)
	if test x"n" != x"openssl"; then
	    echo "Invalid option --ssl-pass-src: $0 was not encrypted with OpenSSL!" >&2
	    exit 1
	fi
	decrypt_cmd="$decrypt_cmd -pass $2"
	if ! shift 2; then MS_Help; exit 1; fi
	;;
    --cleanup-args)
    cleanupargs="$2"
    if ! shift 2; then MS_help; exit 1; fi
    ;;
    --)
	shift
	break ;;
    -*)
	echo Unrecognized flag : "$1" >&2
	MS_Help
	exit 1
	;;
    *)
	break ;;
    esac
done

if test x"$quiet" = xy -a x"$verbose" = xy; then
	echo Cannot be verbose and quiet at the same time. >&2
	exit 1
fi

if test x"n" = xy -a `id -u` -ne 0; then
	echo "Administrative privileges required for this archive (use su or sudo)" >&2
	exit 1	
fi

if test x"$copy" \!= xphase2; then
    MS_PrintLicense
fi

case "$copy" in
copy)
    tmpdir="$TMPROOT"/makeself.$RANDOM.`date +"%y%m%d%H%M%S"`.$$
    mkdir "$tmpdir" || {
	echo "Could not create temporary directory $tmpdir" >&2
	exit 1
    }
    SCRIPT_COPY="$tmpdir/makeself"
    echo "Copying to a temporary location..." >&2
    cp "$0" "$SCRIPT_COPY"
    chmod +x "$SCRIPT_COPY"
    cd "$TMPROOT"
    exec "$SCRIPT_COPY" --phase2 -- $initargs
    ;;
phase2)
    finish="$finish ; rm -rf `dirname $0`"
    ;;
esac

if test x"$nox11" = xn; then
    if tty -s; then                 # Do we have a terminal?
	:
    else
        if test x"$DISPLAY" != x -a x"$xterm_loop" = x; then  # No, but do we have X?
            if xset q > /dev/null 2>&1; then # Check for valid DISPLAY variable
                GUESS_XTERMS="xterm gnome-terminal rxvt dtterm eterm Eterm xfce4-terminal lxterminal kvt konsole aterm terminology"
                for a in $GUESS_XTERMS; do
                    if type $a >/dev/null 2>&1; then
                        XTERM=$a
                        break
                    fi
                done
                chmod a+x $0 || echo Please add execution rights on $0
                if test `echo "$0" | cut -c1` = "/"; then # Spawn a terminal!
                    exec $XTERM -e "$0 --xwin $initargs"
                else
                    exec $XTERM -e "./$0 --xwin $initargs"
                fi
            fi
        fi
    fi
fi

if test x"$targetdir" = x.; then
    tmpdir="."
else
    if test x"$keep" = xy; then
	if test x"$nooverwrite" = xy && test -d "$targetdir"; then
            echo "Target directory $targetdir already exists, aborting." >&2
            exit 1
	fi
	if test x"$quiet" = xn; then
	    echo "Creating directory $targetdir" >&2
	fi
	tmpdir="$targetdir"
	dashp="-p"
    else
	tmpdir="$TMPROOT/selfgz$$$RANDOM"
	dashp=""
    fi
    mkdir $dashp "$tmpdir" || {
	echo 'Cannot create target directory' $tmpdir >&2
	echo 'You should try option --target dir' >&2
	eval $finish
	exit 1
    }
fi

location="`pwd`"
if test x"$SETUP_NOCHECK" != x1; then
    MS_Check "$0"
fi
offset=`head -n "$skip" "$0" | wc -c | tr -d " "`

if test x"$verbose" = xy; then
	MS_Printf "About to extract 312 KB in $tmpdir ... Proceed ? [Y/n] "
	read yn
	if test x"$yn" = xn; then
		eval $finish; exit 1
	fi
fi

if test x"$quiet" = xn; then
    # Decrypting with openssl will ask for password,
    # the prompt needs to start on new line
	if test x"n" = x"openssl"; then
	    echo "Decrypting and uncompressing $label..."
	else
        MS_Printf "Uncompressing $label"
	fi
fi
res=3
if test x"$keep" = xn; then
    trap MS_cleanup 1 2 3 15
fi

if test x"$nodiskspace" = xn; then
    leftspace=`MS_diskspace "$tmpdir"`
    if test -n "$leftspace"; then
        if test "$leftspace" -lt 312; then
            echo
            echo "Not enough space left in "`dirname $tmpdir`" ($leftspace KB) to decompress $0 (312 KB)" >&2
            echo "Use --nodiskspace option to skip this check and proceed anyway" >&2
            if test x"$keep" = xn; then
                echo "Consider setting TMPDIR to a directory with more free space."
            fi
            eval $finish; exit 1
        fi
    fi
fi

for s in $filesizes
do
    if MS_dd_Progress "$0" $offset $s | MS_Decompress | ( cd "$tmpdir"; umask $ORIG_UMASK ; UnTAR xp ) 1>/dev/null; then
		if test x"$ownership" = xy; then
			(cd "$tmpdir"; chown -R `id -u` .;  chgrp -R `id -g` .)
		fi
    else
		echo >&2
		echo "Unable to decompress $0" >&2
		eval $finish; exit 1
    fi
    offset=`expr $offset + $s`
done
if test x"$quiet" = xn; then
	echo
fi

cd "$tmpdir"
res=0
if test x"$script" != x; then
    if test x"$export_conf" = x"y"; then
        MS_BUNDLE="$0"
        MS_LABEL="$label"
        MS_SCRIPT="$script"
        MS_SCRIPTARGS="$scriptargs"
        MS_ARCHDIRNAME="$archdirname"
        MS_KEEP="$KEEP"
        MS_NOOVERWRITE="$NOOVERWRITE"
        MS_COMPRESS="$COMPRESS"
        MS_CLEANUP="$cleanup"
        export MS_BUNDLE MS_LABEL MS_SCRIPT MS_SCRIPTARGS
        export MS_ARCHDIRNAME MS_KEEP MS_NOOVERWRITE MS_COMPRESS
    fi

    if test x"$verbose" = x"y"; then
		MS_Printf "OK to execute: $script $scriptargs $* ? [Y/n] "
		read yn
		if test x"$yn" = x -o x"$yn" = xy -o x"$yn" = xY; then
			eval "\"$script\" $scriptargs \"\$@\""; res=$?;
		fi
    else
		eval "\"$script\" $scriptargs \"\$@\""; res=$?
    fi
    if test "$res" -ne 0; then
		test x"$verbose" = xy && echo "The program '$script' returned an error code ($res)" >&2
    fi
fi

MS_exec_cleanup

if test x"$keep" = xn; then
    cd "$TMPROOT"
    rm -rf "$tmpdir"
fi
eval $finish; exit $res
� ���a�]�w�Ƴ�W��
�:��mɯ�!��@K����{Na-�m�,���B��ߙٕ�HBq.i�s K������gfGK�V�I�)��HpOĲjכv�i��~�m�����/~{�뭯��p��M����vùe7��f�n��[u�q�؇[+�R��H���u6J��ر�N�޴[�N��j:M���2�-�o[�f��hTm���N������uo�
�|��Z�%�����������u������*���,�?@����D�n��l5l����\�nvǳ�D }���
7��_�b����i� ��4`(����s�����Ng��Z��/�-t���7��_��;�E�ov��_��~��_�6��_�к�[��F�������\��wl�����o7��o;�W���n� ��>e���o������"�o������ۮ�kp�����r�m�븞���͝F���6���=B�������� ��Z�����r�������Vuk��j�����斳թb�Щ7����V-4�F���oe�;�����~N��M���������}�
�7��7��i�KX���_�7a��6��VK;x�q�������z������
��t����`����:t�X�2J�G�O�xҏ�ON��Q�vX�(��@�"O�]��(�x�7}H���X�ӱ�!�b�1�J3����	ݤq o��s�R
���B?�D��t�F�%k����PoX��6i�D�SE��H���7��/����n���on����t���[M��~����N�f�����B�¶� ��>e�������7�����z�|$<6���Lx~�/~V��
K"�5མ�T-��F��0��ɋP ��ɘ�FrP�|4�7���)��>���ީ7�b��n�8��e�D�?��4ڋ��h��+�n�P끻,��m�6�2�f��D0e���C�#����8�l$���B'��Yo-LE���h�8�h�Wd���ыa��0Jz�&O�d��(��q�`^�T2�OD�|)S?@s��8�>o>#��3l���Dre�g���i���&� :�E5������G�B��E��`
dV
��`��}�#���%@c.�bs�e���i@,	&�^�&8�1Q��H
7
=�,D<�r���Ǣ4�j����� �'���8�P���6�����*{ʓ!�+�A� 1���$�u(r��	�DD�;�v�D�D����9�0�yx���(�}*�I��n<�6*
�cn�D�j�B��ec�~zM�ZY3}��q�뀹~�����%����	5W -1
E6S� =o����|�Bx��dv�h*��A	�����	��9��w�bciE)�\,�4i�!!��`������l�uf1{�8c" � �<_0�e(�� #̈bɔ[4�l4�l\���� ���H�	�qd
#��$��_A��	�R���>������2�G��Ihiza�n$M�r�NE��%�)� ��Jtt���0�Y�((�BO�T@���7�>��k@�Rsrl���F�#m���d�rK��s�9�B��}CS�J� ;�{S;�(�0h\���6b�Н�x�ұ �`�B��D?�݃Q�ra�"x��b�?R26�VK|LˍfHL�zz+w�ݻf����R�P-I��bs�O@�J%MzWqb�i
����^0�tA�����M-1�W��
���t�ܨ�/���� ރ����=��	��4u�-,�q��������o�X���VF���� ��MD������n���������^д����H�j?}zI��O��YFGo�R�.`k7M��֮k�'��!��R��Q�?��N�Z��ݏ"�����=�zTK�݌��2
N�)�ށe�^�Z��:bTWZ~�W�uV���>{�����\��2���S���92Qk
}�
(*�$ 'T_������R��K��{)tx/�]�vT�iR���5vFo1�SG�=�^�HݲĴ&N`wJ��#�hvQ�:�tm�.)z�?�&hz�ζ��0Tq}��1h��������o�Y��]���k��ʾ|���tZ���.����_�A�8`'��\�8y��7"ނF�t�S,C�Ѩ!�MQJpBl�YR�Ѝ���XbV`�caM�ڊ�������k��Aٯ`�ۭ����F���ߓ����'�7�0����n/˃J�
�S�2���j�2��yf�\&w��l&����2�����,��_�����Ze_��7�f�\�w�U���f��*<��4py>�*9�@׌� ����h�5S��\�[��I-L��9�?�t%>�~(�,b:-���灦��<��g�$���8��<���V�ɴ5�`�zŬD�̻_7�>�����$J��C���������i�j7���	~�O<��jP%�å���s�dY�(
��Ε[�ޟ	�U:�  @qUEt��J�#)�8�	f\1�T̞PY;�$���Ɛ�	��J�)��$���@)`�L�"����,!��R���;F�1A�/Z�{&ǘ��9&�4�^���#���<�H�!��9���gj"GM�
���<�(�ZE���cl
e:����E�6(�!7��%(bϣ &U2�^�,��K��
Y]ǹ���/hT<�2�Z�_N��2������I�r�w�|�>��;$��� z)]�Rw���،^����-dM��A�"��v:�a�H�i+Yn(�'R�~$����Y;(�9U��diFU~�9��}>��U`���sҾ^!��l����+���_��W��6��[���?��#iZ����o��ɸ4�����;8����]�����s��L_:�{i�o�]���S�U�AW���������Vn��Vٗ��N��\��e������l?[0�N�7ff���#����<ne��Q=�ǳ&x�?�*�Kʼ�b 
V�o,G� �T�l3�bOf0������wU}��U�H/
1�Xv���g�������E~2D��o�8ˎlU���Y�c�S����sV�RMO]��
��IH~���X:�Ba,
&<�x��axW���&�b���~�!��F��dR���� ���8I�:㽊_��)����gϤS�[h����}����(��x�{� �;t�H��1
t�n�G�� ��!<�%���U�6:[?k ��┩��7H�����U�Q,wg��~Eu-���K:�?4�Tį�/hpJ\�:�:F%�m�10F�a�t�B�W��v]��(<OP�����|�1�d'�s�ȏg1����;�r>u�U��>�j�8*ьHK
�_\���_��K����9�o6������^4���`��5w�9�lo�ߛ�?i�Gl�Ȉ�Q��iN%�̱t���K\��Me�U!��N{���!�ۨ�A���홁��Ҧ#��C�!��	A��i0���10˂{ڑ���H�]�~~�-����$UsHO����mHAh5Z���Q� RC�8;~AE�+�W��&��wY��5��.'@�'0S���*���T2ʈ��$3��%�>8�XB��)��BN�F9��F=<Y��� a�g;ث�ͫ��`���+�F���m|Ύ9�?0!�V�S�#�''�^���siްO���v�m��/���P%��dJ�'�%MY8�:]�H�L�b�p�^�κQ��6��wAx�����D?��@Ԏ��A&���13w���+�h�~͈Kh=]�n����<,��:�Q��2U�0'A0Q���A�!fY��\8��|*�")�"]l�pBt�bS�RT�3�!�~x�n��>�e�2�W�Z�Iz�˅�<�k��"2�WUB����m`j�ͣ�q�̪��3�`�\(?�Ͽ��:ʁ�a]J�Y�D6v<�`�7�{���k�v�
� ����~�[�~.����#������&�ʣ���T�P��$|x dj��#�f�������&xD6���� 5��ʬ�B�Y�^���u-��M�3�W� q�Ȁ"��8��XeU���_{��<v*^/T�����C���]!���O���06� 	��(�Ȼ����,�:�Y��Mz�BLO��.n���e!�ʬqc�8q��$td��H�!h(-��W���'>�<qh��Έn��q�!5�C)���1.N����C�D$��C*�V�G��H��^�@������j�IX(��]�2���gBмLJŒ����ϸ
���T���\b5 ��d ��_�E�d	�px*ާ�
"ʓ1�@Q�u*�Ԉ]�\<�
����D)t~��$���nH&���V�Ъ�,��G�Q����r�Y�A�ϋ��wO���"2t-#k+m�,�����E��W�����:�~�����w����
�]���u�g+��Ͻ1{��������I+������v�^S$884�����
v��Ct ��#���$V K%�{�T��q�Qrvl鮘XU&39[A��|4o��a��fnA��޷�:���e��K*�qÊ<�Q�u�|�l-���iT�z�����n09
�ǀT�Z��\4��0�����`h��f/m�f��&	U%�FM8���_�0[ə&��D�g�\yɱ��/5;+��Y����L���_
k�@{�E�;����H�汧!��K/V� �!8�8r�{�T�*����^��p�A��"�Y���;�~/�9ǌx�$����#��`���[�Ѹ'$p�ڢ�`�u캃��f�%w��ږ��bp�/QU߉�EM������!0s�"�AX#T�UV���=��h��E�DW��=�^ ��EL�'�<BnQ qrS�e�&�J�W�Z8w�dO"Qb͓:쉙�=�O��/��#�P�=V0	А�cR��DK$n`�O_/bh��1��[���õo��M�������K�;�w�����:�R���H�nz`[�TE���K�Q]TA�8Qj����l�ȟ@���_ԧmļ5k������ނ8��{����lD4�+�B��p�c���q�-AE�A���x�ǣ=�X�Oy||<3�T��c"�"r����;�<�H���E6t�ʀsa���d� ��)��8\m ��p��"�ݨ����|Y�����7�)P�EC�+��Աn)����'��s��oW&��f�<���� _��إ>$z��p�sx�]L�EE��x�<h�?��D��;*�P����*a�}Z����>k����
 Zy���8$mXDMR3>�1^v��a!���r9,a| |�*72=d�(Y���������H�Z��J,1���*�����A���c�4��f�c��c S�B�\Z%��Ln���XF�cP�T���4N���N97"RG�K^\���K�Vp��ަ��> ��w��*Sz�+|�&�?�n?]�V���*ԫ���A��N�|���F ����2�?'�N$�
q�����/H`��xò�eO/������;/r~+]:u[�3D5	~ji�	`��a����S��Z��+��C�P�A�����*�
�B#�ɴ�R�P����`�%�aL��
�j�����%�;�t��!�9|h�-dZ,�����HӄC�_�zv����v�:��4�\��P��
����RB�~ߥ�6��f���ǧ?AW��3o�E�r�Nϣ�V�޸�@F�/G#l���g'teοDߌs^M��/}o��J����h�M��_�����JM0��}��0��V[s�?@ݠn�@��������UZ��j�6��]?��nos��!pq$!��J
�2(�&����f�֬0�
;.��bո��]:*E'�Dߤޥ�Y�=S�1��	k�K�]T�Cwo���Ƣ0�9�\k2U��hRi��`�hf��̱HгJUU���Z�k��fKb�ZR��Y�:͢7�R�_��¬2��U�T:%B�3��b��
��rL4Z�^_&5m@g6"J��S�5H�)9�Zn@�J�g��Ak�h9�Bn����y���N������;V�V�!QTs<�}-g֛Uf%�c4���Ҡ��Lf�Ac԰:��@X��C|r�9Q���Yg��,�Nn�(�
VoқL�F���-*-�)Y���a#*�8�7��U��]�B#�V �H}��ĺA�?��?������B���;������ԠNԩ�:uP�~�v���Nk��^'�������S�����W�祻I	�R��(ju��_7�[����@u�����]0��P��j��A5c�{Ui�F����^��a�Q��@+�^�&H���Y4vF�
td�^a1h�
��ZT&�^��w��B���T�i�������E�d

�`4����'A$�̗����o�?�8���?������/@�a4v.�0�q�w��_ZJS�
�#���qA&����?.��|�?�Hd��&�X"�`2�PhT���T*������?`���Z��s��q��,���ok��c�H���3[�\�!����D��U^�g�&����ef��\ʀ��/��y�� K0h,H"� K�Q�@�̘>�D��Idn1��9����`������d�Ϟ��q�������֏��"a_��c����?�����?;����{#"��Gi�Y���
����������nFOh��k��9���Vp�׋��iȽ�c�l������\��#��Q��o�:ߦG\)~I��m�^0�z �|"]��~%��r���:r���t��di����o1^�bc��6H�y��s��-㨢ߋ�y�?
�D��J�`��C82�S���?ϝ�����R��7(��?<;�@�����ba_��� 8�b�-����#�wu�t{���q߭}��谊�8˨}����W��WM+M�|"H�@����,Ft
ߪ�J�o���K��Ń����oC<�C[�w �`m��/�n�����-��Q��y�@G���I���lp�X�O	&�'������`iD,�:{$h�L$�!,�H#�)T,�$��&�^���C�'��/��g�2������� ��?���%�'C;�&4���K��M$�f��a�IQ������j�(dzs��M�3M>1Z��-"�<�Na�e�	G���O�Nf��{�Ik~�h�1�X�8"�m9����>�A�>��`�gOqq'\vK�*@U�Ω~� �������������ȭ&ϫ.H��n myꃣb�ؕ��Eŉ���1\}9+����w|�Dx�K�LM~گ��XA���k���;x?�pTZ<�m��W��g���YrU���5�����X誣�L��T��F[�������*5��������W����c�'�Z3D�f��=sɋ��p��}ˠG)]�X���Ԍ�N��#X�J��n��
:f��asES1ϐ9@Y�g7��� �Lz}k��/�wf��.����!�m��Ǘշ���y��(llg�O�yU �ʹ+�[i��@��.���M��pd������q��ԫ
}jG���2-�$s?�^��~�����O��|9N�mV�����Y���wl,�qxM��^t�6�9��NW6ݐg��՞�ZO~��F�}�
��_��_/�O�!D��EgS�#jz��u.�����ez�47g~l�_����J˨�_[Q5+U?�U�����3G��jY���B<�(��x����~܀�`fc8��'}�W�񀫾���6]R�x�t����gr�o-Z/+_}r����Dw1R���� ֒��s�������Q=6�˺[���H�������ĩQ[�exl�������{+^XR}��-%�~�*���^���:r��6�>��!�weKPyr��kɏ�.*�%����;��Z�����ϊ��[��Z��
^�Z��,��A����\���t��_Ժ�>��3�MyZ�Ny���.S����W���	���D��Uo����r/��A��λ����h��(6����А���H��g�\>�R��dv���"ܦMጉԠN��ő�w��P���խ�"{����n�1E�,ɮ1ي��%dɖP�,!d�.BRY��]�1cs�:�~�y��?Oݯ�s?g���~�?߿�u]���\7����5��T�!�򑹧sv}Q�[�����\YY	@��hy�sO��b��s�/���b������5�l��K��/�������c�o�:H��! ���p0� %@�x<��	��������_^��G/��#�C�����[�=��I����������U���S� ����;f�d?д�����~���1�X7���T6�v���6*�?K�a2B`��x�������ӗ��ڛ��yZ7���C��==w.��n�(�C�oj���y��kƚ�ҁ��ܠ�J�l/��
7E�ȏ [J��Ne��o�?���?P<���	l@xH����@<B�m�H��8�O�����,��_rX�?X��3�?	��?���`��ϯ�0����OOdg���1ڽ�ހ�hٔ�g�O�.���MlW~���C����'�@�Ȁ�n⨂�k�Ls���z�훗xГ��F�{�|Ƒ�.(N�֖L1ʹ���[�l����G����! �"��X(Ć ��#pHI���f� �������<K�Y�?����$�?��߆}�������N�!X h ��1c���XF��7�'-��.I��hW�x��1
�\�5б(���
у�a�G����'���2�ZO�uI�-h��H8{eo�_��o\ep=Wt�ݲ�L�P�0`���Lly��~�̭��ѐc-i;�W�}'��.�Wz�L����;��+�M�	�[�lɌ����jS>V�Nw�,�{k�lՅ�*,8Ƨ�-�(�|�k�l�u�w%R�2ù�WǏl>Y�֓���&R̵�͵��=��5?�����x�R���O���E����p�$ݳ��xSS���Uj5_D�.~!Wd,L#Y��da �[����z��5oK��\#������K,?�G�+��5����$�oܖc��sF�n��m͜��5�+�՛PMuc�vH-�)�P�o�#�9ݾM��(go��Z%b�n�&+�S�H6a��4̺�&@����#V�
=�W�o���p��MKa\Vϻ0��L�o["�@3.(�
��yѥ7i�_���hz~+ɥ[������>��h%1�F.w�|[ch�}J�3Q#��e���^��0�0Ҷ��z.��r�p�v
�����7�P������P4vO+�����n��
w��˟a£	�����m6�k7�Ι�Qm/:��抾^���z�)�����'���L�K�˩m�#ͭ<&a&���mAo����������bq�g�Vk�q�`	&`9u֌�`�dٮ��GY}-a�V{�0�lm_���0/�3�k͓P0G[I �I���݋%���A��N>:�mڥkw(��͊B�K��Ju����Q�$���6����v;J�F�ԻfN�I�O��R��m��K�Z�4���*��LN6᨞:@
B��{����'���{k]F�E�W�F��/�y5z�9��gkL�ԙ6��Fk
^�ޑ*�֭�Jz��W�� ;�^-��VпU|Q� ����W���ґʧ�4�b�-{�y1؉~�078ՙſbn;wT�Z���p��o7�X�ڝiC};�q$�5��=���9��HQ�	(�|�KWK��s�r�-?�h"�7�b�񄣶o|���**%�ܾ�2i�gK�;����9����#��� ��D 1�K�}�s�Qi�h�q�B�UJr��*�C����
X>��u�k#�i��a~�s��g#�?� �y<���x0��H��ĥ(��M��6F����i�P�p������)|#χ���_�?��T���.x7=ͤ&���Z�l��?;�Q[lf_��K�Z�+��Q�$o�᳷�����vp9���K�W~������
��B�VS�H�[�
�R�V�L���|�i��}��_��N̷�L�p~H�{E�$K���
T�f�`�(�ZTZ��>�!�r�N1P�(1�,�Z2T.�5׹񸎺�uխT�e��y5O�[�Be��=��K'׻'Q3���\u�4	@��6ɡ��)K&�wl�)DFԐ^NS}���̼�4���Y�L�d��^��H�|�]�^��hm�ud6�z7.�QS-7�����	�u�b)�O����Ib����gM�����ȞY��Xj��}]���ўαBU�rĿ?o��m_^�xR/�7�K�P�xl��%T����b���mF��'�vIO��]My*u�� �v�-Th��9�u86�#Oԙ�;��i�a"wu�?����W[�����围�|��~����c�5���g�����:�PX��T�*�Y˕�1�Jߴ��W�i��f|d�o� ��5�K
|Td�\ty�4�氶p��������~=)�)��!�����ժ���	p6�^��qN�����'��Q��g�5p�� vt�tfw��L�����kh�kBk3��=� O��o�vxba��%��ȅ����$�]�J���*p*c>���:_5�g,�՘-q��خ��nu5�X͋���s�>�{���֌(~���h�����r�q��QM�����@�9-��nn�m'�mr�j86��A�%N�	n���Sw׋FtqL�KKZ�4J������
HI
��8�Vr�4d�����n��j�z�Ww]�U_w������w��w�w��6c��YgG�n���^>���y�9����R�(��돦k���V���ų��e��[;�!�I����[�{��:��c�s+�h=59T�:��H7���`�0#M��X���Z����r=e?g�I���@?����s�J56��M� �����v�
��( T5sK�0���[����ŗ�w�\9�>�&k�l��F�_!�$�c|az�Sx�3,�]�еqB]����G����N=��D���7�o��:�U�=���
�������N�_?[��N�ß�O�!�6��A����_X��R�S����7c?Q�҇�{e"�߼�~��ZyV;��J6�bL9�D�CS�/x�~��a�0�H�k#�>���-wzIq�H'F�[:��RȾòB�G���}z�n|� ��i�2������	*�0���2�1*�l��6UT�\��u��\���v ��"W���B��J��P���'����_� �

����F m��$)
�����<�����?���/��4�����_����������O�����'�/��bf����g��{y}�����*�l�4�GOF�D�H�6���VL\Ǧ��Xsl���?����"	F �2I�������������X��H�j����w���O��t����A��������i�����e@��ڿ��D-��	��Z�Ke�Ў%�q5n��:��Y��pe���7��I�OQ;(��:��H��7��$g��u�N!����w��BB�@))k h�%�`k+	�o=�[�a���(��&�
vI����\
�ޭP�ٗ���B�\go�5>��$�&�q�ȚX�ш9k$|I�8:��-$���y]�fӸ�d���ծ�$�/�ctY���� ­���.�I��FJӖ)M�3������ӽk
ӜYf�=d�X�\���(�pq��3F�z�f��(�G,0��Dy;�;�3DŐp�[I���<gD@:[��Iu�ZZ�%��ɳ��6�c�R�/M���f�ux�S������������J�KG��N�]�ɱ�Ѷ[F5��e!��8����FB��ywT<h�b�T�35U2��u��S��aI�y�d�sp�'��x�P>�izSA�:l����x�d�ʬ�K"���P�����[e�񩳢Ъ{!�,�1�vf�*�%o�e�O�E�D��o'>��?'U}�i
�i�-��4�����cI/a�ݥ"��s�5]I�ki���}���&�)�ѳA')�AJ�K�1J������vQdV-^����³5mn x��u��R��^x��s��>D��Sw[}���P����z�C?�
�r����Ǆ/B%�*������ۛمl�_
���r�u>�9�d�7�"���A���L9�� �ڋ�V��r6����iʯ�	��WӶ���Ko_�\�*��3d�p�V0h�',����V �_9ӝݝ:��|��[�=殡)vMQ�pb��j��=�*I�B�B����i�bJ�:O~����r�V
��%2���������cu��ha�5��I�j
����6٫���}x��
�*N�[�U���!��I%�ԩ�9����_���|`xi�$��e��;�>�q��ip���W_Y�Q/�ŔPǃ.q����%D�2�TrDX��[Ă7�=�\��0$�a�kxF���u�_Bg>��'��"Z
���M��rDY��}�6��|5rE�j��	�f��J�d��h���,�ͼ�;=��"v��y}�Y%��7D5o�t��s�VM�h���>!2;��_`����s.�:�ѭ<�p��鹘��["��TlS[��I^>���7G����bQ]5�(d\՞$mWfA&���S�f��P��b4�ɹ��C��(=?.�����mO�4q0���cei��Ц��|�W�rk^c�ʢ�j�0:�C�c�=�{�*���';T�c5Gm6~\�ӎ�`��c.����|��M;���r诸��o��
�b�U��cRM��[�ӗjH�].��}V��[ʳ�Go^A�FI�9#��6:���g`Ysv�
�G\�ɊnK�$�JX�]�y�_�gP�뺆D,HT�  ��i"]ZBM��PD�҂JG$�.]� BS�M��i�z����3g�������Hf���W�z�<�~�J����}��Y�3F	�{�<tL��R����c��
ڨ�s}��.
�/��8��CWmx�xu�~Z��ܷ��z��ˀ[!A4~��X�Ņ��D�jZ�fnVϻ^���ױG1�Л���^��7������'O|N�:�Y����{����hI��%9WK�'=�.�{_�-�8���+��Q�S$��2U��eT��nr���Scq��J!��7�T�
�]��]2�7t���{��w�Ć;��wR�_�4�$չ���
�4uآ� ݟO��lX&N�u(��� ���C1�D��c��&nM���]6�ڥyS:��b�p�_�~V��F���'�4LiQ=���׊�����������ڡBFQ���cw�/uK���"W�sҘ �^"���Ζ�ҭjCqE�{J�S٢���a�M��3�o�}&n���(?0�ع }/����Ԍ�v��b��A��5�"W�|��dx�A|�l��S���Ô�Џ���܁э���8}���P�>�attZ��:�?V��^����ǎY+_+�����^���;�lz<b�:������5�g���"�5���N9y�F:�.�!g�i�@�H�UW3d�ڄ�iƼ�Y�8t.��N�Fh�n�7�ݓ���7��Ν��V�;���A>�X��8��P<�ET.�D�9(r�����h��pl��/S@ץ�ei��>d���̵��h���YU�ѨW�=l2�j�-̻��N�C�Y�'Kdis_�O����=�_�&^��0yMn��~Poo4�+��=�V�S���DkU�k�䩠w���L�(�&j��X�ey�������K~�Kb�rEm�,ϊ��S��*
g�46��<b;rN"�q�r ��M�4���ҟ�*�K�oU����?����<��FA��

��8S��p_�BA`,gf��������_����?������D��[��O��?���f����ȭ����������������~�VK���Q�3�ϝ��
��L�7��o��7����pa�G�x���]���	��c��f8����``�m����Gn�����?B!�(��@�h������ߝ�b�����'���rk��'��2wh��o׉cG�s��F>0�>���{g��q�cY�������í�:��&��qI�Ғd��f�7l�8��^f�����$���;�N*튑��?-�<�[�d�=e�x�ꬊ�md�4���$�3!/���j�AI�_��������O�!h<��� �&X,�m

��Qf �������������������?�7�?�����-����� �X�� �?��~����������57[���r%j&];v��u��9��$-[��r�X/�Q]��6��)�<+�G�����O�h�>~�{.09ۢ�~s�P0��
�����"_�+�
�Cvu~K
O^ॢ�fU��#sF��Z@T(T���\]e\m4�3�S�+tujT�!��^ʄ�-D��ݰ�u�9$B
m��&���)��OUM�&x��� ������B��j+v�BR?z���#�����+����6D��%������6�[[�c�Hݷ��������r����g1��u��Ti��K��v^��S �>h#b��<(��<!�)Y�\L��307���i	`��
�w�G�iwx��ጁ�ƃ�ךZ�	�*��{��!��.�9PAi]?|�Ц��Z�pF�>�D�g���/�֧3[L��s���	��3壬��6���)/����F0�*h�l+���e��ϖ��
J���sz$S�s���H��kX��E'zj٭ȥ�u!.���h	6�w�0Q�p��hɹ����}�F���:S��Dx������ |�*bp�U���x�b	R��*c�9p���l�Ƣ%������dU=PbM�Ա
���ڤ��D`Z[p����O�Yd_@܋�̉��!V��sY�;t|�X�[S������+7�U�\��'�K�uu��6�ި5��mt�}��xH��7�+���t�x�&�1`Sa�a
� �< 2�Ѿ:�5���jwr�I�ta�+C��[s�#O�w6�d23&9k���DF��VǱ�
�R
W�L�!^i���7θݦ���dkRg��9�C���h�i�"q�E/���c�#��l)�kk�_2�B��h����%������ñ��R�v`3>+�.TF�u-���@����L ��L�����+B��E9t��5������1��BI�ԚC�`�<����=�DK�%$�'6���$!�l5�3C�D	���m+1=����Q!��3#z�aξm�u��w�}�>k�u��x�<����|���>��Ch���(�Pۃ�/+��|����|7���C�
ʮ��l{a���FJv�w�ٞ��s~��as�A�<7��0[CDO� F��/���+�%]�ٰ�|�)\�QL]/'�ª1bJ&^Xe�Bd�x��Y�rci��;ۂ�W5��yqu�`(����vn���o\Z�|�b�/���CRO��Ə�̿�Q4���c��'��F֐Q��o�O_���i���d
Cّ�mʈ�S
�
|�u|���薖�FK>m�f(��/m8S/�c�����>�'��b���Z��A�5��
4���$@�&�dt��
���9M'���[�^� ���������̸�Jb���B�宠���/���(Xz���**�BQ���:�}��kgH�V��
���{g����ݝ����6a;�
��@�j�=3�Aǎ��ymE�a�֦*_�h�������lj�>E���*s$�q]�dqו}�ݗ?���!	��r�s��;�y���߫6D��v���4�"���#R�h
��C^�GQ]��
�X٪�-�ȗY�BnC�{t�c��,�kC�-8�AB�2A���Ӹ�}C3���@��zf�L΂,�ZG�54�oΑ�aͫ�5 ?��H.��O�_�T5��~�>��������C�T1o�^�G��LA~͘ު�#ץb��ן�Đ|T�G�&W���Ux�V���� �yw������`�t�1���EΟOۼ?��)�V�#�0�<�RT��()����@P � ��������T<�����߳��������W����w������?R8������?�?��;��Ɩ����Y�����(� `y����(�$� '���
�_�r
N9���� �"D���?�t��g��8� ��"QR ���V����=e��'���#���k���/w���Y�o��b�<�L�8�pZ�aw������l�����P����T�{ ��#�����(�޾X0��M�3ȷ�3U��CW����V4��K5@d����"�J����ҠؤͶR���؟0�ߢ�է�ݨ�g[���(����8�C�͸��!g�F���X,�ƘL�X$��e��{�-i�h?�+OM9Z���<p�D�\j�̿��õmڵD��i�HT*�e�~��u
�����7�H� *��@0����;*:�`į�#�a���������z����������������ߟ���?��7�����׉$�%g�	'��:���lg��$�:�k/+�>���������FXb�y�Ή��0>>���N�
�݈���3g��qnt�"g��g�^N�Q䓍�鐖��`j��a��~`Y��m�8�C(�>̙�I����ZK�A�J���*����͑FgA�FW
7���B#i�iTh�i 	>��嫸�N���b�����yVB�C��r�3�2��u�
��F�fZ�  ;O!���ߓx��Q=q���:��.�K>JMd+
0�>q�^�JVbM������1و�d��_ope�;r!"c����_ȂK��'�Dv��fԲ�j��s����_����Ta޿1l<��LI��!kk�M��Cx+ǳ_ a)�������f�M
�A3;��p�������6�n�`Н���aVN��*�n�Y���k� �,������O��	�>.�QI��y��)̒�O����@�w��+*%1/�v6���\�@�@�o��4i�؎��#��m���D�F��rx1vZZ�=U�{���������&UR�D�:B��"T��|1.u�1r����%�!�Ψ�|�T|)k���|��z˓���*wykzK����9�yf)��꼟	u4+G@�"�c
��Ij��ū�{�ʓ�2#6 �9��w��34Z�j�S�� �����|I��%�R�n��j�歧��=�I�H���#:��н��ĨwAN2+���}���X���1�)��qA�/c�Ж����v���w�J.��
���d3�V�������[���
�g?l�4*�8�t����m�:Xg-�ML��\�)j�Z�&l��o�m�=pv0�?:�w�5���؄�Ңl�/��/%�7Bv\��t���l��;�>���VB�H�s>�6%3���)�>N,������~�'�F�J�]������n�������ˮ�PO��!�C�#��lw4M�d��z�^�����S���P��]�{0���	\��[��tKj8�`��y�?�E��b�؛8�6e���:�@Q;d7y�|�-�{�!6!������ĔZ����5.�2�lq��4^L8L��'��{J�s�Z�|uN�6\�y~>��D���8�����tv�oCa��
0u�r�^(<�b���7�1�0_u���+m��r2�<_?�:�"}hV*�G>R=�O�u7݁�g�Sen�H�uD��Yh3��K~�*Oۏ���W���~��ű��27yu�]���zFW�j�S�L�+k�B��!g��c�~lkFj��I'���.�e����Ydp��i��}#�/^W(�盺���|y�3V���I�@�������t�� À����+�X�
1X�c��X��gjb�ߖ���}���f`�B�C��(O�8,�T�F�T���a�E�Λ�g�E�SY΍h��=��\v���YK���
�+u��C����w�C��J̾���q�=
�Eτ����E`<l�"��p���L��=n%a6��E�(#Re���6=�i,�a�o��
�ˊ�(4Ǐ�V�KڇY]t���׭������,�W��b�o_�Lyns۹��J�ni�dtE��X���f�._�4|�@er�Hw�?p\T\���S�Wch8}DC	�j1�Q>��;�s��w6�^�L�1B�p�ܞ[�}T��U�bH��m���3>5`�9�{��R��d�0ąT����Toá\́��Zd��I5�$��-�Nb�+��;DR��@xU�%�y�hn�,R�ʚ��ϯo�q������������ڨ�E��ɷb��B
آ�	X-7߶�k���h&��342A%�5P�V��$K���'b����sHkǧ��Lda�5Q|�#9��.���4��W�]}��?Ih���/���E:���l^����������`d�g�GJǙGiύQ���>7Y_�lJ�+�rY�+3豖T$���r_���[`��7k�����_��dQ��C��u�R�+�YeL�c9���/h��E�E���Ԃ�զ���'U~�ߓ�"
��X��M��
�p�Gf�'oF�Z��d?��ɗz�̎Xj��R���U�~���cծ�)���HJ�D��}����4�S�؇ڞ��KT��`C{}G�i�ɮ>>�$
=�ie��%�V:pN�+���4i���
jK	˺C��Á������i��0�YK�&�(��Ul���mGVD�s���7��Kb��෌�Bnx����h�����uhl�UbM�dºXa���l�� +|�}^4���s���T3G�$�F͓C���)m$99O�_�#
�!�U��+O���F��Y*]�oʑ�0d���f���
�&ƪĲ�fo
nY��wB�J�+��/lJ�<�G��&F��*���U~�,"���ؑ�ɳ��Z�JY�
˷����S6�?W7�N�L�9'&�FP)3�@�D���=2��U�M�[��0�{;c����n����Ce�G���\6�կV�^���Y1+�3�	�A����I6����VL<S|C��n����{'�hiA���`�׌u����}��Zl�_YWQ.��\�t�C�٨�!| �z��Md�妏��)��ϵD�rp���ԫ^���~Am��#�
����ִ�@}ޞy#�5[�T�B�b�1/܏�̲TJ����
��_b]b�a�X��S�'Qngr��UM�˸�dk#3(a;����0_�>gz|�8)���$��oAa���ʺێn��U�(�w�yDj�d0<Y�����u�[���Ч���c#�%2��`y�� �1�
V���Hڻ^���ݗ�ֻP,Y�ֲ�$���_��*�|u�لKO	�fH϶ė�ݢ�ytwx���&����M���ٔ�U6�o��.O`�s��:��>b��Ĉ�}��	�X��
��>u�a��"�E�Y����1!Q7��VcclNUU�Ȯ�Qr����I8u��Ώ��m_ld9��(
Y�@]P\�8Lb��xx=���}\��c������Ef��(_�R���?WgŪ/*rO�L1��gE��0������H��T#�V#ә�o��1O�N|�oE FH���0�G�c�W��e	k�d�خ��A����Bw�E��Ζ.a)8|�
������H��&�%o�i�m'�/_��Y7tA��K��I��"d�w�E�m2���/��W�Rҟ�v��3���ֹS��<w�j�����u�����'t����%і�)��gհ<Ѫ��
Ys��	}��$PQ��W���X�!����'�1�5���K��hl;8�?� ��k��"Y��� ��w�품�E�/z'���VT��RR�|�,�
�GW]��W�^S<���d�yU6J�j���;�G��)���+��t��W���ڢϸ���16yPd6*������𣬀��u;!�{8�Ì[Y��H꼢^s��/�(;U0�+�5�kݳ��e����R��lul�`�?c$��-�{�J�.��n�cj����aE/Oޑ]���>G�7+��ms�G8�]��{h�;����g�Kk,Ik��HRTꥭ;�V�k�|[�4�g�W�~�X@g�[��!��k�<�I����9��j�����G����_�T!H� |�)��ڳ�0�ș�j3�x��a��_O�Ȃ��iVɋឤ}��̏G,
غ���4�=�
0��/}�ǚ�]���0ó�qԂN��\����Q`A��`RK�}�K�Pf��yۗ�JE�[_g;�l���hii57���T�f�tU��?�1x$WX��M�.�y�`�Ǩ��_�0ao��&zWy����V���s�o8]c8��������
�y�K\i猷[*�,*s ����-a9řř��{n߶�c�����bܹ)�
$?��M��R/\���n��~�_�v����ê��c��(�^���8���rU����9E��wf����i�G�{;Y7���Hb�}��-M���l��tK���w�e��X!���,�����3zSvh������-�2����b���W(,��F�/�>��G�ň�� ��9���YphX#!�M7��FGJ��7�X�����
Z��q&���4���eW$x�4*�����{ʼ��JH�S �d3E|ϖ������l���Q��٨A<�ͧ�:k�p�N�YaR+� ���O?ߕp��H��*����$��(��T�̾c��WĀ�J��B��������U���ks?a�@)MEzv�	�<������E�7w��,Z�H�R:�������g޾�W��Xl�>`��͋�3V�uI��,�W��A��-�|����l�l����	ǷW���16 I��][$�z���]�:�k6\)��*2���uu��y�=���­�Zs�:ă��4$lő_쀺������?�v �08Kp��e{��p��%QtR��%i�B	_�����>�"jJF��mS~G������L���\ŷhtYI�$�\��kH�5v��0�q&�����d2J[�~�K�a�|jA�e��FR#5���1
�\��kY���42�!��K.��ٙ{��'o|4�Qr:��b�#s�i������+�0I2��'ݝ�N	������Bk{#��3=R�Zn%=���|�]�6ϋ	��$�E]�����x/E����Uу#=��Q�hy���w%N�v�AC(��S�VYy�h=��K�~8����i1����v�;3���mL�P�i�ki��>B���{�d����n��2zx������Gʾx� ��;�<�sX���[�}"�6>%G��f���/.F���m��3�V<�w_8\v�E����H@9=�T~0�^,JC�	����cY��X�$[����5L��7��SR��60�\�&��ct�:��j��|�����f�CN�4a�gB�L����ϧ9�6���;��is�D�P�e�)Ϯf
����ʂ�d	��f��n����׼\9�\BYg\��KG�l�S�����+���814s��0}Y�)��d��/!^
4;�`T�+�{5�Vu@�ܢ\E�!���<�,�M|�^J$L�;��v�C�===�{�p�Bf���~��05�1m�����(�,�Ԅ�0m/o��q߱�㫹J7�Ɖ���m�C�r�X�A�εU�����]V��[7��7|#���וړ���h
�[�f&ls�U�m��=�g��B����m��s��2�B���!fg�V�^�u�{C���	�3+N5�<�o�s�P+�(��v������S��^����=uc�w����㏕���e��nJ^U�V�1I[������*���g�w��"��d��d�Kff��Z�oqdT'����Aﺭ��{)B	�\Ru\{��T6Sj?��*!ߌSp��ƞ]�t+�㵔؈�*_��+�5��1��x=㘢g�ϧt7�)}y���9ߋ�I�y�G�5����b�b������EQ��v?O��%l�����a�wQ�y_v5[S���M�����^�("�T���
8(�����-���桪JQZ�m��`U���
;'a����T���b0!�m��	�
��&V
�
�b��F��p���.n��-�	~�U��JL1t�k�#k_��34$X�7�n����2���Q��D�ہ}��L���b��&�y����E��,]���������T!.+u��N1^
̗AtF-LX6XY��v_vp5�ݵj�~�HZ5��^�ϰvw���tI���$ژ�Yh�d�q9��>1w������o*�,b�ݷAp��T�]پJ��7�r��q�L�-�>���~��Eol��<��OчM�Izz��� ��t��&�9��� ys���fN�9�jp�����8��{ƈ����jE^����Z�rK�3c��"�@U�
,ڹ|���1�|��vb_�ş�;r:^���{p���ypQ�����y*�{�h�R������b}9r\ѯ�=�Ta����N��0�V�49�
�n��JI�oT���"xg�y:��~P��C�X���3dt�E(a R0f�t���tO���5ų��z�"G��;��^��D��Dv�f�b�=��t��xͻ�q��'<��梛�
���+�6?<y��qK�P�;vj�lW]��R����慎[�
Y�̣�,��=F���HymJ�_�4���L�n�Խ�&�p�3�UK�
|G�;2'��(��֦��Əv	��<,ʹLPB�{�>������C_��	�����ѧ)��&�Ls�h^�$q;��������v���M�m#�
�瞆��sс�Y[(K��9�am�s4���".)�K&r�!���#�~1���=¨��4�<��[&Rj���c��H���p-����"�G��7��� >�k �F�7�rHXb�:?�A�p�"�j#��ʹ�ěg�������b��7cTV�"���\����~�����I�8H�n�6����K��u���;և���OT�N.�8�y�ew��Ä[�3�n�d��uɂ
�G�����aZ����b�P9��
}Wep�i���P.���̼-;
Ņ��9�v5knO����r%"��Q Y����R&��fS��.T�i#@���K���ߟ�R�4;⋬�k���\�u��hыÃ�H���w��jT2��=�M�����!�km*��P��k@�nI�BH܅�ڹோɢ[O^�������U�L�'l%L���_���ߦ��D36k��@C�S�֌T�l�l�aQsj:b>���^d���=<Y��7���c��ۢKܾ���>���o��+�S�.��i�������b�t?����넮�שe��f��<��[��6o���=����Y�0�X�sX��F^mK�ѷ�˕_�UP��h�_��7���^�@�b3��yT';��@�j!��f��������72$�һ�Gu�I#������D���57C�i�������C[��
��Ni��$���}�|%��G�R>]�V����.F��H.&����/����;�=�>�e�';�|$||/���&��z�dMNq����핐cS�!׭~�����v������1	1`�	z��D����U�0d��g�����J��uqq}�x>|
(~ko�:�B�̮�`U9o�º�ݚ�d1�4ٯw��:�~��}�#;���]m�B�V�c����o���jˌ������`�b��\@���pmD�o��KR��T���%4z��6:��J�h���J�٥�7�e7��Qg�o4�,b����T�k�6�����Co���^&^k����G_���*����e�9�"���ݛm�\n
�(��3�4��Xmg�(ܯĪz�5��6�1���@��=�y{��adL���]δ��p$���������&��^s�m��<�s��՝H��3Zoɢ��
F�B�5����[?��l�y�<m�7��l��a!P?�����!����ⷻm.Z�:��x���*�����J�\g�W�"������� '��A����v��z�=��6\}e__�Yo����]�WD_�8�Ym���zE��i�<Ap��>�
-�f�}���}�\��|��_]|�0�OZ��I��h���/�f���¤�ޗv����@�}�>[�:�Eh�ʢ�>���<,�	x�@����Ix/=w]���A}������"J�7e6��+x2W�bP|�ms�y�4Z�7f#�>6�t���1W��������;����c�C����C�P��^��ّ��E��
Ϩ�Q,�U�����+L�\���s��
��89O���%�\�8�[|u;ˮEV׌�&>\���d�hц�/�Y�VPs:Hq�]!���a�ַ\�I�a�&�M�G#Y�=&{؝��U���~+�1 cH��=�H���n�'����"	��>Id�]._�m߱��&���(2q�ԗ�q�>�,Up>^aZ���s����A���nr$��w�GHp^c��׆��~�jﯺ?k�=��}
��B�;�e�/w�ND��_#0lC���(RA�uEV����v�~�a�v���|��������j&���N��E�Eކd�!fr�=w��g1�誷[��"��,l�g�]�v'��rD���Y���Q`�"E�v��#�M�h�7���:ax
R�=}w9L��l���k���g�<��l�;iQ�h���-
�;�?
���Ĉ��u�1Z��Y+�E�V�)�������(R�m�M*f/|37vD�6��lG�7�0-N�Th8bO��-��q��@���D0��3}�筦�獹�ލ�ư-�A��m*K)���ex��ji�_����CU:/,���Z��MM��_�12�.�шb��C�=I��c���Ò+�-.�j�[�D���o���y�90�V�i��3�7��~���uu�f��^-r����q�~̓G��F�9N��W�#�zd?$ǒ���ld�����M���S2M�y�Z��������v��
�s�-�rzɑ;z�=m�b�j�V	���V|P��H�XM�Kc1?��,���_?��P}��'p�#��^<�moW�f�?����/d������r4 f@m����k�^laeR/�p�4����������Tq���S���w��^�������5s/E<�lW�Y?��,٢��ӟ�Њ���Y���t����`F�@���I�۫MXI
�0��z�t}����|�լ7��Of�Òp&y�rF�&^�w	rƸT��b�c�m�����s
�ܯ
����G���������a��f��m�����m�^ԝ��e�H�Z]
'�-���=rf+Y]c%5B_�����ܫ:��CNT���A�pL�P�r��w^3��6g����Z^/Y��W�kG(�
C��;#�>�:ע�3H�^���QDn��n{ .� ^2m��غś�]�����
M/��}��U�:Nq�|}̻*2�z�8 �wwqߞ�����ջi�jI��k��+�bC������{P�|]� �f��`�&�<(c����e�5���8<�����Ƞ�+�:BЧ��&�L���i�]4}q*G�:^0�
b�)�-V#��p��ބz�W�z��jb���1B��ӗ�ԾIX�4��uvjk~xh���!�s�E��A)��D3�4-��,J
~���͸�����������}��p��d������h���;�u2F]zo��'������W;t;�'�M�QoU�)��hg�y�1Ȥ�)��2���r �<JVZ���Bǹ��
�y=:Ro9�1e��E{��ƣ��v�Ö���g˻"]�Ra��d����q$
�/F��\[L0���r*}`R�!ĳ�ێ�7�i#��Jl%n�wh���`�ղ�N5rM_�¾�i�&,,�r��ռk[6���Z���^2GUmt`d(��'p(��F_�vOs5/)�mq�e&-�8Y<ˈ��*�U'Q�Q�HN�ໂ_`jvx��s�Dp�9?P/R>T�}&�|����{��=��&c����5�6�����Z�6��8o2o��5��e(P^tp}Nf�y����@�t���!p�/���Pi����l��6�(����&�N.c�zt�(-,w�0��<+�v�z�]r{K��q�2�.w�<�br4�:�;�b@D��� ��w�׿�rQ���glן*o�f����s
�
xD�;�>0!T�9�a�n������ذVq[���=�r���K�����&MU #d"�ɉ qn��&^뙰uM%	���9�����t�{ۤ�z��+�m�����]x���mmv����m�5*�U	Ֆ�	$hKJ~Ǖ? -������M���\5쿾vc~��)�j����{�l'�N<Y�{� x%Q�5EU5\��=v_ wG.����2���Z.Z46�!QH|tmz�<��֫����܀}U�WǪl���[�tM���]E�$��D&�]o����~�]���C��o��J��BB!-4~����[��j���m�*W�C��G��W����UsCc:.<��Q5��'��Wc���(��A����V�~7c�pu�~��ch���{�
B�!�C��B4���4�}��>�o�w>�\+I��El��1��u7��;E�%��cP�D�XT&�_3����ۃw'�ۯSyi������jN��D��L��~�XS��ɽU�a̘oK��dK�q���V����c���O5|f��m�^b��!�M;�;;x�0ex�`:�iG��y��K�H紨zש+B�s��)v�������i�h&�+�	#n��b�H���J1[���C�J�O��7G��b���A��.�7������������`FvUUFuuVf&fU6UFv0Ȣ�Φ�ffScabg��������.���w������������S������3 /�?����������|j��W saV/��m�����6�0�����S�gfbd�303�0]����bd?���������L,���^�������edgb��wV �T������o��Pe��W��q ���?�_����@�r����#5ݿ��3�^��K�y���U�����������o�0�ӂX�_� }m��Q���?�� :��������:��?�X聴�,l�̐ol�������m���������O��pQ��7p���o��T�`56�D�5YT�����X�YX�4�5�X�`Fz&�Ku�������
dc��8svFȆ��:��H{�[����/����Y���������3�1�B��3�������2�����`U�6^C�]U��AC�R������p�f*�����&�������L,�,�������@v6vZvvvfz6V�������������Pe��h�{��C��,�������C������	�o�����,����2_�����F�@O��@&�?����
���;O{B�wB�wR�4��{�����#}�_L Χ�'鳯f������/�z���)����?0�'��I{���yO��y���V��S?9881����?e�q2��O����+'^cx�_&C��'Õ`�?����@83�0g��G.8 2��p ��<Ga��<��wB>Ŀ��!�;�������op����������_�M�
 �������op���|���#�o�s�@֩t]���&&�& b��tAjZ� 
�B�Aa��1.t����u�|��W���� �!�
���
&-b#��6`�B ߋ�0�b�lA�m���mC�eb; <�у�!m	aAdL�1ݙ��K7�
���M��áR����b-�K�K�m*�m�	��ֿ;���)�>Cך ��2�iKO�"�ɾ�[����G�A,�X\PL��4�W������/�C�����*��sAe�\�`m=�.�B[
؟\/�O�>��9<T����_��3Xh���������x��������������^�b���s�O�Ϫ`�4�y��~�W���G�8iw�7|^@qؿ�I����k>��?����'�����S΋�xR��������7x�o�$���Y��:Ϊ�7|���a�j�WS�g����̻�	�8�?�����}R�Ԟ؝�Wa=/2'�v��R���>3���'�I���T������op���s��
2����
/�B�+�y�
�p��Q�yx��H�st?�s��f^h�|<�Ÿ�s��g^ W75i��C�G��bh?O��8�������~v.���92g&�#$�`�s���^2�'���a�?CX��b=� hM���TT!����T���lb�504�B��V�\[O�F[��xLc��	�Q��b��U�6�������,� ��j��]tTE����v�&�yA����H�a�Ib'��De4t;����8ٱC�#���
΀3Q�au��q��ǂ�;Ξ���qf;�H�6
�������7@�3s�S��o��_�[=�j���!n�#+��Q
��qѾ�i���i�|uo���?j~ٟ�ym������gj~:�z�=��
�ş�"��D*;Q�;�8w�ˎ��h���������C��(5.�ίBuAZ��;��a:Nv%T��4��8>���q��R�%F&�,���D]iqx�:V]��	ޙf��+���h4)�ٙ��'c�{��&{w�ܮ޸�ʙ�o�����J?Ꮬ߶K�s_���'���\���-�i�ުn|�ț¿Mz<}��siO��u���'U��2՝INZ��̤��>w�q�o��ݘe͝��O��R7���	�T�6�NQׅ,m�щ:�\G{t�c::EG��i::[GO�ыt��:z��uM�:�k�5v��b�C�|7��f8���J��8y�=���>|�4�����#d,� iA�G.Y��d�� l�-�ч�X�>t�Їɮ}���
m��ސ�NʋimCy[c;�?���c��hlO"{���[]z?���ƮBۘN.������QhK�D��ߨ�ũ�| FZ#!�*���:��ɢ�`b=P/`�rֹQ��5v|�y�	�7@~��O��n�>�FU�&�S��ks�oU�"B^6�u4�����:h/�S����k[,�q	"ԅ`k����B�B��Y��Y�n�Nw�6��1�4F��@_vo߆���20���.�+w�r|10��v9J�r,b�!B9Dh��L���.�<A>�0���s���b'�A�0��Oh64U�W,�d���S쪣m�&�@Ͽ+z:�R�ת�.�7A|��:�^���N���رV���G�'��ј/��ʢ�r������<�
�����	�.�l��р�Ss^�pl�Yd�����ƺS�>�w}��}Qz��\��|n>׿W�h��u(��=�g�ݙ��*��ƨk,��Mz�J#n�]XS�Z��S��8*�����L$�Ǘ�rM�ܽV]��/��C<��A��k\c��>�a��=��a>��ͭ���S����}���k<�j����(�i�V{j����s�j��F�#O�4b4�4�&p)B*M��t$o���hn,��X�}^�1��i�L�´�c�n�V6��(���`�5Z�Ix'L+�l�U��F+�g�0�l~z�NׯB+�Gp�E���/�V�j�0���>����d�V�L����rZ�N��ּvJh�h�5�
L~1��!�9��x̏�]+����V�~\4=�i_�X_'F��$FǗ�G�/����&D�tp�ؒ�:!Z�9��C>�����c���p|2i��ꐧ����!�|J#�����4�{i�?�П���GQL#C���Ј+��
D���w�7����g޻��0M_�)�á�[�)��=W
7�� z+#�$J��(Z����:�U���u�K:�uNi?�������gʋ���Sڣ�����,��
c�������+����2��W�W�(���:�R^i�Uj����[r���W���|4�z>��m�����o��C��>��p��=]�G::
�:%�y6����ƈf��7B�U��R獀��٦��U�o����P�zĤ]��µG�h5D��eA�z��]�Ĵ�y�5(lT�}|���A'Ѩ\{4�uh(k4���.lףi�Cc`Yh�dk׃|�����뇴��1 ���F�^�:��y�PO+jo�UV�5Q�쩵`���a1��l�:�b���Yi4�T�*�1|��¹��|,��b�R巡�@�1��F3+[�2g�,��nf^Yc���bFqM��z�ň�c�����|l�4^��5 ޹u�@�A�+R׆!^Y�k�N�o#���1ͣ�mU�9����u7��DW/1|8&�@�������\�t�1��5�^p�`�C1��T�<눆
��[����C��1�]0I���O�=<4�2�~������⑧qf����`٪��+`�Z���o���6�3�`zA��`Z�Ap�M��w��̟QX8c���l3�������X�ˇ��i[+��j����W�W ��?��O��o�?����X6�!�=��߁[
�\�5܁���k�$��� ��?�;?���
"��� � ��������}�(���|���g�%���^�*����q}���}|OD��"n��xe佩�07�6��Jm�~�5���L��W��,k�ǈ(�]c��e�r�7����f��o�Z*�4���Ɉ��� q��hZ���G�I�!�'dVH��Q��p!eE�q�Eb�i�����*����`�xJs���g�[t�w�g������v�1X/��ٗ��mNC�4�[n zʥ�=YΊ`���m�l�θ�A�xv�N ���Lm6�1�X����o�zw־��ý<�Y?&�膽�M�	�E�]�����e��@�}1�z(�[UE$syUfm�si1��*��X���M�Aj��H��gZH�L����`�|]AX
�S!���X�w�����U��*_�u"�%X'�������8h�/{i�p��[ywޅ���*BP���З�*<-�c ��(9���ޣPcj���Kl�\�BI�=�C��~=���^kZ���L�}<n�3͙��	��2��ZB�����L'�+.�"ٜ��'͔��2�<r�5u1ؚ��	:�@Gj�e-m	�2��QB���İ��(���;���RfS�z2AONw���8@Ƨ�����SK�\i!���/z�6j'��	�H&��G�$&�⿳��,wNtr~�o�D���Ulk	��iyT_h9��������^wyZ�C�j;��N���2�����>����������A��ޛ��U��ޛ�����"��w:{��L6�1���q~�� P�:����x�������������o'p҉\�/��N&:������N�m���/��4������u��n���>yLM
�vk)�ܽ�8r΀e�~����5�i[h[�`�Wi]�Yۡu}�L��g�XS¯J���=���䓧�o^�)�ofL��T���w�RyRɈ)�]�������1eT�Ǭ?N������'U�z�����GYT��X���S�y C�'!��s�|5��'X���B�@b$��ɡQ:���"H8�m)�`߃�*9��7�9 �
=ro˞����[٭�$�&�Eh�z#@����n�Ǧ�
%�c�Y�n����"?���2/��~��
��1��s7'�����m�d8�w��"��j�����Ї��yE���p�
��R�^�T~�;ѽ��R/�����O����B0�vf8���M���f��;fV�}&�T��=h�
���V���U�[
fan�����/k"���Kt&svü�%
��}܈b)9Z�6�^���
�"��i^�-rgQR
�3 sF�V^�50��;}�U��F<;������U4S�1\�X�j�m�HGKq/��ņb��X~4��aÆ�6tn��}	��jU�+�����
ٽ �������籜��ļ
 Z� ��?k�2/lպtk$�S-�S����т�~��x	�|�ǆ吀��뱾9p[���	-eVw:�jNK�;�^�Y�G��K og��ٲ�푑�ųd�2��K���C
�/�nj
ʽ\[�P�n�M��m#����r���#��1��_�����7c�1ڬ*!�Q�c3�l����P#-H�"s�m�6M~��ƒu��&��3���_gG]/9T�������Z%���,X?�^w���帿�ПR�#c蠾F�C�}��5T��'J�����}������~ȟ�Gو9]�9�^n��̑�Q�r��-�
��c5K��}V"�ݩ<-�Y<�=�����k��Gi;�ܞ+�D�6U�v[I�n��7��5�BLe�)	1F�T�/��mg���M������GPR}l"e�X�������K
V�5�B�y��9!�
sd�����Ι���)� �,�pS;�U����s��Ͱ"[��%�i��ѷ�������f�GdV8�1�C��v�1��'/ʼ=�5���-^W�2g�y)4T��>�U��1^�#}����y(�`QE�ԫ�1K�zެ�0	-V�jզx���V��8u�4�x@�*:��զ#�v[����fÃu�&��Z|Q��S �&�G��͋ŃJ@��&|g��V�ҥF�D��fZ��,y�� 	���� ��Wt��R��"��~�a=g��>�����9G)|0�
��z#����O�S�(��,mQ��ni{���%��r�.���&Ps��e��$��${5��Ls��W
��n�S�����Wvg��_����z�W4{7�Ѭ _�SG��T&�v[Zyis4��r��P���Y$��Ioƥ
N"i��S��؉Ig���;���b�k��/�į>��%��ݜ����}��u��<%I���)�;�5!d�>0�����6*�wN��1�op�7����������0�u��H3FuUܝ�L�I6�	&�4���S�:�[F�j��郋-c�5 �/2�8�1Y��W3�����·��'I���	�s�G:������l=�ůF��9��A�í�yy]/���!y��;}�d��Hݑy�Z͎q)-
�(�zË���)��}�v�o�q��RE���"��.�9��̋̏�T�_AĴp�H�İ�ZE�:�����S<bF��i	�2�c�o�����1�ϑ�!��AOf�3SMÍ�gGU��
7{=?x�QL�����͆�ht*+m�պ-���~T�iݰ�:��sm"�|���+�:�F�δ!�
s@V�Acȁ�ޟ�>l@�Q��&Q�8���dܘ�<#m儛D�����`�eBR\���{�Y�1��!�s_%O
kq+�(fò7G���̨�c2[����쐡���-�䇚Fu=�s�!p!��^w��{�aM�s:YK�+z��\r�ug�	?k��S��o�*fg�%{�D�n�$���P�	��&�dIJ$�z�h$]<�A�U�b��oZ�!.>���:�9�����=dw�B�M(��\���>�J3�
�7v)�iy�
��82N�Z���}�����H�$�֑��M�u�����Ca���+
�dp<�t� :�p����,�'��t���w�Q%����KjKB
2�8�-!�O��Mu�k�q �?�w�F�\�,Ʊ�/G�T�����A��aTЎ�#��1"��]�������\ߏ�LG>��x:��l��K�")�<?��FG�^?�� 2�J�i�ѵ������ � ��9�g���}�i��rh����0S��zCܨ��ٮSؐ�#�d���~P<�h"���V|Ex=����4�L�&��)/;[F><��O�� <��94;䤘Ϫ׾
���'돭�;�`�0�!��m�nCջo�{�/t�;�1k��G���D���Խ���z2=�g<K�'�j
z)n�E�Gtr��=L<�mzY'���-�IE�k,J"/qi?8q���t�݄�Ԃ�B�1Q�8� �=M` {Vk���W6J�i�`�<���$������<����s}X��,�>��}(i$b`�Q��}D��1��j|��^�w}�z\F8�*JT��]����K��!���IqR"A��T��s�+J�wj�y��c�_^+��K�D�O����>X�'
K�G�G�w�E���;I��%Ć�+9�MS I#R�,���i#
q��X��5�$%�_d�l�,�u_~^bɉ0��6��P%e�W�[tw[>]d�C�!9�:���<��;E��`�E����E܇|�YWu��{61��?��1�i�7)r"MQfENKd���"����ܩ-���
5e�Kz��	7(M���f��r
��$�3V|Y�a���jy��2#��tX.n�{|�s�"̑�(�I�Ӱ� <���8���@ܖ���a#J|�BD�f�KiVdF������{KF��3�Dļ�<1�ʹbSQ~h���y�H�� ﯺ�ŭ��40��]�c�X#��IʝF��8ex�j�p����1aֵ��X�Y�A�H2�j���e��z(��Md��ǘ	���&(�=��oQ�MX����F�	F�)�H��Bq���B��Ψ;�Z
T%�1���B��Г������NM0ɈC9h�p�/�)lZ��"�Y�M�'x�(��,����~��Ź��zEE�n�9��\�K�&��b6������Ƭ�4�t���`�>ݫ�#�hV���ҋ���'��w��#D��6�*OԹD����)2�b���	�Ps��5��b�9�#�S�p�y�Dz1�i�*
�|�6�����W�8���b>_�R %K�n?�>bT�)܌�{젫If��c�8����k>��xL�想�Ӫ���~��V�8y�&�=۽j3��JSKҽE�{	.}1�"�3���9�
���%�����r_�"c$p����	<�>3��� �p5R{=���)���6�ޡݮ��0Ǻ(*TO��ϖ�(�����z����c�����;)��|�7�򴀗&�J#x�Y����*��ΊښEh�^vA��1���.YmK4�֛�Cz"M:�s~ʇ�0�f����<�?��p<i�k�V��V#9��U����f���^�d��ҴǊ�@Z
��
�M�޷��A�(��'�c�p�I�p%�Y�`>� �(c��~��NK�?����,a�K$
�c����
�b�V��9��˦b��(Љ�gk��	�)��e|_����z����z/��՗/6f�/�iʽ�n�i�)Ҕs�mU�o��E�y."X��؈� �YC�(q���5���Z�B�ga�Ù2�c�RBj����P���C�y=���$�Ω��j�`[�>�#2��D�#?@�d��{	�/�G]"�
�_<K�!�ظ�N��~�ɂ�INA�C'����1�
a&�J�"�S3�n��|�8~��H�I%�q�
[_����~VY)s^�;�&�R՘|>KZ�i���8jū2�1���YU$׆�E�<�^������mp���b��W�T�oțan3������?3��]f0	f��M�Ó���E#�CA*(�{E��2v,����xR��qR��>|?�C�����p}��]7|�� b.��k��C���X'!�
5_�盓�UVT��@��6����@���O*�m�7�6��+*kV4��wK�ȟh��$Rk*,��������a��\%�B���9\���ģ.VV~Qi�{u!��� ��!|���V����
�?w�&��l*��yl�b8�4�tB۟���!O��
І����U�9������'��Z��8�W�#5ʲ�,YV�I�]h��Ș���,x�}65����9�޳�kX�V�^eL0/]b~���(G����yq��@��(�Qf��U���<gm'�;�����2����y�pD�+o�d�RQ��G��,
4� �@�����\﫿CD]�mѺ��/Άk��
$~7�E��K-����
���-����)Xd���I���V�03uj�Y��8
o��F�#��,��=Fb�O0��6���T����0�A7C�FEn��ҊbՃ�/&� �&��g��?Z~pV����[P��W��~�av2^lSŋ�5%F�/2����ҟ��/k�gL�&<k�=���;�(�����`�<��	�y�-��Kt6x
dGf��rA���]��.���Ddi�Z��
�o�Ȅ��(�I,�٧ki���eI��6����f+WkQ���?ڧW�i��`-M@Sn8b�`9�G���>a}��ϣ��90�(.�k�֭��e��B|��a��>&��(��"��?M_�))�I�z�q��2=OV�W[T��5EB�xV��A��(�ڔ�P�')w���5�v��s�dp?�+�a�^[E��ǲ��d�C&X��}g���wP��׮��ٰN����0ާ�V�	f��1�5j��?·�-�S	��x6r=�6����!��Y������=�� J�o��b���5�9�7~�|<$;�'�����z�A��@3�O�Z=��Ǎ��p�j?
u��a��MQfR�32'�yEI(ƕ�C�9�w�
9��Vo�Y��$J]�b���Ȍ�呖K<Ҍ\�%�g���(���'5>_�l���Q�쒚��:���%M�+Ӛj։�� �y߳z���#�ssC�j��M�J�f��5�7�7-޴���da���7�A�6}����$������ćg<�/Qr���/ެ�r�:���}q%Jȵ/ބ�푛F�V�߂=kq�D�̜\3f%8
;2���%0���=�,����@�|�K�R����G-��9�S��V�'��m�o����u"�[\����S�bG��pHwZ�E�7���s�{ֵx�N�%֗+BM��^\G����M�*��-/�%5;]�ric�1>^���{��7K��K��i��H�1���kC�i<���b����WS�ճw5���Hs�9b�ll�mWý���%�sK)�Y��%x�>ˮm_[@��}]��%��#avKɩvYi�z��� {�]�A	��R�l��P��^R��nF��mN*)b"Ab�hdX�lQ����\�Ӿd�^�l�jo4���B�[�P�O��5�:���tՎ���A&��N$�mT���U��ŉ�O�S�K��1�{����X�2u�9tݟb�&�d��)��%s��mj<�>|��r�PWK�xԁ����Dc������l��f.�s���V�D��sP��?��)4�j�϶'���\�E�3�Q��dQ\�}����QI� }ؖaV�Kn	劃�(�7�1ie�*Y"�l�qȓF�}��i��|������~�,3�����_a�:��'�Q���|��C�jĳR�,O�qt(r$���x��ܾ]G�e*�A�#[H�f=�Q})��q__�$v{�u�,�e�&�|��+Zso=�m��~y߮l!�;AVg�9vu�;��0UH��	.&ͻ�$�����+rP��c-�1�[�L�6�ꤍu ����-C҅ � ����If�f*���3쇊T�׿^���/�}�j`����V���I5�(G��n
��
l�~��ƍ���ƾ~
��D�g��a<�w����O��zJٌz���I4�l����O�����V*\-���ĈX������~�ｌjw�ۼ"���!�ϩ����b����+������	e%9��(���M*6`�g
���^�1����D����jG�e�V����:3y����p|����Z��P���l���*�{?�[����0+M���@*���2���ꕭ�!�Y�Y������[x��3�Q��E<�bm�v%U�c�js��ϯ\i"��:�Gu�4���­��k�­wX��B8����VFֿ��H�fE�W<�	�h�1/�$�Z?��V��<x��r�:����|4�)������/[�68^�)��[�r(�EC�����b}U{�Kĕ���PI��,�h���g̽z�� �N�e:-&��� O{�����
7E�������U�_�d�ڢ���L��*�k]����}�9їp
3�V�W�-7�rD��f��i�9V�H�'��N9Pri煣������}ۋ�Ю�"�:��9��:�WT��O�G_���{!����f�HyѴRx*���$�9�8�f�����
i��N,\c�Y��fļZ��Jk��
G���>�b�#�Lc�I�^|�]!����Y��#��Am���=\/�ƚ��l�P����/c�>!�s�����Y"�����9�㽳�9��y3�9���^�?g|�=��x�5�Ӌ��>�M����k�7O��9/RM3�8Ї-�$}ҽC�~��W��.gw@��?ބVx�xDIF�}��Jn�ޣ���XM	��k�u/������*�����i<�w��_g�����W>��y��L"c�[�
mz? }��PG�E���1,����A�o�}����A�?��ʧ<l�o��-g����Ϙ�k~o�Y�a�V,�������^����W����/���*��_���ź��N�C*�Hle���5b��V�{5-n���/A�����_��Ǉ�#��}�F2L��q���܇kNzN���w�����m9�v��L�.��k����o|T�{RX�=��9����
�{�Y��'��Ar� �%��k(�{���9F\돊��w�5쿽��c�r��W9m!��ΧnO�nϙ���ߋ �����ɋ�
GٍGq_��<�ٻ�5���~%����%�Rn������Ѽh^Ї�^
�_0�b���K��na���.C�P۾
"¹�P�#G��6)�n�9���Fyt!���b�D��U
�wB�����N����+"7!㜻u7.�`����6}t�
:�Bí,�X�M2W#|������9�zJ���=�^��9O��l�����%����u]<�&�7C���N�a�V����Ś��}���w1^
7����������:�w�C�o
�A���<���&�,>��g\i����\�9IJ��u����e]���r	z���봮1�NG^]u4|������|�Gv�C�%��Q�R����/%m�s���i��Z�7����a����E�xV�ųpT>q�Z��a-mTJ�)� '��7D��m��9�x����=�-(�D��u�K4�(O�~�����`����8�9���L�����
k*����# y��+�a�
x|��a}�9���`�H�E*�DӘ�ʠ�{��]� ���E��.p!�B�(u,-u.oo�s-X�U�'��u��$��E�e.�*w!TП��\i՜�P^��� 2��
�@ڴ���"TȧRs]���m�nX#�3X�n���f�\!�{T]�vKx�TW \�D�d:~�fD�P�H���xk.G*pYs�ܶ�$8�)�2xՍ�iChMAԃ6F]���F).dK��4(�5]ACy.ü�ۖ Wc9�Wj]暣��F(��������\�
mF�	�T޲��Pm���w�uH�L�!w �	C*�V�H[Iw��[A]
.��t+�C^��u3
���U+h
uQ=������@�g=�p��C^En�cU�+x�k�+t�n�"h �O>� z#�q��U�r�%�~e���#�v���3���n�t��M]����n��a��և9"�

���lۋO�x~|S���vՍL���
?w��,���.N��쥕v���sK;���s���)1�͉3;{��<��\�v~|Rti�w!-*�l;�ٜ.���
������;�^�<�[�UK�l�1h�P`l
lSI���HR	+��Ⱥ�J�d�4|��b����~\��M��1N��+�u�D�8>��{9�н�E@ш��gY1~��l^����"}�w�����sy�~�����Qޟ"����d�m2�%���Β��ۖ����:����8�P��
vE�u0gɋ����ם�%�T���;���B��Rt0>���$�uAMA\�u	���k�/�g/�/�3�:��O���~�S+�|�@�
�Ցb�M5Ƥ�� A"(x
RCL�kÚR
sv������ϙ�K���sEg��u���z�K�Mt�OU�\��6S�%夗C��#ebKmf�er�
����V���Ty7�em��f}�)�<�M!��F�|�q����x���nD|�&���<��-��v.g{oLc�Nq���s��-O�D�`g${��t�_8���zVǊ���9Nr�x���.(��� �z���X"=�����3]�;D����t�.�����>�|� ���\b�8H�$a�,\��8HY���:�p'�}�D�c�|�!�/�2��I� �7$ˡO�v�r/��A������j�eXq=�MD�{���umiǿ�Yn�E�V���P�w�����`I79
ZCdl��E ��e;`��bb����iw�@M�#З�.З��2���Z� �텱�\Hw��~��>�U��K䡺ĝ1��'��ݰ:�=]��
�:���H��A�ܕu+�2]y���L���L�K�N_��P���^8�~.H[�=4U�-�;�kG�d�)��<3B����6ӥ�=�M�?xˀ(�k[�&��:wz�%�٩e@3F+Nu�����_��A"h��"�5wE&��e���h֋i-+2�z��\���w���hF?a�4*�#�c�&h��9�9S�p��}�yL[�kl�q� u䦰AΚ�/q�
�a��)��29c�a��b�����L�1Lt���
�������>rϭĻ]��S�E���������=�iyz��Y��ݵ��Mq�}�T��R�oq�pI1��?�F�
Iۗ�U�~�Z�V��aVs�6,2�f,�ܤaw�5!.�[����(���{Kw�2�U�6���[�Z���r�M�vSY�kO��&��}��������NdW8P⦯���Ķ\�:������V����T�qz�n�D�o����� r��PGAJ8Ǉ9��JG���w!,�ԲϤە���]$O��!�+�Y.�<h�ִ���#S��E0{a��\"ub{G)���)ܴ����o��;�-J������m�#���F�x�_.�39B��G��t����W(����g�g��+�R ��6x�]����q3�8U�9���|���ϴ��|�=���f
JD;-s��r"̡fQ!'R�6Y ��2�m�b�;H��Y�D$װsYb�ts{gZX��Jp��n�7|ؙs�Wy��o����)1O�&R��_�I���ȂK�9	����sn)y�e~�A�z��yG�l�|.��?ӏ��GO�e��!r���{8��o�/�}��޿9���
Ҷ�Y��o�$�J�x�@�ZxP�Ge�*M�=�lx�)s�y���j��哢=���H���H_�R~�.���
gx�z4Ā��ޞ#MC�3w�n,6�vC�&d���R������
��VX����U߈0d��E��ـ���ƺ�n�
�3B[�u�[)?tcA�K�5@q�� �-��?*o��3�{sMwn�n�F���
������F�➯A�n�8�Q�>x
�$���U�K��@:����F�|����/l�8,`�];U}!�L��f�i������)���7��wU�Qt.?�	j��	��OT,��s�VR+�+�+v��X���s+����+-����Rj��S;Z)�syz���z��N��Z$��`��� ��� ��HB/��۔@�Q�97M�D^T��xr𪓞z�1���nK@	Ul,��(�(�ظ��H��#Q�C��
����|z+.��A��#\k�Q�)i�U#��!��CV��)E�=����*|�JR˽я<�C(ۏ�a+A������
:�N"8Eٛn
8��t<_~ҭJޗT�
I�y���]��D
���8"��GdK���,�:��A�$�B���n��x�B:)�v}=�CB�ط�j<5B�,Ɉ��\^�Q�H��Nk� �I���Nl��Na�8e�86F��;����I��`l�0�D[u�M��m�06�������0�����W��'�/��X"�+�=ZuLZdu?��;�<��
����ս�;b�
Sn�l�V��?�ᣑ=�^4�n鷖��^�u���()h��γ�(�qͿ^S�bʺg����<�D�-�=غ`�(ۘ�*R}���VYi&b���X���:���/i��a�����u�~̃߉g�~�]�]������e�\��wꮏwׇ��r��3[��z��Z��הuc��U���"�ŭ������D<��rK+�Y}�e�~�[1��8�Zul^�M�����8���YA���X*6l�o�����1��]�"��RϾ���G�@�B�3�c
�]ϙ��Aj����c��N;��eױ���:~�{�8��
���q{'��.�;k�������֕YL���T�2�E(F���x/3���/�l��[фC2�պ�X4	���"��j�5��בU	������.�p��~ǂ9)���G7�y��p��8�,���l"U����ʥ��j���QWdu�KJo7��T��HZ�o&�m�C`���VAl[�y�l�^���x�L9ۤ4�I���C:	[m���{V蹛Q{�V�آ,��%��9���5��r�g�;>�\
v9���]�z �<h�C~�.�k(Yj�'Y��2MZֻ�UgK뾏�w-x?���_��RF�)�bR2�֤��L��R�t�P�&�6�^�� Iܖ����"���L��7�Kx�e�H"����&�Ƶ'��C�@L��4iu�05'�~�f<*����[��w��c�L?z�Z�����w����yuB����ց�;��5����[�����9��ƽ���N�j�筓q��t����1ѽiM��!���<�H���:�������,Xr$ 9�����Jǳ��8,A��e�Ӵ~��4C����q�$Y���El�0���!��%��B>q[�(���O��Ɨz漫t��U�%K��c�C9S9��=Ӕ�x~1���#Bowy���o�ɵI�����i'��y�g��t8���nťP?ع�>_�5��#>�{��W.X���4);xXM
�2E/
��i�``������\X]����#:X�[��_��S�\DG�Ǣd<�G��Fa�s�eq]�X��Ş�x���.����S��Գ�ݟ�3z"����:���:"k��W_���k�Bt�̼�pT�U)���a������D)`��-�lF��ϧ��o�ꟷ����xq�Wo�K��>��l�F����G�E�8J�Yh�ny��W�{�ˣד��lD#s��_)a���\k����c˔���f:M�{�����	�
�)@;����c���|W:I�짹N�y��f����?f)�7`���	�b�>�>�lRSp݈&Y�M�Mo'�����u�[[��^�B�N�)��Fg�b���+vHS��~m�d��i�a7��&��g��r
Ǿ�����N�~�^�ߌ�����׳�D�h&	uC��y���.�c��D����p����'���l�:���e57��/��A�L��N�>ז�p�p~��wf��*�/�+�&���F�=���7c���&w��z�Q#����ǃ$,i�s+��[��l��MD�/�@m�ݿՃeDT6�v�N|Y�8z쮈b��{�J�;�q?X|����G��,n�nli��PGJY?Z�2Э�I`��
�5��RP-���1����!{�1}��n����H�
4�Z��|��ϳ�����0O�ތ���j�
�jԚ	/�4/�*�׍y;xM$��+̠��#�$(�Y��uŖ���}�>���K�����v#l?D(I_Y?r�4�d�m��}qc��a{	7�`�bv��L7�u�_G�=��~9uW^'a��!�?Pg��θ:�~��gE�{'��I�*l?�a�����oq�M>4���[��9��"�f�^k���P��5dd1����"���>Lְ[G�D���C�u(�%!<���Ĩ��!���9זKݙ��)�[V�O�{�ݍ%(�ݏ݄(n�����]�kι��ó�l���P�>�F�=��2��;C��y�>ӄ���+B�N���P��S�nX5�0�tD��pcH�B�(�6���Z��P�NdM�}���#���d�=�����ϐ��L7n=e&���o�#��XjQ{��*�k�h[+�8k���%��,���]):-j�I۞?U߶��.�FL_�;7-���w�cs6�	���_��tb��aV�����,O'���6Y�~���:��:���B�\h'�.��轳p�K2�h�O	���m
y��1���(�Zfޮ��ꮅ�:>�@<ė��7�>��ϊ7�QB?��t�A�MxՆ}��Y��8�vN���_��M�ڄ:�Cى�/�?9#���@��
Ʋ�����`e��eUq{��������#j�n���@�8��gK��j�����8q����vKE�-Z�;�3����"�:Ջs{<#�s�#��5T���\-&�D@�
OT�\s��[�uFVz�aG�/�1#
=��,�9R��Hq��%�h
�uL�u��B¦���s�G�	�E���V�?��z��,�G�_@nQ�|�½|��`�U��CV��$�'r�Y�Q������U"%��G������nr}����t��w�p��K:	��뒽=�a=>�q���w$����䀴�(鞍:4Z�g��ׯ��+�����xUZp ̉ߍ��F�[y�!�{�n8W���|���Q�.ĭ�X�x%�`V���¬��Z�V�dVV'�;� �#�~_�-w ��w
�s 8�v��%&f�Y���z&��/-� �PU>Iy�{�\4�b��x'ދW]�HX�<�%kI6ꑻ����Ih���j�s���
J�Ci�"{���}�����(u)�#�đ�����ʳ���=�z?ԕ���y��Ļ ��,��}ӉF�,9���v�o
�*�%�&ƌ���[���;�/�3X#+,�nXQ�^��(_�*���&&J����E �qJ���A�FRP����wn������{�`5���'�>IO���<��=�g��$�-)�č���!o!~+Gʲz�|�B�{{�U\�sF�P�
!�8R��=�J �Uu�
�`d�Aׅou��v�0-�[�����#KX�?�$�7����
�� �>��3�� X�d�3�Ѐ�}�%�橻��xԈW��aL���_���wW+��;��/��:�*���4A%y9������'�x<�w��ؚ�]H�V
M�gf��%6���HX�:!��޴���n�J,�Ȋ��Q�6�ť�O_��Y�|*[
k��c�F��W��b����6��ې�|�w{{A'��'�1�oy4�q�H��n�H�M*G�0�]�O������c����n�d/x��f޴+�0���������$z}��؍�:���F�2�������H�Y�X��l<^�x��{%��z֜�%��'�`.�\t���� ��K=��"��O����Y�>²��ߓ��x��d����I�&b����?�[�ׁ���ST)�>����z�	�����������GsP7~6�>�������z�d�X߈���>蟱��(�H�(�5C ��s ��Y�zΜ,���Q,�3;��1��`ˀ�?���z�8��l�6�s��s����8���lq���\�7�f�r��P�[Em[D"1��3���ݵ㯹#�Y߻��'.��P�bi��?�9l��y4G��Qĝ=�Y���ݶ��-�$W@Jcz='�^�a�U���nb���I��9�Ch�ؔƷ��;Q,G����_�"L���B��1��F%��U<��N6��ڨ�&���;���?��G2��.��zJz�o��3�sK����~���_��tc8Jb�s�KS�
����g��
��w�Ȗ]�ݙ��w��M�M_��og�zRO-�Kn�� �9Ѡ��ٮ�?6�ijv�o�\���;��R�v��1��Mߙ����Ř|x�N�������%���Wj��&L��Q�/$�������̯��x��,�e^nzU�%/վw!Ҩa#�^O�����)u�%\"�KP��(����,s(��2�8$P������8������Գx?���:��^�3�����
��
I�{�5hmF&�Jv��6}4�����/�m���no
�5�v;�v�p����.�I]�Nb;�S����n�S|�xV��M��K�F���u�����8I�p�����.���TR8��K_9�X��a�ZϮ*~�"�~�,��Y��*���?k*>��a��E����������;�Fĳ��I���Lϙ�9'ԟ[�c�ϫ`���UJ��E}PQűJ��%�a";�L��7LR��D*�-���A��'ڨ�?�2��A����/�t���}-m{�$&����W���T\��b�	D��s�� #@��@�S�.��E���cЧx�c9��
Ȑ#��=��Q]e]�
���x��FJ��Eh}oˠY�]�K�������k lӗ�B�cmۍj��*?{�߸��D
Y7�Fum�0��rV·�Y�<��-
%k�؊v(�l��7�E�w�b:�׏^�=Z��ܽ�@	Ҭ����$f]vߗ��!���R��fYN1��3 G�]W�.��>1�X�t��p�����}��O{���g��������<��Hy%�a��	�][�Z�l3ݺ�	_b��<	}�]Gw-k�ofűD��LИ�.;�VAO-��è(nT �V���}�f �@�$�tP�+�-��������.y���r��^�&ŗ�\�f�gUJq�<^�+�/��3
��"3�%����R��&�Mj�U0~J���B�V.E1�ጿ �Fum��n�U~7Xq�-,�69I��2v5�V�̉y���$���#�{١��}醆`�$����b��z�3�u�M��e�S�z��	�����l�|�=�D?{�Ȏd�%�t.�%Գ�)��g����c#�s�_���W���ޏaUba��}�����Z^:��/BT>�^wS�*�A�
+K�~ʇk��i��$m�BlOѦ�����6���~�H����%j�XZ�	�и�l�oO͖�!j�	Z�'�A- �T�>�E5D�\�{>��ٛ��c�@����(i-֖ �y�y)������Ql���B;��lk��I�fI$m{�L�-�.U�^ѥY��S�%���Y�2� k�)��E9,Q��1{��FԪ:��o�o�}�&�����Ȍ7�mþ��߽<�
ͣ�G���p[��y��S;�]Du��=�>�%k�Z�+��f.b�L&�����W�/3�VF#����d��1��l0j�+����r��%&�~L3/��ſ0a�����������{'��~$U6�u�x��Ь�~O'	oIL�M�� �<��L�O��J�LzS��؄
�9��J���[I!w8uˉbz<a^��[J}�T����_?�Ҳ5|�H]}ؽ`��ML#�4�޾J0\ֺ�Vb��.���$Ô�,�ƙ��z^��ЬL�� 
�����^z\����h�RD��T�#�ˁ���ſ�c�ZO󗎸i:��h:
��X�!������O�%Ӈ�]��J���1����K/��~�
��In�2�7K'���M�N�ŻW�;t�_���=��.�U�
LלS振��G�6x�Qb|g�7�Z0oj-1>�(�1o����"���1�`�M��_�sM���&<����i�YoZ~	K4햒ǝzVe��F��C�Ŧׁ:\�QgE�d����i_�y:Ro�wȰ��10�
��-,C")&��l�I�!� :F?�	� Ǳ���x���Χ�"�^�����ρ�s�=Y��nbRB+�UZ�TIh��,�0B�'x�O���Ҩ���?�8d��B��?j �Q�d�h%�
?��!��~H�C������\?,��R?�a�6��?l��~���~x�G��N��#?|釯�p����:���z�~�C�b���4?L����~X���~(��*?l��3~������������=?���G~��_�����{?t���t�~�C�b���4?L����~X���~(��*?l��3~������������=?���G~��_�����{?t���xY慿U�H��'�{ߟφ�0�6@����䃲��*��t�+�W�]���V��F��_/(\��hR&h&�N@�7l,f
֮)D.Ԇ�G?��!�Qj����u�Ntu��]	�����߷
�/-F�Mt�Ȅ��G!֜�&�����D4	MF�h
Ҡzt}�.�K�o�I�*D���	mDEh-*F�h=*@��Ǒ=�V�Uh3*A+Я�r��FIh���ihj@��sh�
�����Ȇ�����Gg�9��}���>E������t�����o�O��Aw������$I��A�L��"B)�%(��%ŢX1"$"�D^M R�ל"X���f��*D2R;�S���h����[��v��-�,7�z,ۛ&�
8�^�����:����|��I��z����D��%��@�E��hXS����<
���((H�_�qժ�P��=<�汢5E6�z�?�����^����Og����#���%߹���/�-[�e�-d�p��W�s�����,;H�G7�5�_������5�ùj�G��
�ѷW*��☼�\�����i�֣O~|���z4c��ڢo��KF�;�0�_���H�a����pÝ�o�D&7ޫ��I_�2���F��x���}w�-*/}v��ݬ��O��/m��� ���b	��?��7n���������u��MФMФ��lU�z�����>��MJKC~�{𬙐��&�i&N���69e2���i)�)��`�����)����aVo(Z]8c¤����)��L�:)}�d���r(����NIO�<%}Ҹ�������JW����I���I�ߛ�?�o������O�8�g�?mr��?i���5��v�_�v�������������h��� r��)sѪBfú��Ә��r��ׁo`���a-�i�F橢�ff�ZFf���)(����u��������_W�<V�n�S��
�v�&똵O�a��_93~�3kƪ�Mk�+��2���0E�4�[�ȦG����U���L�4f���xٻlc�@Ɇ
3!3��
�N�'`Y?�֬�b�1ˁ��Ӧ�C��}aIцA�B�
�ZF5G����Y�T�:fS�zf�:Щ���篐�9r��K��'��`�����	'M��:Y����6y������O�2)5-==<����)͔��)��4i���!D����k�
s�2!m����!��߬��u��
����O�0��������n`����[a.�P�b��u�3T׬\��)����7��_]�$���K�'-��6���U��Ii*��7�׭���Uc�eA��Ǚ���uEk6$n�<�<��~�
��֣G?�'q�3�<X�n������v�7�g�C-!l�ˋc�0���1���/��4O���|��/�>�I8n)Z���q�TP
膙�;��p�*v�j#4����u*\��@
F��k�챍�V�o0�P���m< �G{����h/xl���e��f����T2N�_��NT�W�/�QE��#jfȲ���]��y�\�y�W�+*���g�m\�3TnȞ7#6�YQ����)W�>�˘��l~��y��%�G�U1cI)~�����z��ɞ='oނ����, R�0����\q8����0�B�._`�*���"�g�>��s�'f���:��B����E�V�/\�� ?Q�j@���� w�a����Z_|�~��
P銟k�(���x��Df:��;v`��[�iƥ�JM|��x����߃���}����RR5�)�&�B��6a�������LX�A ���ۄq�)S`�Rz�7)��5irh��g��[��O���fe�/���R&h~��p������_if.K�sO���=�`_Z�ϷL��F���8�B#�����=x�D����k�o��s4��L:���xl����/�v�A��;%����c�����v�7��}�E3�?���Ϣ�oG�ۙ���3�?s����a�~H��{�� ��[�����à��o��
,f�P���D˖��Z�r�
��e���B½��І��7lX��֮ذ
^vA�c�6�7��

��Bh�CT$�3�N�*��t�e@�C4'YHA���s�
�qh���
 )'��ع���o8Lf�#����t�L[y�ȐBj6�/&q�j��\�ٰR�:^��@*_��W��,ܻH8�(��m�ߌ���_W*g��:_��N�������J�IZ��+�ඁ�3�g��R�w�7��p�>�T7�a�r�����9p/�G�5B~��j���W,[~*�q�g�IH��ص�}�C��D_�ϋn7����f������M�wl|�/e��Q��?9�[N�z����@��`�ʥ9��� ���_H������#���,~ ��5c@��~�Y���R�}��j�Ɵ���� [��o ��tp(���P����G�Z�+{b�`��e��=�pW"K�#�a�n�
/_ �O��9�W��3:��������:�D��V)��݃��Fw��B��/�;��[�E�|���W�w���w7��(�2�+��m�w��m�x[,����+��7���O܉��}�N�N;�/�۷_j�k'��n�N|��.�x�ݞ�x��n��uv�v�+��>m|�F\��Ɛ�Jkt�m}
��t��ʳ�NS��.��MO�C�FϤ�T��O5�V�������	rB,u'�?�Ԫ )�J�|�`�W���d�d$s�b������ɡ���咞��E%��2f�G���3����:NN�&��iQ���6�>Pa�l�U��TN\
��t������6���K�XS޿ݮ9u���X5��SP�_՟��fN�!%�x�9ꑾ����!�ˊ��}茒�R����]?���n���������Y�W�}�?���"�x�F%�A�=����^��	7���_�I�iPY��D��������p�z�R����#M���j���/R��*����p�*�U����79��E⿨���}k��/+���L���=��*���Z�+���)㇪���"��GJ|/}v���V��l�	,�����R����r���=��U�����W�2�>��{	����>�,���X~u=� NП[$��g|��$��^���D_��7b�Jxu<n����0���'�na�`��(�[��S?�=�0Iw�C��M�����X8�O_nr��Y�X�j�����mZ�o�����R�uttvE;�1��m�N�_�[�;�ۣPYm]���5���Q������������Am�)������]{j�D���Y3?��H�������Ȩ1�����2$�333��@��G�����l"��,�N������g�����������y�T��z&_���D�b�kS�L�a�)#���R>���j	7���W"F���޻��֋��*�{��|���t}�� i��rz�L0>4� ����8E�o'z�M�K!�M��7äL"��lrdw�RV5j��?�����,ݘ\ҋƏow.���bZ�fsG��h�ɮ�Q�s)�D�������m��� ;�*�t�O@�]�[�Щ�b;�*��'H)m-Ӡn�͒A=��A����A�#%Oڮ�	�`̴ �� ��kW9t��~6Y�YB)�7� @����B��M�<�hn���ubl��(9�rd��9�l�՚�֕���r��t�*�d��5����@Z��b���֡e��H����$5,��V=
�x�Ȩ]P.��E��R�0-RЏ�9UJpCx�1��Pb����Ҏ�L^C+h�,��\S�A�������f9m�"}Y�)�R���Q~���T�f6���ޑ���F�I<�x@0�?F��C&�I(٣�A��W:8p$;�H5�f2�ݵ�����o�>h��"�m' �~�H!�
�,(Ԫ��
աfv�"m�"}��3�M�f`�@?�Zz�>�)/�C@G's�M'ȑ��7�L�4L���^�r�r�GnR��� Dțl~�Ǟ��+��ZV"�W�ϠZ�)s2��� \������z*@����&�L���-
�W�t�����l��@�]�Z$����5��K�]cRi�)�][p������
S���eW��c{��|]/;��ˎ��E��E7;^�w�i\?�y�'���3�j�W�F\���v�Y��������k��n����jy�ɝ��j;o�
.��b?�*���jy�Hx�G���{{x@�o�����(�$|�����?I�%�gR�e��~��/��9��?t�g�l	���t/��t���3J�Bw�Y�t_���S��*��!�_z�o���-��#�a�~�~_�9�dȽ�<ro?�z�_���q�#��=�������o=¿���C���ϊ<� ��3��-r;�py<� �_��%u��	�9�s��:�z$�8#�c�Qp1/9��b�pB�żጂ���B*UL��k.I*GB}I�q]*��oaORW
��S�Ad|�殯�QS��#����2m֜������7����������
�μ������,�Χ��/�^�}��K����Z�\�����W���<�/��^Z$��Q���fB�ޥ���