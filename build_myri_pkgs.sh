. ./common.sh

PKGNAME=myri-snf-all
PKGSRC=`ls myri_snf-*.x86_64.tgz | tail -n1`
PKGVER=`echo "${PKGSRC}" | cut -d '-' -f 2 | cut -d '.' -f 1-3`
#PKGSRC="CSPi_SNFv3.0.12_for_Linux.tgz"
#PKGVER="3.0.12"

rm -rf "${TMP_ROOT}" 2>&1 > /dev/null
mkdir -p "${TMP_ROOT}" 2>&1 > /dev/null

mkdir -p "${TMP_ROOT}"/opt
tar zxvf "${PKGSRC}" -C "${TMP_ROOT}"
FNAME=`ls "${TMP_ROOT}/" | egrep myri | tail -n1`
mv "${TMP_ROOT}"/"${FNAME}" "${TMP_ROOT}"/opt/snf
(cd "${TMP_ROOT}"/opt/snf && ./sbin/rebuild.sh)
mkdir -p "${TMP_ROOT}"/lib/modules/`uname -r`/net/snf/ 
depmod -b "${TMP_ROOT}"/lib/modules
cp "${TMP_ROOT}"/opt/snf/sbin/myri_snf.ko "${TMP_ROOT}"/lib/modules/`uname -r`/net/snf/
rm -rf "${PKGNAME}"*.deb >/dev/null 2>&1

fpm -s dir -t deb -a native -v "${PKGVER}" -n "${PKGNAME}" --provides "${PKGNAME}" --post-install ./myri-snf-scripts/postinstall-depmod.sh --deb-user root --deb-group root -C "${TMP_ROOT}" . || exit 1
