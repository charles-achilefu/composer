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
export FABRIC_VERSION=hlfv11
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.17.0
docker tag hyperledger/composer-playground:0.17.0 hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv11/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

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
� ��7Z �=KlIv�lv��A�'3�X��R��dw�'ң��I�L��(ydǫivɖ�������^�%�I	0� � �9�l� 2��r�%A�yU�$�eɶ,g`�a���{�^�_}�G5�lG�k��X�<hۦg��AW�t>���J%�o<-��_Z�B��dZL��K�����K�?'��-���6B�\[>Ԝ��Nk���Cl;�id�u�:�9�>��d9!_'�,<��W�l�rgG��Q��m��,l�Xmc;6l��L�uJ�"��2��g��sv{�}@[Uܒ=�e���bې�a�I�|X�M��XZr�֔��#d�Ab�N��x:�<�����?�8!!�R�P��9�Q�r��1�D �*��:�s�A�?y���2��O�qQL��N�s�e�XS3bM��p���
F�HQ鏪�����Ӝ������]�񏟅��0�vY=�b{�)��}��B���H�E��"̀	�u�X6ni}�>���&H�M��Zfؿ�e[5{������8��Eh%�/&D>OC�(�0��)A��1P��Ņ���EX�l���]�C%F�g��'�7�並u�&���������yr��Z��ߪ ���

���;��V:&
o =��8��t�]?E1Pؘ��:I�'�̵4 .N������� ���B��"�EZ��3"�Ց ͠�h�� �A=(Fc Tf�1�>�Ǔr;�q��yk�� ���i�A3���#fn����d��8�G,W�:��sr��� 9�Ɣ��>�	��g�OB[���x+
���}tq@W�4�v"��&<���pխ�J��c����:V\��hJ���OQ�c���������a_��|��	��M�G40 ��i�<�1�0�VT�����5M�I��BM�w��(� �h��@Y8��\�;�©�����m-3��К�m	pZ�/��T��N�y���r����Ѽ�H�a��<'�ؿ�����/&R�����1��I|�u��b�eٙ�ؚ��~32=��٦KrHv�l��r4϶	p�����{ٍ��ziko+_/U+��k�~7>������������g�	K4W�A��*����N��Uڬ��?g�~�;�4y���ې�;^���C!�}�q�&;���f�;�d�����/M6�d�r�߭�To�5J���v�d�'�f�.$��d���cC��"$�HZh��?x�G2�o-]'��G��#�4��ʏВ����h�"��剬fQ2q^���0���x�f�H }�LN�@' |��6�|�4ډ���@Zy������f�KV`Q�wL�\h��ĉ������iH �	���������`ra�^�Y>��ۤ�?$$ |��
�V13*�i�)�34b��$aV 9�<.�8��\���l����l�Pv	o��aZech�Hx�ڧ�ل]�@8h�
�6��l��t\�r���t�fT1������i�N����(!�s;�M�p���k
�K�$0���Q�5�AϴU�1���\6uS9P:�fkS��^a�1��{��p�����V:�!v��=�B��ii:FQ��1Rv<Ȼ�-l��P4�I 	�ģ��0��F�Gk�	t�&�_�%3�2�=���瞽��U����F��qa��/����ow�y�oZ�y����J��s���2����̰�ƐsW1�%��y�^����a�G~�9�����Ŕ�����D�.t��I����N�1�������_L9���*��me�Q̢��DvqUl�X�6�l���������1<�7;���9�2���6�_�Ƌ��N������r���#.�U��4���?��)1��BH����3��+�p������>O�s"QL���?R����1�i��f;.¶mڷ�ek��_��veCu�9��`��v�6�q=�ؙmx�@[�(:�9�QDE?�!��{>�m�]��+"�}��}L��ɢF�o"l�M�&��O�P�T�q�žܵ�lM����gW�m�Iv�#86�^�$0���"��]ē�y��؅N���\XX�D:X�n�ǅ���j����B��hM�f&}���T��?�.w�ʛ��D��zosa��h-�[�8�3���r�{�C o[YAa�.x�!:[��|��]ry��/�'�ƜTϯ�|��d0���5���;5��.l�7����������x�S'�m	��Z��/؛�$⡒X"�E�(Ңo�������x��D�=Y;���p�4���b��Hgts^�����mȻ?�*�'�lJ�zƧ��G��"	C�o�<C�e�݈�ֈa2ht�?��0G����� O��f�0�����q+Ȃ�5���̲�/���K1���)�l�O�(��^&����aW�:-6ZZ�폏�}��'��35�$�`��AD'FA\\~�^ܫA�[��fe��V��+ǘ�:VVF����4%>�`�	����У�P��mѿ�æ��^�eSM���s+��g�i0�7��r���n��v����?�"h2A��	11��.��j������Ķ��/�$,���!��m��D��/%�ۣ쥠�ϵH�K��8�,�!*Dy�ꡆ{��S��`��e:�Q�h���Q�3��iE��7R���Gy��8����/�E���y>1�������?̂���_z��_�Oŧ��Iq~��B
,�Lk`k펋J�2�e[Q$A���:�1�5�-�`_-|��n�FJ*�t��A0B�� �E"n�������A���4�`���2}o�bp��Ԅ%/]{���d5U��¾JQ��dR��e<\������enS'd�{\���G����&��k���6�bB~}vb��O��c���>��L l�m�Ўd��6��>�4����<����yݩ.C� �Q�BqD�-L;�V��Ldg��I��k
�6C4�֗0���z�/d'��x�C_za_PqK�`/����t�u�Q�t5��o��4]��@�mL;)`l{H3��P�u���������
h�M6Py��<��8�
��"Tr��1=]E��E�9X��i��U�ɫ�C@`����ŀ�l�-*(،�������XD���%'��9y%�a��c�3[��E]�
���,4�4��O�~�,�\ [�@\Y�S�D����G��� Q���&�S��k8 0p�n���=gDdBwF�*r``�f����ce�Mmar=� 1��	x����GN�l�Ua��h��gQ���b9W�s�I�=����$��'�-L��l����g��M����N��c��.ǔ�]6M̂n2�M�j�V_��Am~����ئC�Z�Fmx�,�m����Q1]|��ʺGo���^�pS��,#�?:����&Ɓ���Z77{���T��Blˢ4�|���o�6+#pz������H �e���ǆ#�n�M�M
�zZF"�N�����mX�4r���
�5X`��=����+����a�-��ʚNɛgO �$on�a�+>�[r��$�hK�jc��K��x>1d7'�����M�e��]�#��T�^���ߞ�3BMҗ�XFHDg��v�I�E_�f���.�L�D�Qˠ*�NF�)���"�Q����0c�+���םE �Z���P�΂�S�&�}l>2�R���%:L��.��jX�n�@�N�Gn��v�_�mM�aX��1cѱ��I e�pf�sA�4���{֨���CҰ��{.N�ƇT��O�d�`�M ��	�Y��<F�$)�h×���l�r�6Hx �u͡zMaP�5P��+x �@Įn;��Yz�i��dn2�5�1�/�f3|F{�@��FC����i�����HL$��>��	��ԇ9���[�oLf�����@ �]L(���b�Ap����Z������~Q�?/��w������ϓo~O��%S���߅������W޹����_����_����]o�J"!f�[�����j��r&�j53bBL�8!�D*�if�	ENd����L/'��r2��w����M#I�����a�]�~��eB��.q�x�'�a�׹��ݟ�}9��˓H��|��O8̽KW'N�{�_��7���0d�0�y �P��o�~�FA�:&w�0~��c��l���g��������h���������"�K���_@��WQ|�����2�?�׭��-�oR��_��������|�;����B(p_
��	܀{t��w/�����cwz�GS?��Hŗ�*�y9Wө4|<�n�q!�S��ߑL(1��˪ �ɖ���8<��]}��������o���K?��/��ͯ�?�����܏������{/�1��C?�p�������;�������}��U����������w�m��?�!%W\+UP�Xo�VKy�Q��\�T����y	w�R���ڥZ�^s����}���e�q�����
�F��~�9�߬�ji?wT�9=._�-��jk�޽���b��$a��ϕ7j�#?xx�t��n�����Ѷ\�\�W�R���}�ܗ?��7���9�u�k��=�����ڪ�������a�QT�9��H�rcW,z�l@	���~�H�����~-Y�(C݀��Fu\y���I�r��NN�mH�N�\/��lh�b�*�>�[��A��w���ުD�֋=�CH��ƽN�[��rX��V{`���������Nb���k�m{�b�-�{��6�)p�~ew+9p��W���o�KG�|^����TS
��T�j������[���{�\W����s��n��d�r6�#��)m,�ѱ+�nޫ=���:hr�������w����) Lv�J����
��:_�j뱜s�^떥e2�=�OY�]�r���W�Q���I�b.v$YD��D�Ԯ��dW�v��u�-z����=���u�D�V����5Z�I��o��[-�e]*��{?�oﻹ]��.�\?��'�ni��S�����;�R�=ڸ���te;��lm�ui�X��f���w썒�E��*/�8[1��F�R8n.�?9՚ֈ5)��5ե��i�Tn�Xnm`~����^�WO9*������N9��S���:S�v#P�4��.�'?(�W��m֦4
;Ц��8��
Z�����c��z���h4u���#fW�ۉ6���m�m|��`l���`�fe�m�7�`�jr��HQns��\�_D��'	�*���������t���.���p��y�9�{$t�OX�����q��F�.�j<��]U ��9�)����<1��M5�X˸j�hÔq+96�:���!֘$��Tb@N�p�<�C�;}[ǯld[x��s}D�T�ۯ$C%Y����<��*@e�I�rm��4���YԷ��z5kLE�0B���p�y}bu�i�����U������2ʚ�ȡ:l��>)�%?��M�������g�?֓���P�:@K�W� ��z�����������d�E֭�$��V˙�:��h�Q�B��PUҶ7*X�o��t<@}��m^�y2��4�j`�\�lX�bK�y��2�s�w�-?,��oP5z1Ӕ�pQY�K[�c�e6���զ�{�d��Pk����1���/�*�_&�S��?�vCH�N�v�m��Z,7>`����i���/��Iع��Tk(�H{�'� �A��{r�A����S���@��#���������Ow���f��$F�;���FDӷ̶3�O�y�ZU|2�W�
VX2MV�6�o��!��1|���G����9şw	?L�"X��-j�C���S�ڰ��c3�������[�m`�F�����Hʧ�Fȵ��2�Y>�)"R�5�eЭ3`+L��wE�Q�t��n��&2D=��&��϶ez&����[�l����GK�]�E�����_|���{�Q��[���W�|��]qv�B~s���*���[����������[�8���ߕn�+��$�n�������](�8��/
�����\V���w{u�������r;�\��_����������¿|{~>9���RY�p���}�娼m�a�59k��L�K=�"��懎��������W��Ec*��W̅<E5���yb.�)��.s!�ԥǢC]qt���*�>1p#!߻
I$�e��`!s��C�X�Љ 2�:w�*UfC�R�M�2��n�ֶ6dg�֘��W-3��j#��l�:�R��]�aٳ�YE�y�tX9F�&h\�L�*�_�e�wb��9c���c ��]=�� !�jI対C�����x�(�h{R��&�����@��Ы����� j�O��U���  A��O�]i����l��P��2��8*�%=�Mڱ�E���%ꂇ�F���S�����<VȒ#�S�����h�&=��?=�i�D(�BY�)%Yn�tuS���z#�7���"�/?x�o��|�����r ��@f���s��Ȯ`��*���X�k�d�M�c��1�|,�����#O���\i�1�ݼ����L�t�Ko����0
�Ҍ��=m֛xO
͍���|n�Z�T�X��^�֡2H�k�ݨ�f};���.7����I����4M�B�T_e�Z(�* q����9^����N���$e�R�m���)2�hU;z:���k���K�z���l������t�MW�w\�jM��p)*�U���xf���XݵZ����I����M�j ���>�D�a�P��ujQV��I�ף}B3�@��$�����y7`6*�r���&�U�t�"��M �UN�q�<uF��`�<u�L�[��`b��)��9
(�]��x@1�9��;N�_Czj4E�Iզ�Ldע�N�"���۾n�>.�����5zZ��:���v{�I��P�l�|����Ԁ��"��i�{�(r�j~�mk��X��m��Sű��a�LlR�����P8|T�2���B�����M����&��r�S.�0�G�����Ʈ�n�� V9z��/�r�7�}�b��0m�o�Lg]J���(���_�ѥ_��+���g��������/:k�F��Ѣ-7���ՄqXxq:��� �LFs�y�	�4�o
_"_$�hΧ����y�I�7�_�@�����������s~�|uw�K���������?"��)��=��sH�3���I��J�?��C���a�e�����i��P��>�����>;�o.0���*�?��^���:�.#��4�y1R�*�D~��eH��"�|*/�Ϯ�A��0���%�o��^���a��t����Z�{����O`(F��O���.(��)�O�8l�T������b�׃�q����j�{?Q���w!��a>������Opj��b��Ǟ������Z5Y�&�k�F�?���d�'�������4J@�O)��u��{�"{@����=�ӗ��*Ȍ��:�Y�<�����?�>����4�)�;��?�#O�����?A�񟌐�w컋M��|�ts�!�i#-�C����K��������6`�ƻ�md�c?,r�����P���L�_�s8�)����/�O>�����������p ������4��i f���g���u���v��)���@��/��p	@����y�\�?I\����_=�� RG.�������?�j[������j[Y���\�?��3C���N�B��%����/��f��� � ���g8�������E.��@��2�wF���f���y�<�?�]����SB>�ߡqs�A�R�Ò8C�����C�(S�˔]�!i���}|�"]�=r��ԟÏ���ԑ�'�K�������lɝ�-��&�N�_�_o�,����N�tݧ��̥:�
�����uE�m����kx�Ֆ?ڢ��@2]m�s����^鵋x�[��a��ۻ�u&�ƻC�D�%�e+�1���7���؜��s�;_���/��^�5Lv�
K%��{7���3�!�����!��M�o����_v�����!S��~�WG����l����/;|H��پ�K�J��[�.�"1S+Ƭ㮭X��i��3��2��=���jbg�js28�E]Uf3�k�(��A��v�S�\ٮ6�V%�Ҫ浇��U��>�&��X����Hk�T�C�Pl����-r�Q��f�L�c�r֟���A.����� �`�����_p�꿬�����}��(�4�h��+�׸�͏֕e�/�W�������J��۷(p�/a���������6��h@e�����S(J5�~�ߌ��²�ac0��2��b׋��	Qo���%{�d�;k�P���ԩ=\�no�rXۭ��Xn��Z�]/�O���,0��rF[�n&��b���*M!�q�ޮ&�.�+-h^'��Q����UQ@࿥�+��;�O>j�
D���AV�9��SQ���T�]���l&�@\�q�]��<"W��b�kp�/F��&K�9�6;����ڍ��-��|w��������/|���y�5�h����Ї�p�G��S�?���
R�X�5����?k����E!���T�Vx����w�������+����
������_��)!��y�-����/��c�_�����6��}^�\����S��i ������������>��������?o�����?;���p��|!����_H��S�����y�ȃ��(��_V��������4��)����SA.��������SAz�����?�	��?����G��!���l�����!�g��p�/3d��03$K@����9������)!?��B�@Z������S*��`�X�����?P��T����d�������S0�/+��8|d���?�����S�c�_���;��(+kQ��"`s��Q4�T��O��W����X�O�)��3kM�YgJSySr��9��Wv�_��y��G��,�N�f��o-�*�=��a�a	�����	�A/l�T�3*�NeW%踱�g��h�C�>I�@�'I�@ޔҊA�::t�6-�Xq	tL[!G�D�d�b:!^UBv;׶(;�y��Bv�IF[�F.P`k�ͱS�!�h�8𺘮Ń�����wF.����0�#d��`q�,�������b�_��CJ���␩#�������� ���a�GX�������8d����y�\�?���!W��C��\�8��`�GX��|�ȅ��H��2B��o���h�v�����?o���'����(	�?��I�d�`<���-��@�G��`��8Zf]
s<�fPϣw��.[f�!M�9�X_�Oy�����0�?���͖�9ڢ�kb����*�E�r���W�����w��o�b����N�t�7�>c�<���K�t$�`b���;-#��[śT�^�G-�LW���~��K��_t�k[\Ǿ�<��2�"҄����'l[�n�
}(xq|h7�(�I�ahUK��+z��E�7ѱuo���Me���y����gv�6�GS8�-�������X�#3d���/��h��,�#�����e�����fj�ƕASR��E�҄��1���U4\\D����h��S���˥@��99-�1V�Y����ء�(�aU�,����!���Fi��sk���E����i�uws���m���Q��b(��@��߱_9�O��Y �`�Wf��_0����/8��_��?Pf�<�?�"�����?+�>���#gI[�m�+�EtlE�:�X����75 ?��{Z@�p7�8�Í=�he�z��eQ��P3�Ӎ=p&���a5�(�XdR"�q��D{�6�ks4#J�m{ʮלe��X�_�Vn:���2Itg�����<��^�Z��8�]��޹5'�na���b���p��6 "���q�������NOO�N2�������6$�H��z׷�-'X���mK�)���=jH������klx^]�ݰ�+�6Ox/ͩ}1YF=�$��:�O�%����u���f�;�h��5�����������$��K��r��%�F�dn�^����퐮x^f��J�4/��w�v1Zf"gQD¾;e��wT�ٙ���g�؝�6AM�_0~��GA��,���/
��܃���"ſ��U_P��;���?
`�����_���@��Y�&`#:JX�'p*�I�v���_1\��a�D�<~�Htb�`Ȁ$��+/P���y���?������������J$f�	�S��N�2I�F�D��o��H'V��ٷ����ܢ�a����:<����������O�������UWP����9��H����̫�_�@�Q�H���6Ń���Ky�&!�""��L����4��l�FM	i@q!1��$xD�`?�:����/�~��k�Y*j����g�2�1ŏw�Q���C�9�l��Ә��R����.W��Z�H��Z��[���'���"=�a�WMA��o�C�����_���u�����o�����{�?�w����
~���w�&���b)��(���#�W��?������}ժP�!(����a`�#��$�`���G2����{���_��?����H�Z�o`�~�2������?����:���W�^|E@�A�+��U��u��(���ǡL�A��;��x5��aH��B���sY��s�נ�	{S�w�eG������zQ�3�.�(1�^,�*eg�^Ǽ~�[��,�ƀl�����8�gJ�{��ɴ\�}���M<f��yxQ|S��<5!�Y�C�eUdJ�s�s+��_��:0�����`>R��8�^�(��:��t���ӫ�?̊Ĕ�S-��_�|4+[H��H-~�(��蜥U��N��f��̾t��Ma��5���fY,����u��5!6����qHl�c��.{���Vj��=�~�o�]�x��RW��?�xu��)NTLj�~#>�9���R�����{Q��� S��r�J��{����`���SNs�=�q~�N֋t���/�[��Kڢ���ݼ�t�{i(���N�d.�Y�ew�lC�E�&�{�d]/#�a��7t����y�	Y�w�/v��I�&?*��߭ ��ߣ������:��,[C�������ϰ���?#�^���"H|u��4ɾ������������?X��zd5�qSR������b9x��]~u������/E��寃RC?i-1�_c:
iM���ᅥ6�,ӉJk�����=G'��k�����0o.��\�GS�s.�TFjJ�=MQ���d��g*$���{�EI=��I��4t�Q�=r�x61�9�g[S̳�����o�-m7��h��x8�1&�s��l�֐�3�۬O+g5+���H]S�U�]���vo��%�?�x�h��?\����Q�V;?8p�.	���.Jc�ݬ�I����۬9#;�F����?�SS������@�c�b��mCg��|pOhN�~�k�L2\{n9�r���l�l��:�8o��&P�����L�ೳL�1�\[��{��B-�^ ���Q���i8 $ *��׎�j��̃�/��DB���>' Ȩ��g���0�	?����������_9�����`-�Ǘ��>�>�'+9���X�L�6D��� �i�6�p �r!��k �����}���<���u �s!�x�^��a��*�9P'��6|¢�3��7���Ƕ��F.�0&�w���g���m7�}�\�B�#�|S�A�؟�`υ ���\L�(�x�	�b/�Y,i���KID\��%5l_M�^��#-�젴6!V4�1e���V�^O�L��j��	f!��ˉ����d��=c4c]����>�i+Hi*��<�R~��A-�?���Q��/�}�%�����_-��e�L��  1u��p�_p���p�������Z�ă�O�?�!�[$�b��p������:�?E>���	����F�!�pl���S8��B�Ft�GMR	E0,xD�x<!���4����wS����?"~��7��nW2�YS�-B�{���R���l���b�5y������b�Z��t�v s�ˈ^�˼&F��y`3g��Lw���,�������#2��f�=��-���U"��ܔa��[����VG����}�����Q����Q���?�6��w��Q��W����#�dN�}�)ۍ�����n��ڼ_l���m�ڟō���?'Y쇇�Һ4�^�!w��ϖ�� Oq�:l=KNĩ�o��� �;[�L'��*n�[���Q䦙�8e��v=�O���V���� �[ux�G���w|s�ԡ�������������?�U����j�����?���������{�'u�%{�]ǃb~�lp���v��{lw�Z�/�*�	��@�-3��M��-6N�l��a��Cm�	3\#h,n�[o�kE�C�H���cq��=#�3c����e/lS���󬛱�B�='�
S�K�ul�e���ی��['���n[*M��wa'eJ[���Ĺhb?m葁�5���X�q$�B���w�D��2��1kܣ��¢]�x�,��2�u�;��Vh��3I��qH��X���[��'?BC�.|C�I�=�)b-t�\'�l��7bA$�l���Fr�R�f��0�v�߷W���� ���@����5�����������$�B��W���@��0ߵ�����W��$A��Wb���5���w�+�_� �_a�+�������W��p��D��x�)���v�W�'I��*��Ê�:Q�������$@�?��C�?��������?X�RS��������:��?�x�u������0�	����������G�!�#�����	��Q ��������א�?��$�`���4��u��������/H���������4�c^����WD���!Y&��y���� :�!�����y�O� �o� �$c^Hh.!6H`��gQ��h���H����^xX\��LVS�!1f���(�ZVIO�툾��I�&���ah���&S����B��|��>~�j��Q��zEI��lU��=�T����;�X\t��+)k4�uI���d���ή�S�6�x+ux����<�Q�@��>�����������QP�'�����	����j	*����������?�����j����U��/���j����c�*4��aJ1Q���D��<ΧTD1r4��x�4Dp�)���?��LC���_��/��x������m�-�9鶩���г�G�'E�?�����g;i7��Mm%,V\�h�#�v����>f�����lNL��&�Tp����l솝�|����t��#
��8���馹lA���������@���K���������S��GA�����i� �����W�x,T�?���� ��_�P���r�j���\����$�A�a3Du����W��̫��?"��P�T�����0�	0��?����P��0��? ��_1�`7DE�����_-��a_�?�DB����E��<����``�#~���������O�D:�r�S�4��r�g�������������������ٔ����~���}��pe�'=\&^j�K3ۆ���^�C��6��]����F(W��(�.�YI��ů��Ǧto"��յ�Z��O����ODS,���r�	!��Xwk?��A���_l<����j��/h��h�3R���A	�s�w,�NZy��L��I%YMU�U|(�Ğs���p��$����}a��KlUĺ �}F�G�heM���7j���0�u��~X^���� ����Z�?� ���P3��)Q����4��f��� �?��'�����C�WU���r�ߎ/�����B���WF��_������Q��������[�$?�[����j�㦤��17˕�r�ҁ��E�b���{��)�F�I����Dg������\]��!�S{.���ENkt��LR�hվ���eB�'���rGQ��Q�x:�R��yH�'�%�kLG!�)�]=��Ԧ�e:Qi�u�tt���w{m�����ͥ���h*{�e����3MQ������ǈ�������E�EI=��I��4t�Q�=r�x61�9�g[S̳�����o�-m7��h��x8�1&�s��l�֐�3�۬O+g5+���H]S�U���[���۽ղ�h>Yu۔ĔWĹ(�r����r�0eCԥ����K�����Xm7�a�A����6k����Ap0����u�u��g����>������d�Й$4\��ӵ��Z:�מ[���73=2����9�۹�	�4�0��#S���,�w�-����F-�?�A�'�DB�Er.��.����_;����S������P+��Ӑ࢔!�g��ᙐ���0�:�C.��(�X*`�����"6b(�
�����p�?�$����ť���L���v�b�"/���"�6+QhP�R����6U��=kw9���_�%��x�/���./��6`�yxf�Wth��&�0&Y�o�*I�tclp�׽�r��R�T�*�J�B��?��R;�e�=��Ն����v��dZ���x/�exxj]|�j_*�9�J϶
Ձ=�i���a+ٚ2S���`�q��U�������������>_y����ׇ��Y^�����=_y������K����8l���}�%�������C����q����^��A'➶���x;rqh�����\�u�m����v��7k+�VB+�����7>��̷�0ҟt4�R�:�&/����4.�����۩>)��ݷ�Χ�$?��֧�Z)y�Mt{����o��2������L�%��
�+��G��(/!�k}������������������������������6{7�?����e��w��A~��d��J�2w��pxUMմ�՗�������+�^���Ѷ#`m�@�?��; ��=�� ����G]9/-�T#x	`����e�̶OJ�����9�f��ũՏ���&�&��]�ө��*ߔ��A���p�TS�r��W�*W��S�ގ���c����$28=^`�}�!`�>�
�8>�-O�ʰ�ʃ�n��H�|��4-�'�k�]~,W{[�o������"���V�s3�iڍ�Ɂ}T����ã��ʮQ�O?�'��:]��?�
7o(���q�^�x�<���nbKu?|S�o�|9�/kڗ~�~hD�|��׏ٱ}�<,i�s��`�ٝV2���̣��'��ѧ����H%>M/���K/;��O������e},���B6���\����?IyE*�xji��C��#�f�㤤뤍�l�f�/�x�U�鴪�c������*3��1�HJc�Y,OB=�{�ТMKe�4�(��*�k���1���dD:Ќ<�m�a��~`��#�<,p�';x�1Ҡ#V�@H�Q�(���Ɵ?t�1�3��b�1���MzL7'�oZ5��F`ڸ�i}$l8*E�	�oڎ��#y�����\�������c�� ������8w~�����h�O�~��8C�&6S8�8&a��3�ӱ�)�"d�!�M4�LMג��:�Z���A�N��D5?�ؕ��H�����	i$>lQ�PˢS�^��1`�`�=�b߶�(AUgbX*tU�۫9�#�M�}u5����;�ҏ_����;bS��'=�S�����7M�2���q�J4s���Yf4��4�������4`|�)����N̎\Q����=���:�'__G�2j@c��@]�h{Iuط�G�샆�Ro�"$�|G,f���.�>�?k�����M�i#1)��D��oQ40���C�tk炵��7���U�Gm`���jd�!�u�ԣ�-Ͽ=�r�$����v���-��I�h�L�IU�)��*�T �W�>��S	�3�e ~SJtӼ���#Q\��G��VIT<�5�X�c�/���t&����z��|%$ox��w�%�.����+��7%89L_�]�}�U�c��#ࣨ���x3��	���F�(��0�鐑�HP*��� E�+�qp3�3���'U��!a���l����^�͈�s�v)�P�~'��#�������8��qDL[���W�n${���3��ֲ�W����t}5$�<�8��:�x�$i�q(���*
�����TU���!��7����-�D������b�;��O��,���)��O%��t6��t>�^����q`�"y�~� ���Ђ<̂���P�cf�L OH�Qhq�Ԯ�6Oœ���.5&�Hf\j�i�a;�o���z�R:�o�v�Q�J�\аSk���S�  �Ʀ�vz��]��67��"��$����=�Ec����5�ė���ܕ�Z��`���Lm�^>G{�^2��,�TM�YVI�mJi>��f��V~�ehO�V�I�խm�-��Svf_�X���[E�w<!1�5�ƥ��# W���>
MW���Zf��E㖩�;�l9�~A�%�+[܏���j��Wk�ڥó���a�c�pGe=wp{�z�[k���v���I���[k���z���oVw�S�Uݭ.(An����3`�e�{:��;U)uZ��t�������M�·$4~�@&�uܙ�YE�0�Nb`��3Lؖ�����8Oݜ����֜���'Qޓ�\��Mv�����w�!(���X��H����Sz_|x����]����~|_i�k��{����"��*��z�Ҭ�W���'{���j�j�Yotw\C�*&	܅$.���\Cq;Ȩ�e���y���u=�����&��U��h���t+��n}�Q�~j��`t;�<�M�p�!��4�O�V��Sxa_jf�P��A�N�ԭ���R�T.uj;`*�j�����Ie�Z�c��<)�\�s�[��T߫�/��$���xV�l��-��
�|I�t�I�dnw���a&�y�� 1n�;7�?�/w�-V8����13T��B������N��)�]���݊�q�.��d�w.PT���I��r kV9���F��]�b��G��R����칚�Ɲ��"������Tv��7[Ȭ���V AK�B'TLj�������B�w`�{g|��h}�F<��@jM���HƑ��08I�t�����D]�� �beH���
w�ɇݫ PE<�%��z�x���J���e�,��?�B����R9��K���)��������?k���������?k����$��h�Ou{u��ݳv���=�.+��F-՜��m���ǲ�?�4���J�Hg�x��ɮ�=My��DO3=j1l�v�!��k��fY����-�p�uO�����4�2�)$�5��Z,�¼�O�&�F�D�{��`'ŵ,�n�j��4A;1��(*���o��k��Y�yҮ��H�u%�Q��d<Q���] l�aW��0SEvD���x��u�.WFD���	�&�>���`׈��F楈U�:�5�E^Y�����߉��i���!{z��wk���7��%��$�u}1]ؚNm����(:����me��s���e���r����� ��|*����(�/�O�D$�_s��H�SF�m��5��4:V��r�:^���VUK�?��?(��L6��?��z�������K���ϛM�=�S�&�F��M��P��#6����'���⾆]��@��t��i�Ɛ��::�{\-॒��T��Z�������gLÐwg��xC�7Lm���b��4^;D��0�!�g*n�&�I�� �i��\G"-j��d\��؂��!��� �Hl��$��7�&��/
Ͳ�l��/@��7��/���V������d�ͿHl���$�b��#�7;]Py���4XmF �c���Q����u�l��2���(9x#6?h��HD�ÀAczu��C�=���!Ӝ�"}������$ ��r!��Jb�?S��#�n�(���d<�áA�fmҿ'@�&W��_�b�:� ��8y����H�O�7�`�k����_`�$��#���P/%�}.~��������v�t|'��k2�&���1~/'6^�����Rc���q	΃)�4L\��K���u^H�j%u��t��!#(P��{Rk��I�����D?~n�F�;oE�I�/h�w�3�|��l��޸���k�Qu�X)&�����ܫ%׼�_�B��l�Ѕ;"�"}7�h�QG�ZB�Σ "�{H@�^ɱ���at!nި�0����3Q��ܐ�)9�7|p�md��U|/��>��3]�d�IP	0W��Dbֳ�ڗ�֏��n������RYJ{IV���I���In���Y_�����l:�2�\~K�I����
t��*P�M��\�̾�`�'�����22W�3E���J
T6��p&G1�K#�*�7�o��2��ko =�����RjW�'��Iw����8�5S��+rq�)V[/�|sg��.��S��.�K�	��mJ"������{�!��\O%�[	C4�9�)���̣�G�����r[f�n��N�L�Η���
�&��.x-�5��9�~?l�嶕��ɗޔ�Z~����r���7�-aR��\��Ies��_��u�ϓ����o��I/������`�M�>� ��ֲ����o4-���������d~��?OQV�~L�8��t���1����k��Ӕ���_>��O��Wp�/��#���ILŁN(�S6�a!9�M���4�;�`��T��6�q�L���~G4�vyڟ@�}�[jwϺ���Gv���D"�����}Q�눭36��-`'b��|��xyɮ�rK���������0d�&�#�s% �W�Z���#�L�]܂P<0�xh�^9�ʏ��c�]�0�n�7?t�����G)�M����4�C��O�B��dr��?OR~^��|D���a-���s�@]����\��$b'|�c�eA��xvY��u�Uj+̸�O��p�U����&w�����/}?�c���3�O0�����r����2��r��/��ep�S�B:�M���6�]���(���R�z���'Dz��j�>�KK(ӥw�o�$l=��E^2��h�#���AQ���+���L/���꘦��>���좸�����,�]>/��޿/���7UDo�*���m	���*�o+P6�;�k����+���G�W��u�Roq����Jc��{[@���& �XL��0>�w��`EBA��g�`�`������OE�P�)ȡ�[�7R@�>s2H��>GfNgP*|����Q��v��<ʀ�x�U�=tB�������`x;�';Jx�~��깎�x�G��Y�J�Q7�+�	S�F���@$^�?At��H�ä�%y�c��aL�W>�I}/�n�y���M(7"�V�����T���3��W}x) o�i��ۖ�&a�}��dd��w�� U$��3'o�y9���+}�Ҝ�����M�J ��-خ(ژ�E�6�Q��\kGf�:H���D���).�-!�
	+�a�Nw^�P�����s�U�Uh0l��M�a<���$�@�2mg���6��Vא��ft��iy�d�ZӐmg�<�AN��*K���{XX|�����4�A��ۙ���xD~���V�Z�[o6f?�t��y�y"r~i��ER)��cæ��iq`a�qM+��b:�l;3�g�������_.�1��NZ�q��L���z�ׅ�V����c"p�6u3ʝ�ڿ�"~Bv!z�*�Z̶×o�z薩���T_:�,�\��cē��{�ozY�q	���m9�����;�7�v��X�n�%_��
��%�����8�a�VzE�D�`����F�hQ v̬����!�r�W���8��:���c��D���췇���eND��
D]�,��0,u����L��.�g���9*�kq��ϡ7�_<8~��=&����S�q�� D�_��3Q���������f��;#H.�&�"('�@�e˼���{��8���{g{k�L�4�m�.MiwA�����i|K�$v�ĹRh�8���q�q�Ѡ�!��h��yA��7$V�WX`X��x��x�#عU������;�N�k�����z|����9����5��uԖ/����:�j%�p�@RF����!?��/&M���Qm�>�)�FPr�y��)�)��s�����^���eyL�$��ʡ��M�V:o��l_��q���>�^�ƣJ����)3�e�vc
�-ùs��!>��y�j��{�b��j���g��.;�e��pқ�AC�H����q8�������~p����?��?��ѫ��%��P��`�P*���(�Qk`Z���F�B1�Tu�1�jT�T��)
��Q�Eq���໷��C4���V?� t ^�|�ïp2������?�y��G��������;�d��r��������7�ΗJ�s��Л�]�җ7�ur�Z�Ϊ`]���ϫ]��-�����#��.<�%��X>��	4��� >��?#~�g��ƿ�����&����?����?��|�[_}�����	������[�n�\�W��ͺ.>c7�o��h�����E�$A�G0�V� �N�\s��4
�u<ZGPo�Q
�G�_\���������j��?�~��~�S'�)�Ç�Ӄ~߆�߆�z��50��з�8��A��:���WD�;���}�1����>��}��/��M����ȡqA\�Ų��Y����d-ӌF����:>l��S�a���V&+��b�^�Xp����ic�V�ت�h˝��|^�ؚ�k"�]�U*(?�W���O�9����Tlɸت�n�lY&oʀ���N.��V�**bNt��	���*�i�ڡf���s'F/�%xQ�[����l�:ROC���k;1gQ!�O���i�S�*%ĩ��
J�Ĝ�čE�S�U���W��ީ$V	�YZ�$#�hY�d��A[F��p�v{������f8�U|�(�Jo�B�#�)��5���$�R.j�@s�I�<�w&z<W ܊xS�b>'=n�#��uz\A�+q�ļ?h�s��e�C;<�ӽE�\�C6����C�H�#~��}���$�4�1��rw����F���N'_�r�!s�`��A+lZ#���8S*j��.�����a]�*�Tzl�B�li�P'�|a���v���j����ڃ����1Z����=��K{S��M{�TZg����L|�-�f�o[���ܗ�����J��7I(핁�$���\�P�qJ�+;RK8}~�g��҄��q45ed$ޞ���MOH�lVR�>"�&(�$����R��r�FEMѩ�Zϛ&.�U��s���'��X��*��↓j)
�i,���y/�#{m�0�+�f:��:&��� �n;�N���뚠f2����&���㳩�Z�� ��0%��~M��XT�Sx�
7�j��\�ۥ�S�&l=lFOݎ��ջ�.�Sy�)r�墘Ȫ�9c1��ԥB��(�3�
x1��Q��?N$��Ҏ��<�ژ~RV�Ŵ�!IU�ʱ���A}1;��4�ǧs�ٞ�����ʵM�l��LO�I�' ���U�����k�Sn6�Yblù8�G��U)22�jI)h��5�	]��@��Z�b9I�} �%��b���Ne�������e�r����I�Y�ҍKS���K�y9�-,�Q���A4�.N�)��ǚ�4��`Tc>F:��pw2C��91�R2(s�GF�(��Y�.�Iz�YR���|<�*�D�Z��,��Nm��3���^�q�����ϻ.��t��y���×<�m��6;�'���X��W�c�!~^_-tX��v��l��`g�/C/���������W3	�Ց���6�A�v��;������.���	��k`+�5����d%�p��}���o�{�~)���.����/����24�,S�I<�+��v���Ӷ�1�ίm>�����[�;�������E�x��\G5o3XR���Ɗ���i.�La���|�
�$JI���V�B`N��0��Ҵ1G���̑X�,�q��kɀ"�Xi��SD�t`�VI�������F�l��k�^�M�=�6J�r'�4L��,v���
�Y�Lta�fY���r��a�
��Nstv[0
�i",��w���ɰ�Z����ÆI�[��H�w�.Mg\%��6K�Pi��x�PR���6i�����r��(�B�SD`E/�X��q�㵰<��\b���Ճ�2�@�M�֛����;]ZI,�	��f�l_��~��N�zB���r%�BG��4Mg�Ƹ�������n�"#����@����Z s����`ӫ��)|D�*3���$�=���[&,˸M�Sl��uw������EWV���X�V��r�j&l���ddު��f)�M�ʦ�h%>T�R��ɶ�ץt8�.�r����6�&��GU'שR��\�e!K�Q�m��U�&�$�����"�,�2�ʬH�Nj�YZ+;B�6J���w9�	F,1�Vc"K�~���D� (S�E��'�3�:�0'MZT�)����jQO&Jm�P���<9I&���گ�|b��)n�18���F�M�O�͞9#>O5�vF`Tae�M���H�ե}BR<C2;1$�4��=�l�c��t��F�3�ĩq�5$]'N��4�֏���w�\wfmL���И��;�6&9Oί
��y/7(���E-��BC��gy��SV��S>�{<;�%4:��y�@�yH�!�ES��ƙQ��P���5��'&�ΛϢ\נ��E9Ǡ��tE�GB�ܷ玪#����FrN�x���S�����	��n
�6�f>� ����t���b��*t�LM���0�u���&c�*��x�vj��ӑ<��|�ì�R�j%*��Qg���ȉ.��k�<�ҥ�@/oK��N�F7^}�ȉd��N����J����h`.�bC늇��z���=�4�=�x�[D��r��Yr��t �=|�y����:_/o�y�^�^�ѓ������,DE�2��9���]q6��Y��s�&��P�M�6h��jv<iV����w�W���#u�C~��|<X<���s�ꦺ �g�	¡C���!=�������O>�7���'�
���6��G`/�g��׳�5���*�d��l�G��"���ߝ�U£M����3�n�&��Ѡk�ã���q����i�K�Vr�궻����u���.=z��#/��k��ߌ�fn���sOan��ё	�lx�@�۹��8�o:��~ı}�Y�c���P��M硎�ND�O�3Q�]�p*�ؾ�\Ա}�ɨc���Q��y�Q��c݅c���?~/�^��t�6Ҧ}�*��c�����O!�G� � ��� ��������^�����?�����)w������ /��/Y��ģ�/� �]`K'eLZ`��ʢ�.�ʲ*�t|�+�J,)NK�8<D���S���]��Ī1����8W-�����v�n���R��|d�:6�u���t�0��ن"�m|��ݓ��3W��S�����"�%縤����<���8�;A�T/X�,�;��??f?�?���G��.���70'~�{����"��A���`��[&C�v �x�E��Î�CY6`Xp�i&�5ÔٮwA5C�<R֥xɲ&V�ӵy.%���jI��s�	;�R�'��ʒ�y�V7TӍ� +�39����b���,مnw�dPU5:�Ƴ4�P`��3b�+������������#
]�W��EPC1���c��9���n����:}�'n�LFР�w�g����ļs\��O�������F�>�Y��e���2�㰋�r��\��.��O"g����/S�օ�G���������_����tj~�{�������Q�������M��C~"����}���9���?;�>�n�x�+|���I���9v����'�3���w� l_�/��$a���O{���s��o'�S�y!A� ��Ϸ�����Y�������g�� ;�^��0r����;A�<�@�\G ������|Z��$�]�O�7��� ���Ϸ����г�?��.�'���5X�{��O�3���;A�m)ȶd[�N�%�{���^����~�?�+�_��Ϸ����߰'�, �	{�����!��������{��`"�>�O���g�Qw�޿���[���G�3��q2�����k� :\��u\�҇�D�֠P�j���NFuD��ѨQ���t�����������c�?B������w��<q���wtb.G`�6S�
�$B�3�JR*��L�W4F8#���/�h72�Β�B1�Bt��4�!�6�X����I�ȩI&o�5�$g�?"��W�H���{�e3!�Q�6�����s�<���i��������
&}��`���?���?�����<�{���Sx~�����i��j�h|�e�R����!S!���AɑêdXr<���F%���R|���K�ݩi�n��:��tp$<.q�+�M�cRJD�p?�(ԓ*�[�Q�]﷒%[������١:�����*���G��_�����������a/����������������`�'�>���G��É��/�]������9��b���Us�Pь�L�4>w�/Vy����9&�T�H��fN�@�zz�l��Ѱ@3b��ٻ�.E�n����7w�+}3x:��[�������l�f�~�*�VQ�g�2M��{G�sNw�	4-�{��|��{�!
�v�U$YcO��(.������T��r�d[s��4i�ew�
MSy�`�Y��fs��Q�gu������5�铖����mJ�Zb�4/4�����y~�v��I�����*����7;f�P��j����z���櫩sSe��ŝ�����c�EB[�Ϣ�zm�բuҦ����:e��s%ˊ�z}]�7�9��W�>�'Q,ڡE�v��Ԯ��k���h�������Ip��$�Fx����X����<����������?
���8�:<�\�������<���0��?���R��x���a���<����[����,s��򿘀��a�a �������X �_��B����A�}��s���ϭ�H����3�Ü�@�����p���X �`���� A�1��*���<�?��q����y�����ǃ������?`���ޞ�ÚP>�������~��+ ��@���,�|r �����p�WJ��)������?7���@�CYH)������������� ����(�������	��l�@mHy �����/@�_Y ��<�>D�����+����q�{��0n�o�4v�m�>���|cɃ������G��Z���QX�k{
����p=8����S��ɗ���j���;�&bgM�6PX�m�1��c��ˮ�����J��q+3�9gݙ�fU6���X�wz/\(6����������V�O5 �B-�W�>l�*3�LU��գ�/���7j��[��2�q��x��	��v��ߨ�3�#�;��:+26
D��#�s�`��4v�� B�1�?@�����9d� ������?��	�/, ���9$~���g��c�������?���W���搥����D�?���@�CsH� ����i������?~^��������2:g�v��/��?��#��9�A�G���^�qR�(D���)Gl,Ё����,K�J$0aL#��c!�I�Yb�����G��d����x�������N�\m��6�����jb���X�yg�^�~n���ǅY�,�@���K��D�����ƓT�P���1�A���&�v#^֢q�Tf]�v\�?W��[m�J�/7�T��d�ZQ�R��Y�p���!^�9[Y\�N#��,�2֫�bd��^��ƹC/�|��߻{Qe_p�@���?�C����CߒA����<�����4���Ͽ���,�R|J������ï������c5�ꔦ��GÅ�nzn+���7��Z1Ͻݫ�{�Y�������7[�����j*��=s �hn u�_��������i#��V���V;�m����*�G�ς��Q�����$�(}��_��O�����A�Wi��/����/�����e���,$�?A�@������M�%����5Sq�9v�*[����ћ�X�o��^z �J��s= ��B��u �e����B^E�Ki���;�(��Z4P\�*�jY���D��(�F��l͵ŏ/j5�4kuF�T�][[-tmy�Z�Q7��!��{/:O{z�v�k�����'�Y��״�ѿ�H=*�������o��lmr?hȦ��ݎ�\��TQ��FT�����~�+�v���YNF�U8��c���k���"��� �er-0�h�m�#7�B]X��l����W�����x[�I��jQ�.��e*yk&���l��,h�'�7��|���
��	Ə��U���翜�Hp��$�F���i������Ӌ`��������ŉ��`�����_0��������_@bȇ�(���2��N|C��� EQb��d�����2#��e��#��pP����q�������G�8�+����N-&rj��:}ꤘ�hլ��n������w��>���w�rS-������(HX��G�?�a�G��SOw(�"8��������� ��Y��W�Y����Rp���p(�b��O���t}�C%�y�f�8%�Sb�I�
!
�":d�`?
$����/����W�?CLb�>�vg��2'��xtvhq��@�v<eg-z��q�ie�g�ʷ�2���?�@�WI����d/R�k�o�G���P��_P��y��%��ѷ���w���i$��a�/���}�|U��3��co���ǃ��w��?1�����퇖�:���������H��������?�����~�!�T �����w�_`�&����	0e_�O��������?D��˾�������p����	�������h������|�����"�p�{�/o��j�~�yF#h�dٯ䫆R��l���M2g�]/+(�9,e�Ec�_̾s�E����9M��eh89�k!�͡�y�Y����l�`��35
4r�Ŝ8Z���3�����	߆�BG۾���� ���?������������`�s`ˢV���N�������ozER��)�����4�|�+�Zz,#�5C^.��}i6��z��ͪ�jfN�����i�d.�;�}#]e�(Wk�7��+ˀ�]j5��cv�1���x}�0Cn����H��_�[�KSo�,k���Sīq�>�:�(�v�D}������A�EM�Ce�i'^b�|��23���y�;�[S��P̶�x�����o��,��ߦ���GvU;���Eu�/rm���ɩ�"��Ke���}%Iy=�����lݶF��Dt����ZY=���o���i�Qߤ�ؑY������C����y���� ��s�?"�����5�C�, ��?	6>$��+��� ����{�ߺ����������yZլ�v$ͷ�r�����_]�e���k��i)����F�K�ꆊ����M֝Q���'�Y�:��p6��m�ݷ������c��c�p������ʠ^�2�leĎF?oS��j�s4��;ڄ���{��U�:�͓�1����;�m�(����9\�h̨a�����r8�V]?��ڬ�io>i"M�ݞdgδ�'�y�����������T��<��vo뉡:o{��Uun��ϳo��M����	:H��)Ծ�Z��.]���F����k�3gB�G���//멨�NT��u����鉔n&��?�x]a�Tg�IE2l!�m�~1P�����IOh�۵�8O����"�.E:�����w=?�"���U��ڮ��y���X@��{j  � ����D��`��cY���'6 ���/�����|����������y����-.��z��7�����������ޚ�P���� PO�`��� P������4p�z�i3y�i�� ���KG<l�%5�Ic[�	�r�\��~�8��5{���rLٌuFu���������I�XM��hϰ۴آX���� �� �{r �d��]UxQ�o��˨�f+��F��R0�4�ł�y���C_r -�~�6C̚"F̚�hg�o��x�(��������Z�z4Vn}�F��n�?����CM��@�2���Q�柲y@���_���%��� ����D�?���@�C  7H��p�_�����������
D�?�A�����et���>�_��n�G�s߼��������a�b0�#Ib:�d��cY���P�Y.�A���9�#KH		!� ������4��?���o4m����Ϋ�|�Ԥ��3�\k�ZW5#
/ݦ�a/�ߺ���y��My�!]�\�Z_m+A�P�`韽�pj�H�u֚'�l���C��F,
ժ��-�ާ�u�9������	�?��,%���
}K	�?���@�C���@ �?�޿�6���	A���+���uB�N���/j�M3��J+����3�t��w֘�)?���A/��-�ޡ�r/U�]���̞�WËG3�r)���Ĝj���Z��Z��8=Yꮳs�N�c�jT�\�>�͢33�ߏ������ߒ@�������xm������� �_P��_P��?�����X����G����>���������5�N�{q�y��(k�w���_-����Y�ݤ��M��Ť���~��?����2�Պq\*;����i��u���F���z6��摱Z�P��?l�ݤ���+���\�<o%b�_�n���̱�u���˕����u�-���5�p��{a�%fM��u�Bu���Y�֫I҉\�8Ќ@f.��i�ub�2��\�������B�1=ݮK���)�3;�L0�\��9����:M���T��r�T��M9f����f��r�W���n��>*�a�-��&���n� 	�����C�g,���F����{����, �����?X�����+� ��/��Y���wI����ܕ4������`�+��W��
�_a�k��_����?&��0�T�������gY��%;�È�@����� ������?��!������?�B*��n�G���/��F�����/<������_`��om��H����������<?��q���_��$�?K?����X������X������o�?��?����?��!�_����`�+&`���Q@AмLKS4e؈i� �D�W"��E9�P0�YFB�Ne%⥈A"�`�߇���h�í�迏ǯ��0i���N}a��M�,%�v0P���������:����������ޕw��d���5N���c	�<��k�-���f)�EH~���SȖl9v�bI���Q���{u﭅�&����=3�[f�4&��rny�ws��}��7M�&��|�dH���XP3�\���|mh�yf\��M25/��x+���O���x�?�?�>�)��C���������S������x�� t(�����&
����I���x�_��/��w��?�������С�?��E���̑j6�P;�T$5���"��l��a&G�Ԕ�JgSR��A�T 2
D9�x:�_�?��q���_=��MW7-����w�����%���KU���L�Fl�Ka���,&�ɻ��$g�U��h�6�)H�\cL4:�Vu���Sj���M����<�v�z4��AǞe~�"�py#�&?Y$�B�+������G��8K���T���3�������S����O��:����<,�b�������,���@td��?yd��?����?�g�'���N ��/C�b�������~����@tB��=
���:���������������9�1���A��?G��oC�b�����N�C������ǃ�I���Lq����}�@I�� z��=��K��?{+���G.�f�j�m�L�����E�W����h[�?�u�e��xͿo���E�\I��"p�vx���In��3�t	ZLs=����TƋ�?�V�}�V�*�O���Bμ+3*�q�� �n��d����=���C����/�߄��,�WC�~��m�b�;n<������w�N�2a��N��i����z���,C��`As4��GY�k��F�T!Kd���fo����:�d8n�C=Ə��O������t���ƨ}��I�T�����=�����q�c���G���{�'���=������������C�)��������?��?��?��?��?��l�����8��[��������������?������������x��x���?^�/����6��9h���$WZ[7Y�fF�����B����Ч��������N�Dk=~֘H%c��sO
�����^a���\���E���#:�*�؛0��J���^��7��t�9�nz*��\`�0O�'Ѝ	Q����'r�ޓ�ƴB�{�٫�C�6��M1�r�e�l(���2�B�a
���W���Q
nL|��E���\��UW\�*�V�^}`Ֆ�ƍ>��i7S��N�+���p�5:}u$V�jQT����g����/��lũ+�Nf���W��W��L��>|!���}[�
l=p�;u�Us;e�:��~�o��|��ps{,zY���	�S�����bޅrEl6m�/f�:}�.3���Y��P��,��u��W�<�T���;�7�LN�ϧ�����g�4�þ?�/y%�U�n�����b-a!
���z]�fP/�DR_�L>�T���c:	��ڳ�3���A��\;�e���?����m������Bp�W���N	�U�������PJ:���\�L��$!#夬,�d9�I���L�$�L�9�ʧ$��7~�N��������_y��s_W�+��Z�b��!��-���j1g�穥_��7w�T���۹��5�Lg����7H��B����/J�hR۳�U���Mk27S���ق�h�^(�k-����"-�ZZ+���YUD����V:��?>��xt���5�Iߣ�)����w<:	����8� ���&�x�����?���G����m��U��9ԲZ���5�.���f�9��r����B-�i
^k%���X;����q]S��	��]]��՘!g�ќTci���������ù���5l,Ye�=i������i��t�=���/�	��Wl�:��_����Q��+����������;n�'��A'a�e���T:��A���{d�i����-�qK<+Bo~���
���ѳ����(���Ye���hvY[�?���� b۞ݻ ��ri`�Sv��J�M ��`�K�b:�*�<��V�zo�􌜍m�h��\�گԊ��-tJ��L�k�Π��ް�r�M7�E�`�+??F�[۞��9�jc�'�q{�}7ԢW������= �~����lN�2>	v��MZd�IMk�Fi9�
R��w�k���	���5n��n�i0��S���v{R�����㛊���i��n��w�l]h�aP%���(&s�w}/s�Q����H-Tj&aeԻ��p���sS�O®���T�5ܹU/3C��>��ڊkP��zֻ�ީ�i4���?��ƫe����,C��?�f�l������k[�&.�pute/�5��i��@.��� ����EM������MWWuh_v!�xA'H�e��u���5mځ�ᜁP��n��� �
�m�ES�tSC��3�����*m�� ��2���ށ�h�sx�U k.��%زۂ�_]6�x�]@9��.�����a�@�l��ƀ.��B��N�	�r��S��'��_/ț�}�c�]DxS���_�zW��?J�S�������MT�9V�Nt8Pĵ 4Eɀ("=]���HE�Eh����	֖gG�ڳ�J PGy��0���`�qQN=��Ot��PC����hѶ�5.'�z���[@c�c����J(��[ ��ۇ'����t*_@oh?�^
g�
)~}%�����e���@�h|	���17z=$,�-h!�������.�g�z?n�\��k�;�.�˝�.���Gb��߾%�U(�߾�}��?�Q[����Q�.E�C/���<�~�֨��8!���
l�,��-��N��ho����W-���S�58C)��Eg[����(/�Ź�۹Q�M�:E]H�����.4�n�@�P��U�D��������� ���`�Ti@(�sˆ��5��m�j��&���'�:b�����ZbX���g����ߕ��)oy�{Am�ndyh�[?�%����%4�#!�<��kp�.*uS�+𹋯�D��|P}�>*C�k{��Ǫ�y��_;*ذ�f?`#֨qØ����A�"���a��=��@��I�/�t'��K��5�;|� ���F�}�1퉨e\��?�*/[��;��;INo�@�m���.�v�f�釄G�A�ֲQ;��}C?+���}C9"1y?u��q��t)j�ގ������9��Ƣ�v�/8��j��zŉ�a�b��%y��$���"����$C1O�&����A(�h��hc���;W�=�N��"�u*�-_,ݶ�^��ckX �|�
��Xؖ�#{��$'�7K�d��s���<������		��>G~"�&46�� .���j��&"��ߕ�܎R��;���+�[p��׉���������&�x.�N��T��� ��hh���O�E@�a0��9�=Z����A}�^@ۀ���"Y���v�2���d��R�-;��q�x���f]�JBWN�e���Bg t��X�,��{O�H|�R{Cᛩ�O��~AUa�c�4��j*��hQ���<�t
��j&��2T)%�R�HK)��V$UR��arP�3�3#��8��:˒i��	"f@�%p&����	�j<�	�����-�w��s�?ƒʋR&-J�D292��
ECF&ż(����Y2����()�La1�Z2��LRbF��a����/��\(���XZ�7�[͕��nYL^��m�.0����N�'�(c�|��O�ߓ����x��6;����$4�[��5K5a Ԯ(y���*ݞ�`����^���s���n]蕛�+,!�eݯ^��%�����Z�۪�"�]���P�<�>�"j`�;`�[�����n_���p����Iұ夆�:O
d�y_�*�����H�I���>�E���n�k'ۮXs[J�-�Q'�Gq</�i���/�/���"�����;��X�K��r��DЃ�|��4�f�1g���v��B��jV�+��W��d�Y�K�Nڞ�V	g[>�'q�H"��»y7��Bk"頞խ����r��㛍b�t�z�f�ZGow�Q��m�}���Ѩm�ȳRC���L"p����B	=���=!�[`{,�v�+��ʓ���|�ϗ\�N�զ�d��"]��9�*�ü��8�S.��C.�n^����T���$t��)����A�.we����/8��y�O��'��1��Jp+��4�Y����H��E"��h#�G�(���f��)�<�q,�B��
�m�SCE�.j�$�Dwt�Prq������ط�.m���bp3�L~��W�R������(*��?)�%4��@�-)�fR�	^�!��	T�v\ m۲�����.c�nN��s'p��)@�x�@����gC���?� 2}1��\�E)�v˞m��M�(�e����>~��?�N����?ėo��~��N�Ϸ3����/`�+�f۝x�̀w!@5�q��Y;.�<\踨�AA�b��=؇a�5�Ap���a0�azT�7e�U�����Z���
�����yE��/�x�O�f��i�p�`�4ⰛنJ8Y�$��Ux0��xh
+�^_]�s|��s`��+�����,��4��a��E���S�[��q���`?���������L���T�F�O��T��������T�<X�(=T�Xd#�����1�Y�=�q��a����`r�&0yd�^���da �a�������^��Hտ��?��P�X��<��,�Ѡ�H�6��*XG�W��h��mI&(��U0A�|��[�s���?07s㘇�/.6���\������R�/�,P�¸0J�;��_�� �g�aৡڃO]˶�_��{�d���Zє%6C�b�RW/���O'�O��]Pr�n"�����Ѹ3t�??�p틪L�z6`��e".�.#�DZ` ����h����(�����'s�ki�9�j��_�˲<
MC���l��--wz^t�����n�3��`���t�^���u45�v����5e������w���k�Z')Q�bB.�����]JzF�K���ȋ������"��ZL��&�K���,յM1�?%�l�o��P�	Q�͍�M�\�j��˝��<����|gdT(�Z�]v�W��1?pMeپ1�<mu�����KV�Ƿt���ʹ�%f�Y����N�=��de�^����h:�٩���A)5�͠?��z�~<��f��Q��Q/4apݏ���a�k�5��*������ޣh��MO��*Ajo��q��x(�����r9f�������CiZ����1/m_��m�}P
���m�wK*˪�3p����:�.I��f����%�����͈� ?�nemHEW����f�.m�Rޓ3cg�����:�v"���������A�C+g뿐
2�{<t��gX�9����͛�/�LҷD��?T�#�A.C#@O�E�?�3�-�K���W�Ӗ 5�v
�"�UVU�[��:����Q��f����m�U�DǨ�m�$�X�1"��[�rڵ?�7r8�$N:w�3e��K�֙�2�J�1?@���$=��s���`0��`0��`0�����lZ 0 