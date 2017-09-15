ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ���Y �=�r��v����)')U*7���[c��M���\EK��E�%����$DMc!E�x+�p�����C���������H�Dόy$�q��v�n�>T��Bf@���P���~�Ď��m����@ ����$����H�#1,FcqI�
�G��# �S���lh��6aW���-{�+�.2-�����,dv5Y����6�L�6�d~0`m�O�C����� SGj����1�b�lږK� x�%l	���3V���fb��{��:(T2���b6��?z ��?Q�h���N����Ȇ*�!A��������)�m��_�GF��u�v7�~B�
RLdӊŃ�Q%�^T�TBlxsQ�M��SMhHwq碾��d0�6O��@�MX���uMG7��^�5SS_E�bjJ�V�1Ȳʠ+�ElR�k�+.Bl��1�+66~������P��m�x*YE���v�6�]� ,�æ�L"�K�x����S�]o�e;�(�lwtDG����e�0��F��lE[N԰hA���ɧi��!*��p���p��7m�CƯ� &t��Y&"C��Q��͑F���i}M��A�}T�[fJ]�9�E���D]��7��d޹�B�m`8�~o0�8�d���b&FEu��!A62��ʤ���r�� �\�PQ7@�?a�н�A��x<:������X������{Of����X7
�ר��]�`�����$��'I��r1�bk���PM3B5h59;�� ��9PT�O�L�&�竤\��P98*�2o��l����A���O�:��� ��)�_9̐*�t9?������J`-�_6̐�TZ����6�v��{�'JBtJ�ck��"�;M�{�خ��	)��Q�t�<�d�
+����Y�9�ul�Z�CO�i٠�t;��1�.�i�l�A��D�fc����:��v����bɓ�S�;���3Jc�
�����c7�9}Д�j���5k[&R�D�;��'Hd�����X��^�t���&��x��P�v�7�d�-���ÿ+����[�y�9����4�.����� �G��@���- �=-Y���v�K�R�S8�Xi�q����`�?ws����$���Av�4�k���`��O��4{;tWp��'����_D!�����q��{����N��݄6hi����q�BL�04�1z)dq~%�Ɲ����;O����@�����Vo�7y(�����+J� � )M�=��I�����^��Æ��@��OF��k�qi�q8޺4��2���4k�#u���b֟@<>k�-��z���g�Easv8괇���-�[oQ�5������A�2?6v���<7�Ή�̲�G��q����  ��8z�M���z���I��'����pǊ���=raB��h6�D��b�o7�D�8�a%���ZXHG�zMMi�<�#�9����1'���F�7��9�ic�&��@3�y��D6N�H'�7��ɧ�?��n`���+ j&��W�F�S-���Լ�^�u����ʑN�Z[�/f��H�v�C���?�h\X��U����ˆ�?Z�{jc���)>-����w5��I��9�띹g쌆xz���G�1�<G�ݜ	k���&�@��~�������'�����|��������D7!�����yveog�������s�������r>��8S���/.#��sz'�fǰ���8�Ӧ��B��F���
;^(�tͧI(ҭ�����Hg�N�z+U�\�P�2G����@��w1
�[�,�jm^�D�1ꎁ��&�y���B ���S�G:�x�<���Ο�S��%a��ܮn�"q�!0�v�<��{�sK�H��9Y2��	�@�0a��T�w\�ق��\�9Fl��W���FÝ��wkpk�O�k�o5����l�����}��e��i�/���p���=�T���i� �� 蘨�]��'��z�}�u�3��_�{���9�#�u��
`���Ν����O���%p���KP��!�Z�p8���+������ك���ib�%蘚a{/D�mh�V��;� �Rk�l������O��8������af?��y�)Q𓏉�Jӱ��?F���Kz�E�X}�Fm@��H�YC��_dd�~J�z�J��bA�>UB/Ǻ/�Ign�L�H�;�NS�
�i����'f�:����2�*q��&�F{
ytM&��XC,�H�*��	����w�T��	�)q��ӧY��=��k�� 7��w	
_f����p��k���pw�*�#՚+����"bÆ�K!��B��z-�Áh��8P���]�mf bP���x+l��T���ު�(M�6Qe���T���L���ؔ�K��Z�W� �o5� �elk��j~'��0��S|�k���_��tS���K���i������ߕ�]��A^�s�����,�����;}���4�	{��0�X���"���<��ҙ� (ipn%�&I ���hh�ڜ��n����G�9Ȃo8k�'�7u�f<E�̼$W�%0J���Ml�nf/��)���1��c�N�	&�,M��e���Vc*5��t�OgȘ�c��X�ɡNe�yz�{P���Y�4e^����2|Xxn�6�df]]�hB��Bdx��g%�nl�W3�������<���5�'�q��1.E�����[��H���)h_,k�.����B4>}��F��+����>p������?�������?Lٟ~BᚠD"Rb����I�z�Q��X���"R���"�H��GID	�ߊJ��ht�?����57MxC��W���NG׈�B�n�y�x��S�Ka�¦�9���'nch�F����W�j�ȿ��W#:<���%��6�e����7���d��'��7'&ټ���6����qʈF��xC���7���^yn/��ýU���aa��W���~�ɛ��D�K��?�k��
���X�YC�VCSI�����7I_�N�t?����|�����oizΖg�OPD1aM@�X�.(񭰰U�J���m)��F4'ܖ
%(n�a�&�!L�H$'Mh>�+^AD�֩��	PHfr�"He��|6���V��(���y*%+����'�F�,��������>~�p���z��i~��/υ��)��}BAn�d�(�lR�ǅ�̥\N6�ǄT5�*6k9�]�v�I�"{.�ϔj��<Ӓ�w���:��~y*m]��W3�D��2㜽i6ko��Y%z^���ݴ]�B5#����L��nS)�J�x��
ռpP�K'�윕	òw��y�V(Y�T�4}\*�2���G��j�L]*Y�+IY��u�v�sZ͜�%w���;�H�:��Y��$z��k��z!)0��;)��mx��\�JTG����.��v�[�&��L&�d�c�R�$�F&�Jy�{�]Y��ɜ��w�,���E�Z8���x�v�wr�ci2'���䮱�:9����)ܓ��P�hZ�?��uz�b%��
�a9v��s���y���/����j��I�z%�ƻ��\�s�[.$��VF>��Bʢ�R�R��ړ�ɶy�x2�L�3��~�����i	�ÃSHecMz�%\�d쏌�`Jr!s�ʗRk�{g�2����)�l��D�$jg/��|U����q��RC�|�݋�v�u_�Y���L�WHĝ�;��qa�
Z?IĻj�,�3�g��b��`(�i�}�h=������O�D77���b����g�����^�����>���Uwhj��=�5�h�������¢]�������r����9e���B>�Kl���F'sBR�TjB������Z(��j���ف|,T�7��;����M#岼W2$�I\��,��n�*˝�Q�2S��ǑvJ�/j������r���(zt�+�F�yba�T$$AE����~z�*�6J���z������>���r��a�#��tm�W���;��=�5<�e�i��_��\	�����~>5n���^�w������KJ�Ԑ30�33���f_.NN���F�Ï9|�=�Z�8�7�q��hb,�㎸��ߺ��mȇ=q��zBb�c4�y��;;�|�g�{�~;�	���ؘ�ԵF�o�+aK�?v=�;Y�\<)��,.2�,�of'd]eZf�2b|��'4��0�&�尿�g�u��`����������Hf��A �Q]341��4��%;��@�A��xQK��*��r�]��=��%N�y< � (�_�� @��fl���*V~�mS�|����� }�@gԐ�{,����%�~�ް��~�n[���@��?#�{c.��m��Þ<�6�e^F~Ĺ��;F�ȠA�4��n�LG~&Yd���^D4�A��/\���L�ᬠ�ӣ�j�d|�@p�cѐ���؃˥D�@��6z�J�K��ÆM/ B@ӄ}� -$��MY�v�؀QY��mi�K��a@L��z��dJ� x^F�l/6A�ɤ�~a��(/����J=8F'E�.o<?`*ꛬ/�@��lox4��?���<��"�z|��@릊d|���'�^���Mޞ����_]�����Ƀ������F�5����v���M�f��c�I�KRs(��|	Ldu(�u��>k�i��կcLʴ��(z�dN̯;��'�R�bGǱ	�pq-�� ���l)]dY�`����R�s�/N�%���q�pot/zR��T4��D�*a�f �:�h5�\��A�xЗ��u)�1n��Z������n-�*�v; ��;���GrI{�f��=d�<g�6_�W�i�"���P�x^��7=r�0}�w��V�j�MG�]�TT��x38!�EL$�׍�ڡ���Ф�m�v����E����8�#P�vӣ�t7�5m6&jP���^����l��	�*$s��v{�O�u^������s�:�˶�f�s��N�6��#�!��%���<]���`s�����b����7�	��@E��,��Xc��L�>P�c16�#6ܩZ������2�����GL��x�/F�}O��c����]	p����޵�:�������"5��`�P�t��T���I.SR۱�87��y��rb'q�<n��I�X �h����;$f�����A,X �X���#�㾫rk�9��u�}������0����џ���7����ߞ�5�����b�������/~����5��8�9�|G�o����Go�b������	U���0��dE¤pH�P�Z�P8ҔCxL�H
k��n�R!�2Nd[��9d�B��������������?��������ln� ��ǁ�Ð�b�����>��
E�����w�����{��� ���G����P���a�ˇ�~����o��[��v���+ ��2p�b6��u��򱡥c)��{e�a�S��9��{�|���=f	�U�m�U.�
�Ӳw��nT������b����0�yvIB�>zR�5$���~V�!BJ�Ǘt�F��EZ��BQ09{h<g��zu>nb��@�
ź���g�5�p�8Lw���EdgB�o&L�ᔛ3��[�̠�Wq��,O�D������<,�ͳ�z�ܝ��H�@�T�a���~�/O�f gλhչi��y}���K#����X�5Š�t�ZL��Hw�Hdg%�ܜ)�b��2�])��ɂn�<]H�m�}'9�(D�����za��dM�Y�3�M@ϖ�B�
a��:I���#:�I7�s�|�4Ҥ���Y���������ÛE�hUY��N|1�Z�g0u��2�E5ry�f���3�u��֗��i'�'kZ�LRҬZ*E:9�ҳq�ss�?9�Ǌ�!����%tu6��.���Jn���+��+��+��+��+��+��+��+��+��+�����1�w�7K)��~�T��d��α�v�YMċ1��ĩl��i��p��v�{Q;+
�U99_"@��E� ࡐ��Z� @��N�D͔� t7o`������Z���S�!VLF��М!2�<2�H�*�[��6K�X5E��L�PK��9��U�
'�R�Q459��Mpb46GR�,PW���?7Q?�ƈn��X��X��Ζ��k�TN�{KoEd�2C�¹y���ЩY8�Ñ)��Q
>����L�5�z�Sd�HGq���Z&B�X-��
�̝VT��(�&�<"cmVj����`��%\�]�B��_�����G����8z������c�y����p�]��wC�3佸}.6���0?���"�I�����ܾ?� u���ԩ���w pd�����׼\T,�����G��}��o ��\��џ:��?��a������_\)�2KK���J��Ft�u��3�E��k��nm�|I|�:?��%W�ǉM�o�	[���I������,X�ӕ\�m�f��Bl�U0��#�LcS���J��~&JU�E��r�Ϭ��0&�cB�QJ�%�HE�T�J�㼒���Wg�rl�gs�o�S�� �7��n��ユ���IӘ7´mW��A"�Q�q�2£&R�-e�P�C�,�]��Y�i2�:~�Y:���4�
qH2�)�L����r�24�Q�r;y�G"���[h�`�Ҩ[��zI�"k���M�,��*�֔E?_K6q�[*8&*�H�_�YD#�hA��f������icL/�m�2C�֔��l���tm�VB'>��_f<��+�&�g(�i��˃�0�d�h&�w���rK��_��/���̦��X��@fٮ����p�������Ȳ�EVY�x��=3+=.�;r[~w��6~��;ݳ�D�Yզ���T8��B.ӡeO6t�������3y����i��`�aI�f��~U-��Ju��a�)f�a�nm��|�F�x��6�4U��g���P�
-Цm(s��h�<�����&?�;��\ G�B>�w������Ǒj�����	�B0�s�҉'��.Y|���i��+�FEI��}�,��t)2K#L�͛�!p�y�(Z�a�p4�J����s��.L�+źx?��!��(�^���&��+y"+E�X)!;�Ú�
x���])$lY%f�ݯ"�I�Q$�k?j�m�`��	�	r�#W� +;�Re"Y�1W��9�*Ŀ�Z����P�\i����:����'O�ꀋM�$�sq�nW��Q(��[�c\��X��EI���YJ+�G�n2�-�ә�D��	�(�U(��Qv(�H9S�C�L�|�4%/�C��I��T�<�)ļ�N��R���
Ct3j)���p�,4�S��+U�!ҵZl��g$����J���Q˨Ę�y�J��)0��(,���am!6�j��c�w3yvihe��j�[���g��x�o�y��n�~���d�v!��%�c�ݘ��W������/#?Ns��>���X	<���������1�3�d��%u���}�<x��9����A/Ϸ�w`�v�x7�&�����)�u|èH�*�>$����$��J����ȃ�������Yu��G���	��p�dHN���9���;�?+}���#�šey�躢��#�C����=z]���Y9B^��;���[|�x"c~=�/LW|�èЖ��p?|��Gz9�_��>z�	�:�G���Y��V���5����N� ��T�|9ص2����#�A�ɰ*I���4P�.v�����Q o��f_����'0���ϑ�I�3��U?��vW@��wN��:oXU��e��ѥ�e�p?]��xo}�Y׋llݮ��V �W��bNvt�dG�^6��S�{{��:����dC�N���Ѹ�G�ڀ"��=,iA�1
@>ڈA�)��Yt?Q`��� �3����PїA������a���&����� �1^0�s�$䍠�M598T,��]N}*�~yj�Wsj�2 ��,>_�� �jd�0�!�l�x�xK|t���]�C�8s"�������W��Zom���A��h��p�NFC�Wf�:竍g���`�`}?iE�<�Uae�Wa�ɪ�
E��c,]gh�cm�kd�v���N�k��Б��1�>k�c�,�ۀ��ɸ�Ћ�'�� �a~�[�X�N�őU��	WDV���_�����	?3 WL�Xٜ�M�����u�y�����h�lH؏���V��u���ůK~������&x�d2�u��c�������Б��� �N�
��`iA�덺\��Yp���7��O�x0�27�j��'p��yC��G I	|�<���E>�]]�R�88sx�n�%��}<�%��h+[�0(i�+YE��֕��r��m)y��S���p���t;��
�Rɽ}Q�.�z&��}�*i��s�����/���;u��[ Y춽-���/�x�݅�A���4 (O(t�Ǡ����푋�*T
6AYX��,�$H�뵃�`g�����z`u���A΀$ xU9�cM�H�`��cf�\L���+��5����
7i��悐1ktӚ穥�A��°&ٞ+��v�M�x��6��/��W&��YÒW]\u��J�9MX-;ǢA���.�/p�e�{c���_�v[���6,�i�q�U_�V�N��n��4���*Y�]l5�`WB�D�ԙ�S�''���ɨԃ�aM�!]�<���8� ��YW����lN�N :��O`����X�Mܶ6�4ND�b p�I�+I῜�FnG����- 	l�);JC:@��[�������c3�M���X��_�p�P>=�U ��~ԁ��x׎�e-���\�}�����o;�͕m\q�����?�P;���#���	�	� P[�U�#�-+a0��kD�}��=����Y�>�1����BwV��䎂%�X��,mU����G���|���v���?g���+:��7kG"Yj�H�IHR���E"CJ�lST��Rڸi�D4C��1Bn���%��QE"(�L�ۂ�=���� f>sb�XVi7���d�?��|b=y
�
c�\{;ě0�ξ��Y�xLjR��l6�p�Ȓ�J��I1I�(*S"X��*!�)�RȚ�hL	G\�$Ś���������'�'p6f��6P|����޹%�'���Nx�3���.*�2���,�#��+���l�+�\Ѣ�$��t�,�Kf�
�y&+�i��l|I�4��R��+�����_81�c����+��f/����k�*Ng�R�g���Ǯ�"]mua��ݳ.x�� ��ڑ���t��3�j�>i���N�����j�i];l�}�¶I{�L��Z�v�c;7L���l��9CV�Hv��%�)��V���=�+r�ȓ|6y��������g�9v���	�c�����˲���M���EQp��It2:��S�O��$h�̢�KO��y]n�`6���f��\��*�ʕ�x.���gYN�抧�5�g.��/��7��:���v&�]{�S�<:�1�j86i�-����?YZ���=����,sI�x�O��3&�/w�܈�d,~���m��(x�ę=xg�Y[�t���	��A�.bj��N�i��|��f��Ķ��7����B?&��
|k���2���Շ��Gm�;�$�0r�c��v�].nv��ݱ��VD�C��Y������
���^�l�x7�o׋6y7��&��!��>���Gw�q��Y�;qX�}���[2�6�""�a���^	��$���;���Gz��ohzK�M��C�C����B�S����Kz�?�c�򟌄�i_������}O�W6�K�_��'7�������t�@s�@s�@�B=��7K�(���#�����Kڗ���1���,��#Q�dG��f;D�Yj�"Q��PQ,��Bd$Ԍ��J�<LH�3�eQ�W;�
���o���_{I>�o3L�����:4��H+���9r\��hJh8�A��P��+�ye�In�O%�
�9�.rM}is����C
�1��-.��hY����Tč����[��餔��&�Jq��R�J�)�����1��������/?�
��p����r��<��i����:���#�
��v����i_��l�}�+��� ��_�o�����A��#ݳ�H�����t:�����w��G����^�+ ��U\ :��?��A�߻�'�m�O��>ҫ%����(���}����a�ڒ�D����������'�y��J����������][w��}�W�w�h�_������^� DDQPT�_4�U���R�+k>��TR�N�k���@��.�������j������I���~h�C�Oa���8�������Z��o��R��/X�n��.�	�li����gQ����	�m�Ӻ�~"?��y}�:ڇw?�����v?��|2��ȧ��}��>���c�T���*k(��=�Yo�h����P���N�LŊ��Pl)��8��~�;���,�VK?��6?��M_��Z�o�}��>���l��x�dr�������v�8]*_$$}4�Ir�M7��"ݒ��)�w�fl/��ԕCm��86��FԳ�]#LI1��ҴP{�PTړط)�=�M{?���?�m�O��NU���c����l�n�A-���+C��ӂ(X � �����j�������H�*����?�p�w)��'���'������p�e��/�B��
P�m�W�~o���)��2P+��MP�"�P���uxs�ߺ������:��1���9���G�N�߸���~u����)�sg<:k�ߗ��[����c�LC�z�I��`<��n�����]��Zh��Ҋ�r��Q9�S%�1��$v���9ٟ
;/E}��Һ���SY����x�ϟ�z�y'@�x>W�K�� ���i�#�>�{����e��d�w
Q	������7����b�M�����l+h5���['��g�I
�\1��F%G��L�ĳCq�H����_�����{��0�e��o��}���� P�m�W�'^����_
������1���f>Jc3��<��P�� H���g}��	�f|��|��i�"8�C��qԁ���C�_~e�V�uy��d�l5uɒ�=�
y�A�β�M���_������#9\=yqQ'��YL�������V���8��d�����)�B9�$�7@� �yi3������wց�����������1t}+E��P�U�Z�?��T�������RV�b|Aԁ�������;�lT�q܌C&4��3��|���������q�>eYr��r����H͈q�sFw�T�]�h.�ynF�(�]��0���H��l��\����s:���ؐyT%���PP��������V���}��;����a�����������?����@V�Z�?�����������B�{�� $�m�w��z��N&G�iz��?[V��_�[�k3̐��Z�� �Ӄ?q �g=����T�ۣ�_��*r=��3 x�8Oȡ���Fo�j�l��rvsd�h5��+��fi�Ұ->���Ǩ^�5Jﺞ�O9�\ԛ�[r�~�^���#�c<�w���)\s����x=��[B�	�z`'�rK��O�_����>��f�}	��b�~��b��
��>a�3���L���XhBClm�ؙ(��K���0y����|^�Q�G*��i�����ө��h:���I��v;"�l����f`&}�,4�׉�!���6f��$�Xs|^Y]u;��hP����	��|���wa£�(�����C��?(����2P������/��?d��e����?��B������������6�	����P���8ף)��<�dQf��0< }��\ץi���ـp���4����$`.����i�C��h���O)���N�;�
%���z�X8BE>��I�sr�oGdA��T�2�k%o����l��Ԓ��v�ö��٬	��F�|7飸�0���yD��MƂ#��ᡣ�6���;�#����ĺ��E������J����5��g	�;�q�?�������w�?����r�ߝ�#�x�#��������U����P:���/���5AY������_x3��������������)��Ʉ�yw��~Q���Ļ��o����~_C~f����F�q�;���x�w���S-8ț�����k�N����ޑ�'�T/�=--����
�Mo51�ОO]�W[�̌"Jc�Is��MFɴ�`H;�|n����,���d��r������;ƹ���q����V��ަk3���ߡb��"�KuH�=�Oe��&ۢb�d�4"��ֳ�ɺG���b�4I�s3��wg�P	MJ����=ϒV"�����Ld2�:��"�1Ǚn�Z�e��:迋ڃ�+B9��w�+��������c�V�r���:���i��J���7���7��A�}����X ���_[�Ձ���_J���/��jQ�?��%H��� ��B�/��B�o�����(�2����Cv��U?O�c�q�?R��P���:�?����?�_����c�p[�������?��]*���������?�`��)��C8D� ���������G)��C8D�(��4�����R ��� �����B-�v����GI����͐
�������n���$Ԉ�a-�ԡ���@B�C)��������?迊��CT�������C��2ԋ�!�lԢ���@B�C)����������� ���@�eQ��U�����j����?��^
j��0�_:�P���u�������u	�S�����?�_���[�l��(�+ ��_[�Ձ��W�8��<ԉ�1�"=4`ho��K��傹Oz�ϑ8\H�fg.�$�˸��1�˹$I1��>�����O����O��`��.�Tyz��۝K���S*��ܽz�����z��DM.Zy4���jb�@o������/�����!��<?��̰�a�٫��L��k1N^"�he��!u�Zq@٣ގBq1��Ir��x��>ߔ�ù'u,4X��H4�{iw���~�k�:��!��:T|������u��C�Wj��0�Sj��Ͽ��KX���Q����:���o�uj��V�jl��7z�@�,�bؾ��68��|*oܗ��
V{�`�z�$����,��1�,PD?��'��R�M{z�ݰ],���o[M�	<m9J��A�n���L�P�����ߝ��oI����w��w��k�o@�`��:����������Z�4`����|�����>o��S�_����Ɉ��ޘ#[Y!4��\���_�����U�I�#8m,�V�u �?"�ٻUj�͆t\q[�4;���F"3�ێ#�������v/��0#Ǫ?�%��b�m�D����)Y�þ���Nr�^ۍ×W����t�����a��\.�-��㗼���,��]���A���#A�X��ﺁP�C�e}�'�~�����/��&��aN���$mq�1o2񈈝){�y!�S����Ák�{+G�#ANf��zn�`�p�3�Ǔ0�L�Fp���|�R�����+����f���-������/����-�q�_���ן����C����?a��|���)�F�j�2����?�b����(v��%���@9����	��CY�����k��Dq
��2���[������?4��6��$b�	���%��\�I�:��%��-�C�_7K����I�u���G�������|�܏��|���\_z����u�jBx�.�W���\^SK�?ǖ�-�B��iU�ﮫ&�u���n����62:622��x�����FW�,f�|��G�0�����bn�s�ToR¾��tl��h�&�=#�-�c����[�쓕�侹�[;7�\�\���k^�7�y�f���ij��{b&�F$�c��֖h�vS�n��Mn��c�cP�e��|i��\R�X�\�P�� �/z��
XHv)�;0j6��O&�i���T�%f#TB!������)zp�^�	�io�#7%2>[��9�/�}����n���������[���G�����Y��]nN��{y��}n��8���ϐ7w	ƣ}�G��� ��lv�P����_�����_9�/���8��2���Cٙ��#o�u���{����g������{��g��|D�\�
�����������P	�_�����^���W
J����Wc�q�������?�_)x���W�����){�ط�H�.3�	=��w��k����y�e�NΩ'��j�!��V�����������o�	�����|��퇼��3�hov��Z�@�t�!����4���:�֘�_��7�4�5:p"u�Ӽ��?K����|����d�ꆑ�vGW����w��������:�f����G�ٻ�d�+��,M[f���tU�*����Ip^&m��z=�P+�0�jҿ�(!JyM#[���G��Oռ~���!ͱ�B�2�q�+�.��-6����,V���wC��h��KA	�ʥ}�h��Pb������ӗ�(&�G��˺,z���f,F�.�Q�G0�#���D�q���#�>���>���ku�u���E����BN�<b�q"����/�Ɖ�N�����l��䣲����?�׀�����W��.j�^�����@����'<�����U�?�U����9�A�AY�������gp��K�[����};�јv��b�����l������>�!����&(�����s[?���(���-D�� ȉdɄ&M��R>������1��1��c�h)�n�+䣭�[�
y:�r�O_�{�l�V�8>��޹?��m{�w�
nN�Թ���!=ur� ����֭@@| �:5����;�DgҙI���>UI�"l���{���ו��^�y8���r�θ։����<t�v�Ѭ�uݾ�z 
������T[UL�=��,�mfe��mW�nɑ�+b���t�j5��^����������RS��y�g)J�X�{�94Y��vŮ�{{m�
�x�mؒ�4l��[edK�ڼ(��O��*���Ƥ�1���T���`8��j�߫�X��x�mg�j���G�+�$�ek%�������//��JR$=���WRO?s��?M�?������	Y����^�����<�?����,�A�G.����O��ߙ ��	��	��`��U���C ���۶���0�����
��\��������L��oP��A�7����[���տP_%�[d����ϐ��gC.������?3"����!'�������+�0��	��?D}� �?�?z�����X�)#P�?ԅ@�?�?r�g���B��gAN��B "+����	���?@���p����#���B�G&��� )=��߶���/^�����ȃ�CF:r��_�H��?d���P��?��?�Y�P=��߶�����d�D��."r��_�H���3�?@��� ����_�� �?��������m����J���ʄ|�?���"�?��#��!���o�\�$�?�@i���cy�	�?:���m�/�_�.�X�!#r��GS�I�%~�jF��yn�[e�dK�[�k�|ɤ�3,K/k��1�2�9�c?�ou����A��ܥ����������Q��������]�bS�[��d���$=���uQ&c-�vm�;mL��-��8��XPkq��4_�*�#6����vSZ�t�z�t�v����tX��vX
����5Za-ɜ��'�����5�7�ݎ]�F���-N\�vI��J�=(�Ȋ�:�����B��9#�?��D��?Zìo�C��:����������D�
�K��?t�H�O��&-�j�=&&"��|��3�-�^O���j˝=�?���h՞�ڃ�F7�Gnk�5lX��a�p����X���;�U/Ķa�&���1�W��R�ڜ^ɁM<H�v*�$��^K>��"��"e�oh�F�36�_�\�A�2 �� ��`��?D�?`"$��]����2�������g��ݲ��懶����ȑ�b��:��6�����S��5q&S������׃m���6�T����]�$�vw�z�k�h���I�/��a\�X��CҚc����̫N6����ms������v�R�8��X�q���uv�O���U���-�V�_��v�&v��c�B<�~������81����fU���J��ɇ������	NU��ө�l����Qk�2���r�0�Me*�q~�����)�ұ�q $��w�~�4d�����݁��!�Z�~Є^맷�^���b��*޺���=rJ������+�d�?� ��_���A�� 3�z���	���G��4ya��<��H�?MC� 7�?�?r�������O& �����n�[����3W�? �7��P2{����������@�G���o�\�ԕ�_��2��+@"��۶�r����2r����#r��s����d�7�?Ni���9�C�J�� tĎ8>��|o��-�"�Cd��aĵ�S�G�>�~�����]=�~����܏4�{E��)�s��y������~�E'�׻≪��'qj��w�ڲ���3�7���joHE��Ά�̜���i��F��qt�1BX�Ƨɦ�ڎ⫣4���y��i�ؕ�_M��6�(�#-� �
<i���p�Lk}o1���$4��y��31���D֩�b�ٌ(r`Nxf5iK��&Y�膛�06�FrԦ�^�dحX�]s����l�>������\������������d ��^,��-n��o��˅���?2���/a Sr��_��E��&@�/������Z����D ��>/��)n��o��˅��$�?"r��W����&�?��#�[���������n�^������ʥ�ڲ������?|�?�e�yx��76�����~/ {��S@ink��1`:nC���R���=U���v��h��Y�|�o��D{�DU��4�-��т��ڡ^���V�˲B>������$�?���I ��Ћ��'(���.,�U_�R���D��9W��[~҅E-,��֞,�]Iٰ�i���Z�L�a���t���C��9��[�ۊ���ӻ��\�ԕ�_��W& ��>-��%n��o��˃��+����Y��g�ohE޲8���%͜I��XR��bi���R�d)�"5��,�0u�3�%��s����ߟ�<����?!�?~���~���-�әϟ��L�TK���^?��zm�Z��iT.<��y,�	M4�v����v�?��^�ט�b�x��EMk��s�;���<;j���i>��xR��@���!��h���<��P�H��t(�p��������Ar�Z0qQ7�M���?���ǻ�x���Y�9�U����b����Z��N	_����}����td�����}��4v.�&��zh�Y̏��ꈝ�����1?��Ӯ����e�`\������M����eh��^K>����/�g����������E��!� �� ����C9�6 �`��l�?D|�����-}���ύ�}�"��G�-�^�t������i��� �y!��9 ���u�����-H�T+[��z���jQ3G���OelE���GG��O��bSl����:��C��CU�S�Y��m��$�N_�yXj牚׻Ov��x�J#��bwX�tL0���&�M��|�ZIItr��=l����FC]-UI'd��Q88V�UD2���{�������f5��k�a�4��J�Ӷ�g{��p�HS��WW��S�f˗��'w�.9�
ǵ=;����Ŋ��?<`���Uh�������jcD��Q����p����L�������G��s�����>��O2������L�;���s�t��h���=u������&Qԃ�^Ğ"}�j�ǎ0�x�W��~�!=ܝx��6q���i�M9���	�;o��H\{�
��t�����z����(-4�5�χ�39��?/j���ܱ��k��?o~�K>�7����D��-����>���}�A�|������"t�%t-\`������p��-'#�/�'����z�>1͝��XhF���O�S1#�H6'�����&&������\m����?��@��ha��.��xs'H���#VQz޽�n���G������"
���~{ؓ��K�߯���~����ϓW�Q�Ƿ����w��v�������y�"� ���w���ė��7��m�����yz������x���ڜ�f��'<��ǧ+��q-9�g��>��E"|��u��׉�����N�L�KA�����@iV������ �$w����0�Xx��_���+�M��ͭ�ٝ��%>I����s0�7̀���z��?��y�8��ï���'Y2诅9mnb����ȧ'�z��[���������*�Oj��;�j�c�ߑڭ�"?vr'�&0��T4�k~�I��^�0��t���/��L���{���&�(                           �����Y � 