ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
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
WORKDIR="$(pwd)/composer-data"
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

# Start all Docker containers.
docker-compose -p composer -f docker-compose-playground.yml up -d

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
echo "Please use 'composer.sh' to re-start"

# removing instalation image
rm "${DIR}"/install-hlfv1.sh

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� k�?Y �]Ys�Jγ~5/����o�Jմ6 ����)�v6!!~��/ql[7��/�����}�s:�n�O��/�i� h�<^Q�D^���Q��Q���/�c��F~Nwc����V��N��4{��k��P����~�MC{9=��i��>dF\.���J�e�5�ߖ��2.�?�$Zɿ�Y���T��%)���P�wo{�{�l�\�Z��r�K���l��+�r�S�	Pɿ\���:�2�L��Oz�Q�A����P�أ���(YL�Z���w�O�x��v���C�1�Fhsp�<��)�r	�X�4JS�C6�,BQ>B:>��=����Q����O�7�gͽ
?G�?��xQ���?��8� ėR� �����Nl�jM�>��t��Xk�֩R�.4Q�e$�e���$X`�{+X�R\�ʦ�m�0R�?����_5�
�B ��@���c%�&�'pG���&�OQ4�!
�\gu���=���p:�JH�w��L�	k[�ˋY�E�[�~dK��B]��:uVT�����=п)~i��^4]�~���c��G���R�Q򿫸:��N���3^��(�cO�?J`��/�?/�,�|�6o5�,�M���A.s �5e)�ɬ�m�!ǳ�Rܶ���\�&�Y��i�q��e9�k�`jZC�[�� J� �D�S�&e�p�u#2�q�pک��)� �6�8�C֐��#u�D]���Ev����A܉�q�jr@1�&��Z=7rw
G� �qEPr�x=X�b�#���2y���rK;
��{0Qx�Tv����Ρ��Չ�XD���Cq'���\��Y�M��I[,���ā�q�t1�Ӹb>��Cso୥bpc�S��L� O
��
p�����yxsh���H"S�n$L�^�[\c�ƨ��s��/;hS@�N��䒡ʅ�ʻ�R�L�ŭ�L�f�E�F�S q������k�Q���Nc��#/�����V�xn,)@�@�����u���(��EƤ����7+&@fK��(�t isy�1����R��(y��@����u��@.|[$�%���1�e�����}v�7��k�r�-'iKj����Ŭ��,��Ez ǢϙE/�f�\�}X|`6<����,����i����d�����������*��O�Ci���2���������u�����Nݯv�zK qO��|h��x,fȑ8N�
��Q/!T�G��vB>$��N=��"��U�TA������^���e�$��h�``a���x6ad1Ok�K��w��Dѭ\������5$B}ٚ8����������B�w�<v]�+�<s�y;h��}?���{o��]~�-C��e[�*�ቪ{@k�(̶p-�#��4M93rր�6�����C�� �v~�Ɍ�\�A����}� ����堛��>�u�^��[��kSR�G�D������:��u�Ő�`f����d_��8�#�f5�7�~�&��� 7ؽߤی�	��97�~&׵d:\M�6��C%�u���|����]����'I���("��9�_���#4JW�_*����+��ϵ~A��9&�r�'Т����K�������+U�O�����):�I#������8E��_�!h��Ew�e
���E� �h��H�����P��_��~��RU�e������qG��V�4��e��,��h\�o����b��Z6�`۶�17�ij��ɗ޲���f�V_r̹�4p�N�#ڃ967�hk�� ����V��(A��f)�Ӱ��y/~i�f�O�_
>J���W��T���_��W���K�f�O���������#�*���-�gz����C��!|��l����:�f��w�б[��{�Ǯ��|h ���A����p\�� ��I��!&��{SinM�	����0w�s��t��$��P�s��m6�7�y�ֻ� 
�4%
��<.�R��;Y�c���'Zט#m�G��lp�H:����9:'�8���c� N��9`H΁ ҳm��-LC^���Νp�n��3Զ��$tpaA�ܠ�w�=Ο��={2iBU'���F�����z�_@�I���u���N�,�Ҳ��h�����j*8���1���Y��e�$d��9Ɋ�����O�K��3���������3�*�/��_�������o�����`��?�����K��
Ϳ�����U�)��������\����P�-��E	R����K��cl���u(�p�v};@�Y�sG�=�o��H��>��,IRv�����_�W�he�����T&��j�R��͉�1]0��cϑV�f?h�CO^��(���0�;uZI��!��h;��e>^�0�m�F9fl������#Bݞ��� ��|�q��g��Rrj��U��������~x
����&���r��/|g�w��PU��rp��o__�.�aT��W�
o_��.�?��x%�2���8����Q������a�����?�j��|��gi�.�#s�&]ƦX
u1
�\�e1���F�u� p�`���m�a}��(*e����9���>��t����0Qx1�v�z���`�]��c��F����_��Yh����8��u��RTO�È�<j̄�]��kF�A��!�Sn;�"l�z&⚠:����l���y7>r��t���T�_)��?�$���W�_�������h�
e���b���4��@���J�k�_�c������9+9�Vᯱ�% ��7�g��ǳ���,	���c�ㆹ�T��bxT�޺��p#s�%�~s��(4t���y��]k?�ڹg�@������)�b^|��ж�1���t�o�0��"F�E7Ӭ����	5��D�Xo�Ql�f:Gm᭸h.)�74L��(g=�@�p[�G1��#�|FzxH��9|�tH,̹����p�wk�ʹ�Q�hMX���UjS����ҝJ���9�[a��5� �RgD��ކ��t�w��n�5���`��Ԝ��]]q��B[��n;i�圳�xJX9[��1�C�y��L;AO�%�����ӻ�����E�/��4����>R��t��?NV�)�-�
����	���P[��%ʐ������JW��K�������� ���5��͝dv�
9���D~���P�'������7��������9�=n�C�j
�����m��?�=H��ɡ���-*�;��5Y/��Z�o�JOM���C|k�r�Z��0�SٌI2��u��(�Z"��r��դ�Z>�iB���8��Х��cs �5�͑��hmւg�.��}{��Y#Yͥ.���d.���j�l��;�j��7|��N�aFHt��*�>=l<����O����t���E�*����?�,��:�S>c�W����!��������?����_��W��o����s���aX�����r�_n�]���"U�g)��������\��-�(���O��o��r�'<¦iCI�b�d	��}�H�'p&@�vq�Q�!֧���u1�a0���[���b��(��V�?����?@i��-'�}˜�1lv�C���s�`�����GڢEM^<�c�9��v�u%���Qt/YS\��A@����X�%5�Zߺ�#j��������pF�ehr��Lo�W�(�M{h^��y/�؝�i���$���}���g�|��8BPO�(�T�l�4+����_�_���v���W�Vsm�x�զ��_k�}�����N:u�\�뎡n(�
�F��+{�L��g��v����_��7�ծj�t����M����`��?��ձ~z�`����=�E#$���ϿNe�č����MjWn�����Ż�]%��݊`��k�>�I>������e����y�+�v:`���o��U��NC����0F��%Yݾ��[܎�rmO�~z���bV����͠����p;s�6��}eZ�6�hnuuA�E��!��:7�o�*]���!ק?/�>^�r_�fW�v��kM%��|��^�q�����W�v��}��]t�~O�u�(޼�Z���=����`{�F�S����j/�����-�D��i�Žyx<�}\!?�����7�[o?����<����oe߯�?_�ǖ����5����N]��t>]�7�4�Z��d�qb�'p��p8]O6�u��~��I�^�=,|�	�!�#%pVϗ��}��#���#��Ⱨa��z8U���m.R|Wo�&�U�+�7�H��hȊ��أ�*��o�t�?.6�b�����6���+Ó8[�[;���>[R��Å~�dO,����{�ǭ��^�����F{۴v��g(�z�7�0��h��Hm���$J�!��b�} ���@�/�)�~��Q��O��"��-����@я�����kg������s�9��s�=��T�q��?�b����`��<rn�J��I1�o�D8I1��b�� d�$��X�a2�1Pۖ�12�fKB	$�y�$�=�uGfZn��a�-z�� #�5D�y�	:"���m��%�m�U�5\�xU�$���	�n�G����u��R�
��ldҠbإ@�XpYБ��9� 1�S���eJ��m�$28��OX�!zbN���@�3���L���+$3qj�]��aE�rI?����s���x0��Л-���	�����H�4zC/���־?��g7�'�Bi��D0�����z�v�l/ʲ��rkJ~���"򩵦�ڤ9%OcN�fZ�ӵ9=�9�̙S�g��Rg2����vM�ؾ��.3���[m��T�#Wq����s����4�I�ܜ��s�U�N�"���@�M%�Y4E�}����G��;`-e�G�N�
k���  L]2en���xߏaޛ����m�F�,��F����|:�J�󟡙�sR�?�������z�߂ [�e��jKʠ��zN4*@;�s@��U����hp�ޟ�6��|UBd��6͍FA�;ǂ<�g�=�#*9lI���`�c
jG,�`�>p���C;�B1A#�6f(�I+�
�A��3{u����.�%���ZT���"OG����v˾N����B��?�~�CD�Et,G�OO;J�NO*M��L�U�8�b��rS��������?����<-������f=������Y;;3嬝���c��#e��	}]PeN�iCh䟶I?Q���kM���}?���?\n7m����\HZ������'3�����3�0�߽��)'i�����?��z��ŤkoeQ&ʜV��g�Q�ڑ��뜎7EI�9���BK�
F�T��2
��#��������� )���[� ok���m V�������؁�}w8�wP�2��_WpG�Ces�<�ߠ��XB�H��&�N�dP!rj97��Z�=�*9B�j7
ķ��c�Ű�@e�k����@sO�E�3A���D[�H3ߝ��j�ͼG-"�'�6+�QqS��6A�dE�Pm��,����!�vX���Ϗ�H�"K�)<����Ӑ�_��+�X��U�ʨ�Vq4,.�u#����ǁ^��2a@*K�u�$��\$8$�{u������p0����o����u�Y<w d���*h 㢌��*��;�@"�QBy݀�=�Y�����eU��w�g0ۀ&k��g0H�pB_ԭ������g�oY��I�$D�:���Ҋ��IR��O7����8��?_H���5����U�p�b���*� �<����~&��&���o��۽
|"�y�k3�J�ԓ��8��{]�g�������NG���������Ik��b���?���9 X��4������ߵ�?�t�����I�(\��-\�a�HZ��
U����;`�6�曵�9{Z���*p�0��Y3�g�'��)ҹ�_LZ��_�@��myN8V�?颼��?��_L2�H�BW��6Zue�̘��𪢢Yiv�MŨ��dp��\ٜ��**Z��u N�	䢱��l K��~�&���t|Ӛ��X3�7�?� ~|�dL�m�돬�L6�Ll���̬	�) \����	�{8�i�B`����}�r��p�Z�c/Ų2a�h*����O�X4S9Oo6�dr�]U˩�[D;��oil��v{�
S��n�hNH�����έ��׍Uy����������~]�p{:ҘXZJ��xB�q�;���:�{7�;Ɣnl_@<YQ�Y�NXl��D�ę"��Y�� �i)r|q:���_g�q��?^������'�V��a��$���Q���'I�����t��?ˤ��wy�3�O�������4��+�zaE�}��鸠����VE�ՙ����6@=��=����O�	����n,�1��/M2V���Z]��6Ї��m�����7��[�yb�p4c����;8���eRx��{����O�޵�_Hz��&�Ou�%�:W3��8]X����U�`���>��+�->�nU&^����w��g�0*�^)/ʹ�����g�^���l��v9��^H�����nŦ�3=�.�pd�c��zvc�8��X��.D���dI�9�@+��-|K���"��}��͆[mk���[&�<�q�xa8P:ꨎ���J�%����	9���I�U�_�k�����:�{!����/V�����2o���\�5�q���Et�<s�����_�����^]��=-ȝQm���[�G�h�!q*�d�M��A��@����+�.`L�g�Eo�,��(�/��+�H��9E�o)���]t����u��6ض�G��*��qp����4Pέ��u�*ڇ�קjh|Փ�/��.�jpd5��'WO�x(�������k���zq
'���^t��:���Ӊ�Rq�����]����h�3��.ʻ���B��x
���z��O�����������LV)����0�p;Yv�ު�KS������*{�U����y*�������y��%`8x�އ��u���x�����׫�?|������=��?���8�8�H�~?���<o������� ��������&�
z��M��ľ����?~vťf~�0ѼԬ?n��.07&����컹�y9Ӌ����{l#�cs�^���w��w�0y?23���%��F�����/�@wg0����]H�N��Ֆ��Hn�2A�%��l�h��S�-D��rf��z�U �%����y2|?_vA#Ć��a��e��T�J���t�e�%^&��6.�J���p �5;�C��q_���ў��	��c�>��X/}��9f���׊9k��ҁV��fr�~;��Lk�pB:(��F.ߋ�����R�R�*�b��k�l�a��%���f�9.v�jI��q�3AB98�r/쇗�7�o�[߄w������� ���#-lhʰ�odac|$o�78�u�R2[�&��{�T8�eݭy"�sb4#�s�񃸻�8��;٤T�;���S���G���M:����a��{�f��jDG���l(�kR�|B
28�e���t�̔RDZ&� �#Y�'��1gYg��`-�
�,+Ӊl����-2A�P�Z�.��rQ,��"ao�iq>Qs3b��l���+�f_p�|5�J�l9�W()�M3T#���ґ����9	K�²Ke7���p-\:���j\Á�J4y"��kd���Eo�������9R�W������뭸���;�����K�A���	��ؼV��6THUA�eYO:�de)5',3�S�K�%�����ا3�a8�u�+8eg_��g'Ur��^��3�!,�a���>�������dD����t)�+T��'����j;�Ԟ���	K�����1�%J�zB:N2�>O�Ô��D�> �ĐJ�:C��_.�܄���)5ߎb�Ѣ�{��'��R��k�4"cR�N %A�LXB��(��M�;%$ݑtʙɖ�49',3�S�K�%�$�C�O��r��gkj�`{��+z�f���ݹ�뮁��ٔ�CO ��Z*����Uh���H.Y�Jr��\�b��>JXk�m���}���lW/1�<�A��������޼�e�*v��?s�KW_¾:9��3���������y6��&�l|yUF@[	N�����~N����I��c�`σ�(���� ��5:�S�D~����^fx^h�$�/��^�1����h̽i��	T/�A�:Zn���xVS$�q�j��P�~�rl|����>���鰙����``�{��]�v�$Vʱ�a/B���(�f�c�����r�� W�v��D���g
��_b?���@�늊��0� �9#ƾ������͐o�bF^~���b���qy�A�zPp�A�G+��(����N�r8�nd+]_���ˡ�k77����m�klZ끀��EB����0�c!"$Q?OSa�+�`W�n�B֟6��>�اX�4 w�+&�	q�Y[a����N24��%�;��� ��l��"	��l^)s1�.�m����"G��Әt4FT�Ә$kB!B�zoոL)DBH�Z.6 :������n��Eھ'�t��N(R��M�0 �� �`���ݵ���-�>,��t:�����O�8�WX�e�r��d���2x�B�����Aό�#�	���e��#�	�B��(i>�:�(���F�����!'�>6-���X'�{2B>xD(�	*{���-���p!)Nޙk44�0���ڐ���x/V��uu7'�<IC��,��6�I��]
唦�K�V�ebq�r8�ʱV��r��c�c/��W�S��	��
�,�d2��g:f���nbo@��'2��]�3�}ޑ�E�����_�=��s�h��kI��DҎۉd'�#\� TI��&���t��ssߜ !�|���qg1e�K�r���"�TPd����fPd��	��O��1#2�����j'|�T�p����?�L1d]Oi�*;w�t�ݡ	�����q_���0�jq��a�;}O���$2�����`�l,�42��
�r� �n���""w����':t<��'��D������ӍOĎ��f$�^�TשH����n)Ua���/��'�K'�x?�i؉��]��/R��XO�J���&�R�`?��t��Sl�k̹xXk�X+�M9N��P��c9eԉ����}+$w�0��-��r:�4tdxVW;��Q�h������	�+��T*��i���2xqj��~lX�2RM�U��0�.e����w@�X\yg.��H���,��%����ʮ����׮��o����{���G���o}�����X�9�U�ǧ��m��Ӊ��=EQkڶ%��z�q�\�I������z��$ช��G����'�~����7�W�|���������������w-;�+k�#1�2�%�0	�����^���9��I�Ĺ'�飣�����v�$[�#^ � !!1�!� ���3c��['��%�W��t}K�;m�]���������o���w�o��?	���^Ŋ�N��j��pW��~�?����/�����/����������������������������9���	B;Ah' a ����}H�i�	B;Ah'�ـ���γ�-C�����ʗ����O�`��0�����
�^�C?�x�gݾ��� ��~����Є� ��Y��T*�Jq�q��Y��+b$_5F0����~o��c�X3F[���, , kf@� �#�53�X���%0a����sÝ1��Ұͷ�����+�t����~k� �8;��X��<���D_�S8N�#��!!(�5�J|�}AA�j�s%��\���[m�q��]1V���f]�J^m����湻lI?�C���9l��>	�c�쫄�	d��zx��w��2�Wt��e�^�q�S�a��|.���������B���h��`�I�J0�f(&j��j�fj8�0,���0*��i�(͒$��9�@%Z	��j�s�}���`f�Cc�]��փo�����d���^���W/����ـ�.�o��k���f�ޑ���d���g����<Z�JUA��ջ�X�\� ��b���X�}B.W�M��I5Y�gK§�l�K��
'j�N��d���[⹂o�H§���gS��GO0t��&�GoP/���w�*��wUV;�>��\���)�[ǹ�g��7���<y�=���m�ۓw��Ju��}��ӷRv�����*��'rVjl?��W��Yv߷����}��������v`���o*N�`G�����v������$<Ek8n��
z��-6Y��At�����#z"���g�zͧ�au�nxl��G��/U�;>�IE�$�w��7��vK6�@�ś�'�N77e���T�����+�;���3ņ��hc]:�}ueY��ߴ���)���jm�a�&�3_�;`��;t"��/�R��ճ��!x�ĥ�R�&��J�LA�����slIu]�~D���.�j�+�^ݓ=NL�i|.�;M�A}HD�����G�sx��r���='ln��jK�,/���1\w�;0M��j��f����F�z�#�o�����%12܀f��J��]����n��ѹ�Tɀp6�:����>��B����3[���u�o��R5/�-�����S���w�<��c�������j���j�1��U�����q��^6�N�O[�=G�g0�_iVy����Νo���Ίڰ)�8�������ĖM#�}:E_C��^�����:�S��@����큵���LH8{��x^����?$������,���y"���G0��>{����>����Q�x��_w�A�?�S (�0p	_�Z�F�Bw�˫�7��*���������፞� ��-�}*�s��x��h�G�m"�����?Ă�i��Q��a \��ǵltq���Q�?F���O��?�����麎S
�
J�4JS�J
�k,BQB�j��`�����(bƝ�V���!,�<�Ap=���
�VM��P��p�D^lm�Ne5����$!���$M����eNnl�b�*(k�t�3mjT໼m�-���%?V�"Tڜx�U[��Ԧ;pA������F�a����$���_�6K_w;�4����	j��h�Y�&�dR�Ԡh�4E����|�[���׈�E�q��Q;��q����p��U�z�qr� | ��}��q�=��H��"����UQ�����(�c��O�/ ���T3N�fD�2�A�?�F���a \�/���q��߷�����`�7D����@d�������	������1�OS���:����yq1����Xe��>��9��i�s듯�C��B��<����}O�Z��K���
\E�͖C�N�?�-���˕bW�p��^���@V<�����`"p�s����ȝ�U���}���9�˯��{)��I����˅�!$S���Y��p*ixٛ�J��tI��������U����Q�a���Sfل$w�[k�4��~��.Q�d^ʰ#K癖.0���S]���I�ʸ{=�yfR�TJ��m������N�`�'�k�i
������o�/���G�H� ���0�����������0��~��`��������?v �����b��@�#2���@�#n ��?j���!"�'�6q�ݤ����8E���!hJ1	�EL�LcU
�SCI��
��:���L���/���g�����X�*i3�o*�.GNAo	�T��q��õ��_,��p�����[f���f�q�Y�g�7�G9�:9�^#���H�;�d�:m�nZЂ�c�z͍�	��n>gb&u3F��t$)�6��x-������n��?������?��?�Cd�B�b�� �'B����@��� ����@�#n ��������@�#:D����@d����?"���?�;���S)|(�0��s5�������}f�{
K���F��=ѻ�s�T[ۼ4)u��T�+�WC:%���q'Y���n_oryx��֟�ԐT�	I4��*��zy:e���וj�����e�Y��o��*����$oa�<WZ��&p����N)\�H����9�V
JU�����N�ׂ!��	���Ŝ�uۼ��弧�;��|��eY���,�� ���~9e�oM���Ҵ�'��\W䆙^�+��Lh�i���-��t^)����kUJ7�j����f�T1����0��H���֝|�ʥ�>O�2��'��M޽��q����Gt���q��߷����!���qA,�0���?�����w<���_S�n���?��$���@���޴�3?���_a�S��0 �`������q��0�D�/�0����(��k������A�Ck�b���ᬦk����(���������,IR
P�xs�Q�����?p�4��B��E�]��dR�[��m��T�כ*������9|YY,�Ҁ��@	���=���e�������c)#�vr����Tn����gr^�5�rC�RY@��!�dx�l�k=չћF�O�5����ǫ�ۿe����q��B�`�/�E��\+��_�8�#���@�����kDx����B�b�0��|�'�`�/���G,���@�wD���n>�� b ������9��?BA��������G��8z4��?CB<����E#LSUE!5F�X
�0
�5�e1E�L�F\�47q�`LS5�aL�a��y�>����Pp��o	���n�h{,�☚7��<f9ƚ{��%�\$������A<�'��$��ժl�l�jt�S�a�',�$?t��PZVL��2 1l	Ϋ�9"̊IG�+BQ���S=�
�_�8��z�E�`��Pi������{��,�'��cD�����BD�?� �����?������_:�]�U�
Kb"Yf�Ř&K���\d��X�u+-{H�pȻ��Ԋ�sTA��W['��<�.n3������'����ܙ6��as�WVqF�C��%����-cE!��������v��Lk�/��:�V�ͺ\�=q��M��к��o��B:r�她չ����5Ѯ�ruXkXq�=Z~���O&6䔴zG�\.�����Ҷ�F$��Hd�XS�Ӷ��q����$��%�=&��1e�S�z?{C�^ѩ��<�ŗ{���ug���Ғ��	��Pƻ��5"�}�HNi����D"�^���Ϝ�^��u�H%�|?�V��+��*�FZ7]U
��uɴr�_*g���%Ӆ����)ǳ�|iO�Df9!%rݔB�i^�'e��.(47T�Ya��u��:rxJ��3���'��gB���\��v�,��4M�'|O1���5IV�N�v gҍ��,������`;�����m�ł����?dĄ�O�� a �������`��P�2���N��6�a��u�ޜ����L6R�#���g��9�|��Q������Ku`���@�������lM|0l��O��m1��:ˤf�酕��iqNdf͌Svf^%Sk)r�hye��^1ź�CU��1cG�VJNyu��Q7M�j��q�8�<��pC����v��s��Cw�C�V�kdoT�8[SW�^�ݒ]S&r��dƓ~���.�I�_��{�В
�ĭ&�|�-�B&��6QZ ��,,��T�ޟ����������P���������_,�?�����X�?��������d ��`����������`����Dq`���8��(}��BB�X�1F����S4��C�������k�������WT��'tB�iCI�bT�d	���H� p�DM��p7PB%M֠L�0J�0Ue0�������N����������N�5ӊ4^.r�nӂ�����fW���,�^�V9���G�1��V^ΛX)�gJs�.�]*U&`�$y}Z���ަ��LT������d��#�U�H6�2囚�DY�[F=���Z���ۆ���ʶevƥ�yIό��A�� �]B��C�����*N��L�󮛰F	�k;n°m��&1��#7�	�*#ݹ��M|4fdm3���嶋����}���lk��{�;���o,>���r_W�����*q���Vа�w����˲�4�M���	��N��Oy��X#�[(���]������*��7���m�įVG||���ڃ����m��+X�2�X�{E#$r��n��כ{h�궮;~���f�t�G��ݧUۘL�mT�d�}��%��=u~�K��7�ϗ:7_f/߃��ז�2��%����͖d�5i�ƴ��� H8\l�؜:cI�&�\+o���x`-�����=[l+�u�c_��my�4�J�l������\�uo����K|��h_�.����]j|��@H��Ң	�a4گ6h?Z��i��64i�"(��A��ig�A-�(E��v��B˝33gΜs�̙�3e����u��LN�ƚI�L���0tK�֓�C$�i��sMUi�-֢d��0����)J��b0k���{�>�rc� T�@3��ܵ����ƥ�i�����p{}���u����/�����T�=�ב.1���O��k�����`�ב�Dn�+`�e J0��W7M��9ΊK%n��>-�7@j 7�d�5�'[��l�B�z&��4-�,�F��S��U��O��,�D`�&Bz���X� ��.!�sʥ�j�l��x��������H��3`}S]yb���w����������}�N4=A����!@ڡv(���������)ƻC�}�@�	�x(� |t��}��}�!O�-��g��_z�/�������}�Ϳ9�凿��+�������;i�ѵ���?[G���
��u�C�'�軟[����O��w^F�e�k/O�����lj��v$B9}Ss 27ٹ�x۲77L��}s�$[t.[��vj�-w9�����~�&���I$J��F��>u�{:T��vZ� ��;���f��T��i���*��Kq��V�n�8.�U�Э飚8��EzXiƏ�H;��W�o�Ԯ��f?���SY�n�E��y�{�0�T���?B�1:�f�xrj�̰�-g����A�0�Hx,r�m��6Z*�G�^���w���9������� �f:����@Ƶ����ؼo��y�2����CI�U�2;~Z���y��}M�Q\<<ks��{'��	�w�	G�y���G��M��ac�X1K�L��m��jW��1}$ m�dk�ԪѬ��(�Gh�K�^9�!�H��$ݙ�N)�ו�N�F�3">�3�?������J��*A�3`�2���x���;�X%�����f��j�Hk{xA��H.�$JTH�19|N�� O���Ӭ�����#�pg�����Uo�I���Z&�]*��~���H�T���2�q�n��p;[�e���'K�ӎ��B"��2K슘����zJ���Q���3�#ZJ��x��:4^,T�,Qi"ރ`���JX���!�J,t�'���p5�n���H��k�Q���c��g+��Ndcս&��f��B�,	���� O���,I�GFCo10�G�>��
UJ�ٗC!ܭ&�b��t�-�Иe4n����=�0�K��t>���n�VT�yO �k�f/B�-��1�p��f��̒��L!M�����=A
as�ֈ��ƞ<����~����^�a�:�C;R��%�ݣ}%7nԚT�Cy=1"�w�9D�y.�,�V��S���J;5���=w�T���� O���,��&�B�`���a�=�X<;���� ׉Pv�_�y����Y��lvx�(��D+��U۾q+Qη�Z��<����)��,��f�l�Ͷ�Ͷv���m��^���)�$�N����5t��>���ڳ�'�K�I!b<�wQ�~�Rf}�Zf�qkSE�j\����#�S
݂�l���ϣO#Oy��<yy6��8Q�y��/��#ϑ4������k�C^��>�"#+����芥�g"�#Ȫ\�t��<)��8YGnjؔ�1�~
������ַ��o��M��>!�m�ٕO���{��	�]�0/ҝ
�ss���3 ��d8,�M�6�1^Xa�Q<���w�[d�h�7���{(t�hnX�;� �%J{p{]Go#�t��W�4���_	N��u��OV�����zR��(�K/
�>w���O�
�H�]j�C�pd�"��������c�<6a�H+;aGx�X��Oڡc�0?��þd��g3���X!��aE�"�Akp޺����u}�tW��M�3<��%�����vb��]9�	�#B�HF�2��;q����l����q�pX�V�q�og�2}h�Í,��X9����^��C��� �d"��3i��)<�,�Mك�)8�T,��x9$�5���3���(�t���8�-p��B'�B�@��T��pE��F&�����%�T�G��v��m90�t6�Ñ<��;�0=H�a�%��ӄT!���6�!���xi���b'�%N>S~�p���a�-�ر�+��3����Ÿ��!�0��0m�%K�΁� _�x�5)pb���\˳��W�g���z���������-;��,��sk�Z���|!���Qh���V�Z���d1��G�j�6� �;E�)���A.�1�Bt��-�d��aj��ȴ3� u{�Pk�w�iE�a~N��H���ɴ$�w�B쨧z��^�����!��z�8މ�i�O%E�?��F�@/��D:�ƒU�3d��\�r��T��
���}:�&8��(I����tڷO$ݹj_!�Lo�=�hW!��A��xl ]6��^��3b�Z'�x��#��r2��$�m��a��s��.O��nĻI���>�O��~�ts��8{�ѮK[X�p����M8.d�x�=~Ke�eS%�p}-�[�Ͷ��������B%)��	lI�TZQ%�[��? =g_5<�d�!1��Ȁj�!�єn-tr~Y5*%yV]huQ]An�����j��RTyeΏ
Q��$������F&�]?���~�+|��7���~�o����������,z^�@i�:y�����4�.��DQbe��Ԯ:����87��;������kI����o�ß<����ѭ?��_D���Z��~�}��Z�����y����;$����8��+�Ŋނ��t����������ǿx��/w����ϭ��k�g>�������?L#��L��d	���:��th���N;������0;���������i�!m�vڡ�vh�m��6��!�����z�A�˄����z���Q]FF?�( �,x��W�o���P��������}Kh»�g`�uv����jo��q�p����\"F�Q��01�޷|fs��e3c{[�of�����oflᰅ����������:�̹{�n��֖��p�G�0���K'ZA����c�.��9a�<��DH���s�?�v��u$�.���2�2��TH�v*=٣h�����*�5�5�sB�u#k}�>�b$�X�a��`�̀:8��g�Pa��]��s�L{l Ԧ֎Q��qh�!�
��{ z�W�
�Q
 ��������EiȺD��yL�3�H,W�m����*O��$�����-�:@���(a+1 O!������d��(���48�iTW�)z��^[ �(['KX�����R��+�����~���"�+�b%,_�"�\4UN�s�W#s�X:��na�h���� �� %��F��L�`^, ��kr4����`�$\ =�z���d8�2@���.��W8��6�#���g渏 <[�x�IU��v ��y=
��%�6�5�)��4h[�Zb��w|X��WF+�j�S�u�E��� DD>
0J�@�3�@����R����.c Ŵr0nz�p.\f��mEJn1�TYkEPy^oY>�So
��M�iwb����&昹2�IC�h��8^3�YV�@ǎe�����N��e��Ξ$Ҁg]��w�K�X���}[��Յ�N���_pl`��&����kbN�������j4"�I�q�d���\�G���,�-��8�^�(*
���@��&����E�X� ֧	�v�
��1� �,��`{�����Q��{�sZ1Q����׫)1
TO�d�ܵ1��jO�16��k=J��؛�0:Z������<	���{��s>hb�T�&�>c��	�n, ��@`0�����
U�\���"�O�y�E��b7�`�j ����F�Vv�>A����Y�@(� ��i������@h�Nr��&婢(*����L>������Q���2� �M��Ҁ,P	�b6��or�I��*J([a��6�H9a�.E+�&�с=��g�!��u<�83`��*�[soν���c��{&��4Y淁��yvz�M�`@Ak��;t�t���;�z�1�e�N϶H�B�X)aE`cR˄}t����Pτs��й��a�nh��O�W��������ؘ�', ޻80�M0�A�����{�,0ϱ�tQN���:@䡕���iM8~J�gTeaWk2���rk�;��˧C�4Ӻy��b�4�bZ��{gJ���t�$�`��,X��s��|3rdMS�5�S(���[;�ul�@}�ҦB�F�iR*�����TF��y�d�{KH���.0�N����ՙ~���J�26�ց�q7P2�:8E��:�����-8�Y��cAA��",�vFI����F�cI�y������7��,�1#m��81�r��s�����f]��FY���L�TԩU�5il�8�;�ȃJ���`�{�ü�(�T㞎�|���=��4-(�Vs���:@[���y�8^_0�13XCe�Lx��=��o���� ;���|�8Ih�-�x��3#Xh���^_
�9�)N[{�Ў3��V���<�c��Wڎ-̬vV�É��{���s;�4�܃񘧼�}RTY�=����"y P��g͊δB:E�MՎ����������=����Y�Z�O�,pQ�X��o�r�Ld0�R�������Ra˴Y�'D뤂�(zLR.&ܩ8��jЛ}m 0b��ANZ[O�`:ދ�65����I��g����N{)��1���u��9��Ǿ��Z������?���">�mf��B^\�%��8�B���~V����^� �,��}�<7-�0ݮ]���
.��+��z�ֺi�����Q�e�p�%�U������y�,��ہC�Fbh��i�IN��29����,]�^A�t{8t�j��N_�3�-[�C).����|2�X|y�����M���' �����t %q`�W�F˖��4�9��ny�n��Ђ�IĤLT��y
71���h�v�Յ��N[WS(�@b؇��!�}	/i�)]�1#M��>�_�l,��q �X��
�@.LoJ�z^W�h��`U���&�L���5�^�q��]�.��	�j@>��T�{7S'�3���/{W��8�����+дt�g��`��0aO��ӓ7vc���ߪ�fIw'�1��h�K���9ߩ:��ȇrH0��lD,��١j!�yhѰ�u���Ǘ���2�� ��e?)�Q?A�^տUd]d����_a'B�c��jz@?�RA��)� ?�"X�Ѵ��Ұ�� ��^��IA��!58j��m�d�?]����+�8�����b�WX�}�6|�v�am�H���S�U�:8#
C��Y�=���<�V��FxR�o���q���#���ovj�x�_��.�Y�Jv������?Ξ����7�?Ξ����9<|ӏ�^��Da���%�FA�ɪ�g��7���L8�H��ݳ'���:�����~��`�ޗ�@�ι�$�?���?��kZ�c0�/�wԓ���� �N�|���1?�U���iipt�i=�k��4��y��?(���?��.X��Gt�h�k�!�Sg�:M��:h7�Q�^"�Q���*�F{~����&�oZP-����25}x�e� ����8m�?��qx煎���<&T3���>�y1Ѡ��愃82�����^�߇j���C�:�`��i�[�@Z�d�fԥ���e�B��9:�R�\��x�VZ>���ʷ�N�&�?�}:�Tg(g�H�$�K���S�윭
������T�� � �A��H�����{��B��j�
��x�PJ>k�9�.tҫ�١Ø����5�6A�]�̹�������p$�b��eFH���Tڰ�	��<�{ݩiΏ45��F�ł��_i��#b�/��?T��T��7�lG:�O��T'�c��~�	|G�_gd������-7�[՚�H���8�dN�?��0�����~��?0��4C����*P��hH7|ɰ�u�|�a0ٯ4��MU~5i�vkM�T���t�#%<�����s?}�� e1Fjh:f�Y`�JJuS�M�k}���y`B[�F����Z½�U��g}�+��`���2��_w�?�;!?p��C���ޝ������8	$�.u�_�����/\���j-���q��#��h7���'.�|c?������
�#�̏�9썦S���{����T��n_����H'͏��S��Z�	�аn�,���`_#���#�	�J�˔;�WS�� ��y�7Bs�X������Cs�"�~����9������?/��O�`\E�����+�os�i(Ǡy�u����U�v ,0���S{�u 
�c�,d�Cݥ!��Hj��ڑ(U؊������v��$�?!�6��&����Y�U��.w����9$��FΡxE�I��|�*4a� 0������ٰ���\�I1�}d�MM�ul�`�B^�5&Hg�=�=�qQ>�c��.�K!��M��Ҟ�Tz`�]GO�13\i��m��[`� �x`:铚�!����֝�|i��/m�G�a�F.Ri`1F�J�P ����������\r���6�-�6t��pP�DҜ�4Gu���V�a3������x<��z<�vx�<X�[ }W�h��K�,wv�S�7s�B�mJ���N�P�� \�1���iiзn�`����w�kO���
T�A�(ӻ�$�|���"�Z�@���	;{��ǅ/��cWpW#����D�|7Χ�#�N�SЇ@��ꊇ���;6ڜ0H������V��� jg�^���ݐ�6�=�nO�
�`���t���;#�ň����u�<=J�k�l����Oڨn;�O�ԋ�P/�����J��@���p�>^��p�2�xe�+��}e8���Z��^�ޏ�
po��w�>�u���h#�[@9�<�߀�&vܤ��	�8;&$|���>�O��ɣ=�S�k������?@E!�����h�6z.��nJu��o0��oȃ��D�O����A~�?�}X��\��:
��E�N%���e� ��\���T��kf���Qk0�Ք�E�D�_C"-�8?�.]Ǝ=�;|�B�p����@EQ�hΠ�G{H�q�ȫ����e��o�����.e ��&E[|���R��hnB�f�߂�(h���y�|*�N��j�?Z&�e:#u
�e�x(����,@�Aƹ\J�GKWGL/�*|R����//_J/���$܅����\#)�����⟎��w��Q�������AX�NU����q�9���p�O��.����@c���$ƻ��jm��&%����!?VüN�x?�rd�> DDK	�հ����
@��2�-G�h�Ζp�!��K�����8&�9&��d��gP#+j<����ꟗ�R���Ѻ�`�_ۅ�S����a�y@/?ϲ/������9��G�}����������ó<^���dh��q�;���2�x}��$����C޳�?�~K�3T&��?�Mߦ��j������	���C}}�8�h,�ő�?R�w*ϑ����|����������K�D]�����o��Oa��C��<}����8$n�]Zx!H�`���m��y��y��q���'y�����`8��3*��<�s9�ͨ���H�3IV3)���,�����:E�f�����뇒�����$ɰ�9���_�H�YRAl	�zS�
m)U�z����zAhH�,����L����-l{�œ�4���s�|����Y�0*8v�H���i��� =��޼�r�a�*O�']j�P�U'�Ly��Mg�e��8���M{���D�)�%3�[ߴ�鎽�%.?���Z��Y�o����ոvC'T���S|�|�g���Ľ����(�7� � ������.����\��_�?o�u����� ���0�9�3���C�W��W��W�/}5��33I��G�?��2X��C����� ��	l�l�/	�O�g�?Y����\���c�J����`�S���C�g�Kc`�kVh�7���`^���m��r�!��4�
��\���ݘ��#2��K�kj�E���`E���v�N%�W�kbQ׀�/l������Ma'����´�V��GH>�!K�\�=n��Vn�Yӡ��yE�+K��=f���P�js������_,�P�.,��U�O�z��
Bc߀�����r���So9q�.Wk#�$x� ��u�QN煆(���f�}����["�F����-����E����O��]y�m�RF�k���p6��3uoS�ot�+zO�"�}�O����)ȃ{ng�@���XU��.!�̒y��i���Ț7)ӭ�t�i	JA.�f��d{��lf�	��X�i�G��U�.Z��I��������$A����h���!q���������������4uv���1ɵ�;��!������j���������H����\O���(l�'L������D�?��q5��q��d	�������zr5�gM��3,Eg�>���_��pl��e3<��3d��󌞥���ќ��)�O�<�3X���%� ������"�G�R�:��j�ؿ�O��!�fn�艭|�#���N�V�d�{1��Rn��u��g��%y^�6
�73f����|�H�+��u'f�Ĵyg��#���'���Y�������>�4'���LVG�㭒������Ľ����l�}��?	���\O���xP$���sE����������?������$K������$�?��q=��]���$�?��q5������_kc�ՌIr�R/u�v��������'`�ħC�:��c�{l��@M�P��ZAZ��![ ���M}T��F�+Tһ�A듍�Y��~X�����{�Q_�r�X.���C�c�M[(9����g0g�t�Ӈ��M��,�2�Yh�K��Ϋ�H��i^���^/O��2�%
�f�"{�(8>7�H��0��\�W<m0̭@�ܺ��Yb��EI��;��ꤞ7'OӮ:>4��,���0���b�muQ�<vo�픘9{����զQ��c��xx�4�\��Q��de.YE�I�����VJM�HN
F!��"�w���?�$�8���$n���H�`��c�I���zr-����dH"�����`�?��c������u�7�^���
���H���z�����	�8��-�?�a�?��?�����q��$�t���_���E�y�7�*�1��SZ������2Y^7�>�7h&�z_g(2��P,�#�Z�쓬����r*����G�G����f����"�G-;x�
�Ţ�����Pmd��J}6���|���]]����?����]���{l�'k=�ՙ��x�ӆH6�uˣ�k���;z��I�C]$�;K K�\�s�=���5N��f���Y~z�ێa:�p����?�d1���O�.�������$	�?�^�����"�?���x�_"%�����_��_���4I��?�c��Eb�����'����?����?u��7���\��� �,�1�_�������"I��O�92��3��i���Y��q�Ns��gr9Z5���F��>�gr�l���j.�3)�(~�ą����rx�_<�
���4��}�'Q��R��ܦsS�Ў%d퍗����%Y�Lo���w��3zzV�iꋼ�k63�PMG�Y)?�Jcq��,�([��ך=�H��#�+ZiC��ڍ+1��5�FgN�������7K��:������O�ȕ��9�+��>����gx���+Ir�?r��M`�Q���G�������U��/���j
�]f!���^���ez���nK�,�~�wc��R��t��5����������:�}.u��CUO����k�jNu��%��U�Y��Mm'�Q�&Upm�m������z��N��3�	a�m+Mœ��l������f�l嶚5*͞Wн��Q��cfМ�5�6��ښ��-�_2���e�F�F�����*�G�P�H��A"����^lo��e��_v�����8�O��9C���am������jn3ϭ�kiZ�q���S�ׄ�Z{�r���UN?�T�{j�1"�h�HA����P�ȁ��$�[��n��?�W�R��t�l���Zk���M���ܖ���T�<�˻�(��O,�����
���D �,�yI�Un��͍��[���Tj]]�]/���'.��9�[��V����F��N�_/zE��/
c��7����8u��S�T�|��`���p���ɕ�?�9�+��?�����}����Hb���]L��$��?��<��������y�4�].�{��)v�e���wg�_�_�eo(�g�r�P��"�q`O��o�-��Q5,�tB[���A�B�����Fw���.����ɔ�ݒ[w�^���J��d*�4{�Z>�,�4���qv�j��C�ἶ!(Բ��[��y�6/}�{��!~�{��O���?6��荽N�I��,��Z��Z����RJg��I�1Z#֓�����6�d7�l6r�S�HfkՓ�=mQߒ�O��V۲lQ��=�(��hS���,��s��rZ��s�� ���� �\r�{�����L[�իWUﳪX�=*��:��˗��̷F�Űĝ��ZG��|��M����j�N{7l���dz�_������ǵ�G���� 9�����{�?��;8�k-���`���ғ�����GK���������z����O��%}z�o�����1���3���kHOB������)�E����M���+���L:��ב��?����?��u�'���Xi-�_���s�d2�Id�[��NZ�Ή��l&.�S۝D'�R�H�2�1�I�b<+�Vk;�
n��t�	�~��d2���Z�
����������ݫs�\��q��t�\j���W�,��G�S�U�7����Y�:�V;��^j�v�͝�l�$+t�w�����%8Q{o��7B�Ş�D-��}Uϼ�^��l㴢%�'����NR:I����"����
:s����:��d�+����'�Ha�n ��$LG8�e>�wn@�7�	��η�P��LW�XLV^���3�vO?�Z�Vb��i�R�=�]��>M�v(��Y�(���զ�B�7�26�P�����+Դ�����9/sx�!v�e���<�U�f�R�1���(=���ǃ��N���?���>��1�n�;���Ł��]�ѐ���T<ngJʍz-�3�����%=@�ӿM^��h[�E|��@�E�/��1_�'�������p�g��?}�K�'�d$B�Qσz �=O����b���Dh���;f����o���l:�`�L<Jy���IS�>(Ƽ���d�P�WJ�R��ݘh1_�+҂U3�1�0�
�`�g�y}^i��#Q�D&q^�D�	�KI�'.��Z��@1���#\�J�-BOK�ӿ�Q�D۴nTy�]}ĬtEg~�VX�����ZS���ߴ�� �r,Ι�s���o=��_?)5�B���ey��9[/ָJ�r�-���qn�^f�l������Q�Ğ�G�L�
�`��r���8C��	��\�����Zy9g�^��G>�a0nc�HU���XŴ�߸�Ml�T8��Rޭ���Bh�B�) 'Î�g"hqM��m�e}vcҊ� L��͐��<(�o..ה�|d�4��V������|T�����BR������tC����T�ZR�Ͷ��IL��:��^LׄXW2z�
�G�=���L��	=�><u��T��d��͠���]|�J7G>wW���R���Rt���,�s�:z��=g�.2�&���{�T�)8R���� �>? �C��!���/
VB��"�L�����j ��`� ~hH��N${���PrФ�����H
�Эhu��gv��y��N�<��#4kAw �J�D�Vg���B�T+�M�5[:k��J���5vwйkz
�}�r��4u|�-��{�����6��ϫ���'��qcw�H���0����ZL*1�ft��%OXP+�y�����:G��*s�r
�Q�4�������^e���8���HĢ�~��*'�Z�_��,:l�g�5�ܳ�A_����usͶ^0M��:i'�e�B�)<e���EX�a��-$ϩTvTYVG(��h��R�@/���ű��$� :��(��V���B�apb4r��X,���
�bVa�>6���Z���a��B�V?��l�1_[��C���ڇ�\̮��\h��ݵt��R��tP.Z5Z�ls�,j��A����#�:A>�Z��#���i��2N*љ�Y&��y��c.��cO����#��0s�_�k�(Umq *m�	��N��s粌	~�m���A�x���G�G��|B�dvl%m&�nO�6���0��Oj����5��l��&b	g
,a`	}-a�Z��%�~TK�|�%L|�%�z���=�����yC�Z�O���I�뿹D*1������kI�/C�Kr����m2T���>-x>��-rn.�$'��/�[}���A��גtBg��[A�2���%^jʉ�caaǥ�Cm��'<�����u)��2�h4bxJ,�jݘl�鱣J�=��hgfi�3Eu��⮤Ac[w�E(���L��@����. P0�$4Q[DW;ƈ�DDӖtC�ZC��_6y�j7 ���p�#.L�T�-DrQi��E.
�z�Qa9R��Y8.W��1��#��KrX9.ozKD�t�a�L	{Rl�n�D�C���jDA�H4M���$]$\A�
�/�8�:�F4�ԗS�N�+��BZl�`D^�B�h�^G �v�n80@�bD�7m��y�S\��4��xp���L��� ����FB�$���,bͅ�/dY����`�/��u�9��j�KQ��vE�>وx�'-`6@�M`����k�\c���y��y��0Q_D6I�P!��0nZ��rU l�9 J��Vdx�6:�.��8�1÷�%j��@�7p�+UR6��}`�E`xLk���U%�	�tͦDQ�����;����>}�h`L4��vB�E-G�D,֨�kyrl)�>m�1�PCEA��V"rs�76��ظ1Y��M �8�6l�1��q��nl:e@�Z���ɆU|�w�iA����~b����N�ܴN\y���y�����𷱓�;E��h�Mk�b�9H��/C.q75r{q�� aM�o �M�P9P/0>~���(n8>"v��CL�65y˓���Sb�Hަjk:_��(x	�BQ�(jQBD(�뛈�^�>-F�zp�;�6�7ʦnјl����LG����7�n�������A����n��H�m����VݛT1 ���}�Iv�vu�ŋ��90.�]�#HW4�d�R5���$!qhk��h"@'j�c�e�;+Kl;�4P����cn�Ce@����#j[gx�A)�l�[qC�jg(���Qk�Z���D�VɌLA��:�sF:��Ͻ�������W�@�9z�1n#���o��y���%��^V/{[�)���)o�4uD���4UC3�ÿ{��.ۻ�f�F\�#[�퀋��iwn��'���{0�^���P���dv�U�Cz�iei[�"�cPA~���l�Dj�5^�y��v:���nR:M���;6"Ć"���^E���n^F�����A�1�&�;+�X��lN���6{���$���	�.��`#���9,�i��}��9ca�p|(�s��@���	d=w`�
��ԍ���������ti��r~��&R"l&�=�ΈN��=�<v`���J�?`�{4��{�ױ���t.51���G������Z�k�z/zN�[��9����=Q�lA�))�����΄�$Q���CXdj���a,n�q�v�|aB��,���?,O��/��&W;���o�o��d3��h0j�7�����S�W�N���o���������P��&D�|܇Mny�-�hg`�g�����p+�?���㺚X$�������T"8�a-�����	8$4\4�.E�6u0^�!&#�^4W�K�� K��r����N�E�`Pn���E5��31c�W�C�5�[����S�d ��HOW��}g��N����r�~�q����@���X�\����qQ�Cϵ>�j�1�*E߬����M�yK�Lh
�Q�}�5\�C�n��BEAyeu�dE��׌���H����l*x�w-�����X�1msfU �+0j8��:S�Ƞ̕N��5U�6����>`�q�P�(����P$�����)�"�'�Q&LR�Ԏ9j:�DŎ���9÷JC�t[�f���q�B�Ѵ�~%ょF�a�%j_�D���/���އ������Y4�m�|�S��8 t����SO+�k�2^'��Zl	��l:3��'����%}��_ũ�e���Xs�<�Q�7(X�B�k�|,�G	�A�����=���TNpZ������d��~*��2���
�j݇c�"�c+�8'd���x@��U��O,��81���������eZǰ�B�Z��[��u��&۫cv �c�o r7=Eß�.���L�q_��'��N�H��#-?�\��l������_28�cM���qRf�N�ˬ+-/�\��l������o*�
�-���NO�̖����˘s��l�	A��7���8.�]
�Z��|H�ڇ������?�-��;-��`�w-���C�֣7��<'u\��oX���[I�o��a�M���S֌��줊�~�U�3�2.��m��u ��U��G���E翦���)\��/������Z���p!��QqN䋄\�{
��I�E�l��ֹ�9=� ��/����E_��!�<�*�zb�m�~��'I������>o���2�`K����0넄GM� =2����d��N��]׈��B7V�>▁���Y�Ҹ�>�a�^;:�֠�nN4i
~���nut9�s���� hYR�����䁐��T���;�8ʞ7�]o���(����#�U��������	����Zғ���֝��^!=�b8�1s���G��I4�Jr��h��^l�11o/�3�Q���E ��=�|~�ML���%�Y0P�+��b��K�/f)�9����_g�*���+���/���-�Ȥ���#=��m��h�L��=�0���L���7|�x�Gjj�7�H�d���?噋��=�K�j�D&�_�a��y`�*=i�YG���������sg���5wSǂ�~��!�#�}������n'�?��k\�X�r�%Ң��Dƌ���T&�8����֒PU�1C��f*�a���L��t��Q)��I݉�f
/���}N(�P%���m1��6j�, �� ���}����ъ����`�g�bM���F��o���zD���8U�3�p�[��x�����E-�>�%�<��j��W���=�J̈́�������a�Zt�]����UӀ5�kBO��$��C��(~PUʘ�� �c\��e�� $�<�쌩§��;��J0i&�ɂ�rv&r�2il,�?�V�	&�93�������2�Ț��r�D*��"�T���ZR�G�^��?�я������}�%���V�������N���'Z�T��˥�ۭ/�v�L���t��ngۉ��Ki!%@�����~�Ǎ=��?6��O��7���u�����{�7o������W�~{��ah\�O~u��_¡߳νz�O�g���Ph|sͳ���O�������_���>���=��������R�P��K�G���;u��ޕ�n��ȹ�=d^�^��jCU�*�j�zt|Ŏ.賮��U��}?}�\���\|S-V��w慩�.�\��w��B�p���vz�l��/^��j/ʱV,Y9~���^\�J��^2)�.��W���S��8�_$�}��ή��u������M芭~w���ί�v;��-�F��j�/q/N������Z�x������ͷ�[V8�\V;���vOo��F��M�TF���"_���`CU���Z�x�Pe�J��R�u���w������n|�X�|���������yOm�޽9�(�J����R{`��W�����yY��d��A���\]��z9�r�g��LS:l ӴK&�t+����wu1�[U�[���nww֫��B;R���q�_�J���N�8Ώ@�q�ǉ�8�?�@���@�oHR%*�g�xB�'x���*TP%�(�/�Rp�I&3�?3�a��{�!��s�{�9���w}3~d����J��LF*T��:fH��	~owaITK�5M�X�)Sւ3�tWn�x�X�D/�ׁ��w��h�wm�F��T_	'<���������ym�f��ަ���������!O��/1l�)�e�Ӄ�YP6�:ƺL�+����B@KS������)�0��7����Z�jI�����w�j�1��t�֓FX������M[�l��<i�mKg�H�*�Lc��v�9%EQ��,Q�+��傮NL���H٨ą���#m�$(���@H�[r�R�w�r,��N��M�)k	�������Z�M�S~�L�)�l	������$��.LV����p+F�2+��207W��RWJ��.�J��)�d`\^�T�j�i�-���	~��{\��Ns�qG:ہ���\0�Д�P,lSz��uoO2ha#�=��f&\�q�Zߡc̰6m��zц)�1�M �%O��Q���\.��ވ{��p/_��jI<W����5�֘y��aY��K0���)���N]�d�#�[.��NY�M��iCo��@�Ðb�	C�l���jc:Y����{N���{�B�E�#�q��uM��'ɵ
,�vì&[ �t��S���'����q
�̘/�~�!��"��C�����p���܌���2d|�9�:��Z�]�fx.���==�v���B0((��Q�t�Fğ�|O�:RMΔh�d	�;L,�Px��{FƢ��X���^q:�L�Z�Ć�H��?��宁��7	���d9�}�ը	��t����M�s�VO�J����/��Y�j��*��9eK�%��kQ�����B��3�#ʇtok,�(�X�#�1���i#%�K��,:�����F�LOjAba,3�Y.F���4A��,ߎŞR��R3���g444���ne,�-�Ż��tN`,�r�H�t��H��u`�bkF��Κ��k�D��F�|'��p ����8��z��g�Ɛ�D��2���錅me�Vj��(9JVm���J.�/T�8f,G����Xf���D�M룶'����K�L��r�ݥu�,FU9,�`�6����Z�a��zNod�iK�EJ�����lK���LG��IW���좜�l(g;Yζs�� ���Ҩ=n��K���a;�v>�|x록K�����J�����t?�Qg��Yg�����~�K�<��毵�?D�'c�
�x4��������ܜm��v�.Cc����e��������-�.��q����m�}g⨳A��΃G۲�*���Ek
m��=�]��7o�E\�y����]w�5���g0�����py5k�ծ/Z�=�]�_����ݶ��/��Y���΃�u\���-|�:�6Vk���a;D��7Z�h�g���b�  �.6���N|uLl/��W�,��O������o�������zש[�O�Fv5u+R���B}�(QtR��t$�D�E��P��8.���Ϻi�質\hnQ4%�J�s�R5�ʢ��ʖ$JYN�$��$�Vg�R�v��ܩm�#ݒ���o�.'��CUZ���tNEʀQYRb��$�O��4�̨��,L���@�̭p�Lc3�X�
,2��fm8�ܻ���C!7d��D������\t��A�׭�T�,_N;r7���!0<��&9#jʔ9-�����FjAr��HYǨ�:e��K0�0ef��8@:0����<y��Ϗ��h�����b�vŕ��)6%�-'1�����LA���f�ӗ�������MM��74mx(2�����dˆ:!�x����������$��L���9�iX�^)�@���*���D0/����O5�;:�.r��9�ǆ���g������<�OL6k�r�� ֙��gŧ7*\�.�+伫+|�+���K�cr��/�9�
ߗ!i�;H�I'��8�w+l=KT�pdd�����1�G�G&�CQyvۨ܁prPEV��WPd�*�E6���Y��|�Z�!G�pQF���h��L��(kF��$Z�c���$�����ĩ\K�!1a�Lu0��.������gg3/&��J�"Ĕ�
�M0�(N�`!tiZ�p�N�F���z�����OHQ�	!$��c�l<�s$Yc!�0�[���aތ��׌Z�:�6l�T���*2!z�Ǖ`��i��Նa�o���b�{:�p��J��N�Yjw*�	�$�B΁����9N���#~'J�§N��8�u"H�0�΋��l��c]Н�VJ��hb�'�Z���@.o�o�#��^����p�^�.�6�^�J_�_��'��i?���0l�/0��5 x�^y��:oR0�`c��������+��(��ٯ�{?~��W���w��뫟|{�i�}}�U���䰌]���z�̚u������$�G����:���;Ͻ���ui��~��oaW.�������׾�����`?̀�3�'Oo�����_/���\�}�]�v�kf�y�_~����[O~c7�Y���~��װ�������y����.��aj���ډ���ډh�&����)��).� ����ډ��(gC9ۧ��yj��}��8��$4�8�Fϡ��\PY�5�[BWπzfx�CW}�����Wױ6�	�`�g��:�3@�RѣT�3@΁����#y���AfX'_l,��]���� ���A�в �f9r���f��������2��Y�p���NJ���Gϐ�yV��um���H� A�	$H� A�	$H� A��� ��   